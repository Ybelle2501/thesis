import 'dart:io';

import 'package:flutter/material.dart';

import '../services/classifier.dart';
import '../services/grid_scan_service.dart';
import '../theme/app_theme.dart';
import '../widgets/grid_overlay.dart';
import '../widgets/shared_widgets.dart';
import 'result_screen.dart';

class GridResultScreen extends StatelessWidget {
  const GridResultScreen({
    super.key,
    required this.capturedImagePath,
    required this.mode,
    required this.cells,
  });

  final String capturedImagePath;
  final ScanCaptureMode mode;
  final List<GridCellScan> cells;

  @override
  Widget build(BuildContext context) {
    final healthyCount = cells.where(_isHealthy).length;
    final issueCount = cells.where(_hasDetectedIssue).length;
    final reviewCount = cells.length - healthyCount - issueCount;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Grid Scan Results'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          key: PageStorageKey<String>('grid-results-$capturedImagePath'),
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              '${mode.gridName} grid - ${mode.dimensionsLabel}',
              style: AppTextStyles.displayMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Each numbered cell was cropped from this one image and analyzed as an independent scan.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Image.file(
                    File(capturedImagePath),
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  Positioned.fill(
                    child: GridOverlay(rows: mode.rows, columns: mode.columns),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    label: 'Healthy',
                    value: healthyCount,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryTile(
                    label: 'Issues',
                    value: issueCount,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryTile(
                    label: 'Review',
                    value: reviewCount,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...cells.map(
              (cell) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _GridCellResultCard(cell: cell),
              ),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Scan Another Grid',
              icon: Icons.grid_view_rounded,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isHealthy(GridCellScan cell) {
    final result = cell.result;
    return result?.status == ScanStatus.success && result!.isHealthy;
  }

  static bool _hasDetectedIssue(GridCellScan cell) {
    final result = cell.result;
    return result?.status == ScanStatus.success && !result!.isHealthy;
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: AppTextStyles.titleLarge.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _GridCellResultCard extends StatelessWidget {
  const _GridCellResultCard({required this.cell});

  final GridCellScan cell;

  @override
  Widget build(BuildContext context) {
    final result = cell.result;
    final presentation = _CellPresentation.from(cell);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.file(
              File(cell.imagePath),
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cell.cellNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Cell ${cell.cellNumber}',
                      style: AppTextStyles.titleLarge,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: presentation.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        presentation.statusCode,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: presentation.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _FactRow(
                  label: 'Plant visible',
                  value: presentation.plantVisible,
                ),
                _FactRow(label: 'Crop', value: presentation.crop),
                _FactRow(label: 'Primary finding', value: presentation.finding),
                if (result != null &&
                    result.status != ScanStatus.noLeafDetected)
                  _FactRow(
                    label: 'Confidence',
                    value: result.confidencePercent,
                  ),
                const SizedBox(height: 10),
                Text(presentation.description, style: AppTextStyles.bodyMedium),
                if (presentation.showRankedFindings &&
                    result!.rankedPredictions.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Ranked model matches',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...result.rankedPredictions.map(
                    (prediction) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              prediction.label,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          Text(
                            prediction.confidencePercent,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (result != null) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiseaseResultScreen(
                          capturedImagePath: cell.imagePath,
                          result: result,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Open detailed cell result'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: AppTextStyles.labelSmall),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CellPresentation {
  const _CellPresentation({
    required this.statusCode,
    required this.color,
    required this.plantVisible,
    required this.crop,
    required this.finding,
    required this.description,
    required this.showRankedFindings,
  });

  final String statusCode;
  final Color color;
  final String plantVisible;
  final String crop;
  final String finding;
  final String description;
  final bool showRankedFindings;

  factory _CellPresentation.from(GridCellScan cell) {
    final result = cell.result;
    if (cell.error != null || result == null) {
      return const _CellPresentation(
        statusCode: 'inconclusive',
        color: AppColors.warning,
        plantVisible: 'Unclear',
        crop: 'Unidentified',
        finding: 'Cell analysis failed',
        description:
            'This cell could not be analyzed reliably. Please rescan it with steady focus and good lighting.',
        showRankedFindings: false,
      );
    }

    switch (result.status) {
      case ScanStatus.noLeafDetected:
        return const _CellPresentation(
          statusCode: 'no_plant_detected',
          color: AppColors.warning,
          plantVisible: 'No',
          crop: 'None identified',
          finding: 'No plant material detected',
          description:
              'No recognizable leaf, stem, fruit, or crop structure was found in this cell. No disease classification was reported.',
          showRankedFindings: false,
        );
      case ScanStatus.lowConfidence:
        return _CellPresentation(
          statusCode: 'inconclusive',
          color: AppColors.warning,
          plantVisible: 'Unclear',
          crop: 'Possible ${result.plantName}',
          finding: 'Not reliable enough to diagnose',
          description:
              'The image evidence in this cell is too weak for a reliable result. Retake this cell closer, in better light, and keep the camera steady.',
          showRankedFindings: false,
        );
      case ScanStatus.success:
        if (result.isHealthy) {
          return _CellPresentation(
            statusCode: 'healthy',
            color: AppColors.primary,
            plantVisible: 'Yes',
            crop: result.plantName,
            finding: 'Healthy',
            description:
                'The ${result.plantName.toLowerCase()} was identified and the model did not recognize a visible disease pattern in this cell.',
            showRankedFindings: false,
          );
        }
        return _CellPresentation(
          statusCode: 'abnormality_detected',
          color: AppColors.error,
          plantVisible: 'Yes',
          crop: result.plantName,
          finding: result.conditionName,
          description: _farmerFriendlyDescription(result.rawLabel),
          showRankedFindings: true,
        );
    }
  }
}

String _farmerFriendlyDescription(String rawLabel) {
  final normalizedLabel = rawLabel.toLowerCase().replaceAll(' ', '_');

  if (normalizedLabel.contains('leaf_miner')) {
    return 'The model recognized winding, mined, or damaged-looking leaf tissue consistent with leaf-miner feeding.';
  }
  if (normalizedLabel.endsWith('_npk')) {
    return 'The model recognized leaf discoloration or growth patterns associated with a possible nitrogen, phosphorus, or potassium imbalance.';
  }
  if (normalizedLabel.contains('bacterial_leaf_spot') ||
      normalizedLabel.contains('bacterial_spot')) {
    return 'The model recognized spot-like leaf lesions and surrounding discoloration consistent with bacterial leaf spot.';
  }
  if (normalizedLabel.contains('mosaic')) {
    return 'The model recognized uneven light-and-dark mottling or mosaic-like yellowing across the leaf.';
  }
  if (normalizedLabel.contains('cordana')) {
    return 'The model recognized leaf-spot patterns associated with banana Cordana.';
  }
  if (normalizedLabel.contains('panama_wilt')) {
    return 'The model recognized yellowing or wilt-like patterns associated with banana Panama wilt.';
  }
  if (normalizedLabel.contains('sigatoka')) {
    return 'The model recognized streaking or leaf-spot patterns associated with banana Sigatoka.';
  }
  if (normalizedLabel.contains('white_mold')) {
    return 'The model recognized pale mold-like growth or damaged tissue associated with white mold.';
  }
  if (normalizedLabel.contains('spider_mite')) {
    return 'The model recognized stippling, discoloration, or damage patterns associated with spider mites.';
  }
  if (normalizedLabel.contains('yellow_leaf_curl')) {
    return 'The model recognized yellowing and curled-leaf patterns associated with yellow leaf curl virus.';
  }
  if (normalizedLabel.contains('late_blight')) {
    return 'The model recognized dark, blighted, or water-soaked-looking tissue associated with late blight.';
  }
  if (normalizedLabel.contains('leaf_mold')) {
    return 'The model recognized yellowed or mold-like leaf patches associated with leaf mold.';
  }
  if (normalizedLabel.contains('septoria_leaf_spot')) {
    return 'The model recognized numerous small leaf spots associated with Septoria leaf spot.';
  }
  if (normalizedLabel.contains('target_spot')) {
    return 'The model recognized target-like or ringed lesions associated with target spot.';
  }
  if (normalizedLabel.contains('phytophthora_blight')) {
    return 'The model recognized dark, blighted, or water-soaked-looking plant tissue consistent with Phytophthora damage.';
  }
  if (normalizedLabel.contains('bacterial_blight')) {
    return 'The model recognized blighted leaf areas, spotting, or browning consistent with bacterial damage.';
  }
  if (normalizedLabel.contains('phytoplasma')) {
    return 'The model recognized abnormal yellowing, reduced growth, or distorted plant tissue associated with phytoplasma symptoms.';
  }
  if (normalizedLabel.contains('white_flies')) {
    return 'The model recognized pale or yellowed leaf damage consistent with sap-feeding whitefly activity.';
  }
  if (normalizedLabel.contains('insect_pest')) {
    return 'The model recognized chewing, scarring, holes, or other visible patterns consistent with insect feeding.';
  }
  if (normalizedLabel.contains('downy_mildew')) {
    return 'The model recognized yellowed leaf patches and mildew-like damage consistent with downy mildew.';
  }
  if (normalizedLabel.contains('powdery_mildew')) {
    return 'The model recognized pale, powdery-looking patches or surface discoloration consistent with powdery mildew.';
  }
  if (normalizedLabel.contains('early_blight')) {
    return 'The model recognized brown leaf spots, often with yellowing or ring-like patterns, consistent with early blight.';
  }
  if (normalizedLabel.endsWith('_wilt')) {
    return 'The model recognized yellowing, drooping, or wilt-like damage associated with a wilt condition.';
  }
  if (normalizedLabel.endsWith('_fungal')) {
    return 'The model recognized damaged or discolored tissue associated with a possible fungal condition.';
  }
  if (normalizedLabel.contains('leaf_spot') ||
      normalizedLabel.contains('dark_spot')) {
    return 'The model recognized dark or discolored leaf spots consistent with a leaf-spot condition.';
  }
  if (normalizedLabel.contains('bacterial')) {
    return 'The model recognized damaged or discolored leaf tissue consistent with a possible bacterial condition.';
  }
  return 'The model recognized visible abnormality patterns consistent with ${rawLabel.split('_').skip(1).join(' ')}.';
}
