import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/location_tag_dialog.dart';
import '../services/classifier.dart';
import '../services/scan_history_database.dart';
import 'treatment_screen.dart';
import 'disease_prevention_screen.dart';
import '../data/crop_guides.dart';
import 'scanner_screen.dart';

// ─── DISEASE RESULT SCREEN ────────────────────────────────────────────────────

class DiseaseResultScreen extends StatelessWidget {
  final String? capturedImagePath;
  final ClassificationResult? result;
  final String historySource;
  final String scanMode;
  final bool alreadySaved;
  final String existingLocation;

  const DiseaseResultScreen({
    super.key,
    this.capturedImagePath,
    this.result,
    this.historySource = 'Camera',
    this.scanMode = 'Single',
    this.alreadySaved = false,
    this.existingLocation = '',
  });

  @override
  Widget build(BuildContext context) {
    if (result != null) {
      switch (result!.status) {
        case ScanStatus.noLeafDetected:
          return _NoLeafView(imagePath: capturedImagePath);

        case ScanStatus.lowConfidence:
          return _LowConfidenceView(
            imagePath: capturedImagePath,
            result: result!,
            historySource: historySource,
            scanMode: scanMode,
          );

        case ScanStatus.success:
          return _SuccessView(
            imagePath: capturedImagePath,
            result: result!,
            historySource: historySource,
            scanMode: scanMode,
            alreadySaved: alreadySaved,
            existingLocation: existingLocation,
          );
      }
    }
    return _FallbackView(imagePath: capturedImagePath);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATE 1 — NO LEAF DETECTED
// ═══════════════════════════════════════════════════════════════════════════════

class _NoLeafView extends StatelessWidget {
  final String? imagePath;
  const _NoLeafView({this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: const AiDisclaimer(),
      body: SafeArea(
        child: Column(
          children: [
            _BackHeader(title: 'Scan Result'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Scanned photo (dimmed)
                    if (imagePath != null) ...[
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                0.33,
                                0.33,
                                0.33,
                                0,
                                0,
                                0.33,
                                0.33,
                                0.33,
                                0,
                                0,
                                0.33,
                                0.33,
                                0.33,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ]),
                              child: Image.file(
                                File(imagePath!),
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Overlay icon
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.hide_image_rounded,
                                  color: Colors.white60,
                                  size: 52,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Icon
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.eco_outlined,
                        color: AppColors.warning,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'No Plant Leaf Detected',
                      style: AppTextStyles.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      'The image doesn\'t appear to contain a recognizable plant leaf. '
                      'Please make sure a leaf is clearly visible and well-lit.',
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Tips card
                    AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '  Tips for a better scan',
                            style: AppTextStyles.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _TipRow(
                            icon: Icons.wb_sunny_rounded,
                            text: 'Use good natural lighting',
                          ),
                          _TipRow(
                            icon: Icons.center_focus_strong_rounded,
                            text: 'Place the leaf in the center of the frame',
                          ),
                          _TipRow(
                            icon: Icons.close_fullscreen_rounded,
                            text:
                                'Get close enough — fill the frame with the leaf',
                          ),
                          _TipRow(
                            icon: Icons.blur_off_rounded,
                            text: 'Keep the camera steady to avoid blur',
                          ),
                          _TipRow(
                            icon: Icons.eco_rounded,
                            text:
                                'Scan only supported crops (banana, eggplant, lettuce, or tomato)',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Rescan button
                    AppButton(
                      label: 'Try Again',
                      icon: Icons.camera_alt_rounded,
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CropScannerScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Go Back',
                      icon: Icons.arrow_back_rounded,
                      outlined: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATE 2 — RESULT DID NOT PASS THE DEPLOYMENT DECISION RULE
// ═══════════════════════════════════════════════════════════════════════════════

class _LowConfidenceView extends StatelessWidget {
  final String? imagePath;
  final ClassificationResult result;
  final String historySource;
  final String scanMode;

  const _LowConfidenceView({
    required this.imagePath,
    required this.result,
    required this.historySource,
    required this.scanMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: const AiDisclaimer(),
      body: SafeArea(
        child: Column(
          children: [
            _BackHeader(title: 'Scan Result'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Photo
                    if (imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(imagePath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Warning banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.warning,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Uncertain Result',
                                  style: AppTextStyles.titleMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Confidence is only ${result.confidencePercent}. '
                                  'The result below may not be accurate.',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Partial result card (shown greyed out)
                    AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Best Guess',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            result.plantName,
                            style: AppTextStyles.displayMedium.copyWith(
                              fontSize: 20,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            result.conditionName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Confidence bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: result.confidence,
                              minHeight: 10,
                              backgroundColor: AppColors.divider,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.warning,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              result.confidencePercent,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (result.suggestedDiseases.isNotEmpty) ...[
                      _DiseaseSuggestionsCard(
                        suggestions: result.suggestedDiseases,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tips card
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '  Improve your scan',
                            style: AppTextStyles.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          _TipRow(
                            icon: Icons.wb_sunny_rounded,
                            text: 'Ensure the leaf is well-lit',
                          ),
                          _TipRow(
                            icon: Icons.center_focus_strong_rounded,
                            text: 'Fill the frame with just the leaf',
                          ),
                          _TipRow(
                            icon: Icons.blur_off_rounded,
                            text: 'Hold steady — avoid motion blur',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary: rescan
                    AppButton(
                      label: 'Rescan for Better Result',
                      icon: Icons.camera_alt_rounded,
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CropScannerScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Secondary: trust the guess anyway
                    AppButton(
                      label: 'Use This Result Anyway',
                      icon: Icons.check_rounded,
                      outlined: true,
                      onPressed: () {
                        final acceptedResult = ClassificationResult(
                          rawLabel: result.rawLabel,
                          confidence: result.confidence,
                          classIndex: result.classIndex,
                          status: ScanStatus.success,
                          rankedPredictions: result.rankedPredictions,
                          suggestedDiseases: result.suggestedDiseases,
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DiseaseResultScreen(
                              capturedImagePath: imagePath,
                              result: acceptedResult,
                              historySource: historySource,
                              scanMode: scanMode,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATE 3 — RESULT PASSED THE DEPLOYMENT DECISION RULE
// ═══════════════════════════════════════════════════════════════════════════════

class _SuccessView extends StatefulWidget {
  final String? imagePath;
  final ClassificationResult result;
  final String historySource;
  final String scanMode;
  final bool alreadySaved;
  final String existingLocation;

  const _SuccessView({
    required this.imagePath,
    required this.result,
    required this.historySource,
    required this.scanMode,
    required this.alreadySaved,
    required this.existingLocation,
  });

  @override
  State<_SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<_SuccessView> {
  late final TextEditingController _locationController;
  late bool _saved;
  bool _saving = false;
  String? _locationError;
  String? _savedImagePath;

  ClassificationResult get result => widget.result;
  String? get imagePath => _savedImagePath ?? widget.imagePath;

  @override
  void initState() {
    super.initState();
    _saved = widget.alreadySaved;
    _locationController = TextEditingController(text: widget.existingLocation);
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveToHistory() async {
    final location = normalizeLocationTag(_locationController.text);
    if (location.isEmpty || !locationTagPattern.hasMatch(location)) {
      setState(() {
        _locationError = location.isEmpty
            ? 'Enter the crop location.'
            : 'Use letters, numbers, and spaces only.';
      });
      return;
    }
    final path = imagePath;
    if (path == null) {
      setState(() => _locationError = 'The scan image is no longer available.');
      return;
    }

    setState(() {
      _saving = true;
      _locationError = null;
    });
    try {
      final scan = await ScanHistoryDatabase.instance.saveSuccessfulScan(
        sourceImagePath: path,
        result: result,
        source: widget.historySource,
        scanMode: widget.scanMode,
        location: location,
      );
      if (!mounted) return;
      setState(() {
        _saved = true;
        _saving = false;
        _savedImagePath = scan.imagePath;
        _locationController.text = location;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan and location saved to history.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _locationError = 'Could not save this scan. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isHealthy = result.isHealthy;
    final bool hasDetailedGuidance = guideForLabel(result.rawLabel) != null;
    final Color statusColor = isHealthy ? AppColors.primary : AppColors.error;
    final Color statusBg = isHealthy
        ? AppColors.accent
        : const Color(0xFFFDEAE4);

    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: const AiDisclaimer(),
      body: SafeArea(
        child: Column(
          children: [
            _BackHeader(title: 'Scan Result'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Photo ─────────────────────────────────────────────
                    if (imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(imagePath!),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Status pill ───────────────────────────────────────
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isHealthy
                                  ? Icons.check_circle_rounded
                                  : Icons.warning_amber_rounded,
                              color: statusColor,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isHealthy
                                  ? 'Plant is Healthy'
                                  : 'Disease Detected',
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Main result card ──────────────────────────────────
                    AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Plant
                          _ResultRow(
                            iconBg: AppColors.accent,
                            icon: Icons.eco_rounded,
                            iconColor: AppColors.primary,
                            label: 'Plant',
                            value: result.plantName,
                            valueColor: AppColors.textPrimary,
                          ),
                          const Divider(height: 24, color: AppColors.divider),
                          // Condition
                          _ResultRow(
                            iconBg: statusBg,
                            icon: Icons.biotech_rounded,
                            iconColor: statusColor,
                            label: 'Condition',
                            value: result.conditionName,
                            valueColor: statusColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    AppCard(
                      padding: const EdgeInsets.all(18),
                      color: _saved ? AppColors.accent : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _saved
                                    ? Icons.check_circle_rounded
                                    : Icons.location_on_outlined,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _saved
                                      ? 'Crop location saved'
                                      : 'Tag this crop location',
                                  style: AppTextStyles.titleMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _saved
                                ? 'This scan is included under this location in Reports.'
                                : 'Enter the location before leaving this result so it can be included in a scouting report.',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _locationController,
                            enabled: !_saved && !_saving,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            maxLength: 50,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Za-z0-9 ]'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Crop location',
                              hintText: 'Example: Greenhouse 1',
                              errorText: _locationError,
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                              ),
                            ),
                            onChanged: (_) {
                              if (_locationError != null) {
                                setState(() => _locationError = null);
                              }
                            },
                            onSubmitted: _saved || _saving
                                ? null
                                : (_) => _saveToHistory(),
                          ),
                          if (!_saved) ...[
                            const SizedBox(height: 10),
                            AppButton(
                              label: _saving
                                  ? 'Saving scan...'
                                  : 'Save Scan & Location',
                              icon: Icons.save_alt_rounded,
                              onPressed: _saving ? null : _saveToHistory,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (result.suggestedDiseases.isNotEmpty) ...[
                      _DiseaseSuggestionsCard(
                        suggestions: result.suggestedDiseases,
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ── Confidence card ───────────────────────────────────
                    AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.analytics_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Confidence Score',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                result.confidencePercent,
                                style: AppTextStyles.displayMedium.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: result.confidence,
                              minHeight: 12,
                              backgroundColor: AppColors.divider,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                result.confidence >= 0.8
                                    ? AppColors.primaryLight
                                    : AppColors.warning,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              result.confidence >= 0.8
                                  ? ' High confidence — result is reliable'
                                  : ' Moderate confidence — result is likely correct',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Debug card ────────────────────────────────────────
                    AppCard(
                      color: const Color(0xFFF0F4F0),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            ' Debug Info',
                            style: AppTextStyles.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _DebugRow('Raw label', result.rawLabel),
                          _DebugRow('Class index', '${result.classIndex}'),
                          _DebugRow(
                            'Input size',
                            '${PlantDiseaseClassifier.inputSize} × '
                                '${PlantDiseaseClassifier.inputSize} px',
                          ),
                          _DebugRow('Model', PlantDiseaseClassifier.modelName),
                          _DebugRow(
                            'Raw score',
                            result.confidence.toStringAsFixed(6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Action buttons ────────────────────────────────────
                    if (!isHealthy && hasDetailedGuidance) ...[
                      AppButton(
                        label: 'View Treatment Advice',
                        icon: Icons.medical_services_rounded,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TreatmentScreen(initialLabel: result.rawLabel),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      AppButton(
                        label: 'Disease Prevention',
                        icon: Icons.info_rounded,
                        outlined: true,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DiseasePreventionScreen(
                              initialLabel: result.rawLabel,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (!isHealthy && !hasDetailedGuidance) ...[
                      AppCard(
                        color: const Color(0xFFFFF4E5),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Detailed treatment guidance for '
                          '${result.conditionName} is not yet included. '
                          'Confirm this result with a qualified crop '
                          'specialist before applying treatment.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AppButton(
                        label: 'Scan Another Plant',
                        icon: Icons.camera_alt_rounded,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                    if (isHealthy)
                      AppButton(
                        label: 'Scan Another Plant',
                        icon: Icons.camera_alt_rounded,
                        onPressed: () => Navigator.pop(context),
                      ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FALLBACK VIEW — navigated directly from dashboard, no AI result
// ═══════════════════════════════════════════════════════════════════════════════

class _FallbackView extends StatelessWidget {
  final String? imagePath;
  const _FallbackView({this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: const AiDisclaimer(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: imagePath != null
                        ? Image.file(File(imagePath!), fit: BoxFit.cover)
                        : Image.network(
                            'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=600',
                            fit: BoxFit.cover,
                          ),
                  ),
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, AppColors.surface],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircleButton(
                      icon: Icons.arrow_back_ios_rounded,
                      dark: true,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tomato — Early Blight',
                      style: AppTextStyles.displayMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Demo — scan a plant to get real output',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ConfidenceCard(confidence: 0.94),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'View Treatment Advice',
                      icon: Icons.medical_services_rounded,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TreatmentScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Disease Prevention',
                      icon: Icons.info_rounded,
                      outlined: true,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DiseasePreventionScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SHARED SMALL WIDGETS ─────────────────────────────────────────────────────

class _BackHeader extends StatelessWidget {
  final String title;
  const _BackHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          CircleButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Text(title, style: AppTextStyles.titleLarge),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final Color iconBg, iconColor, valueColor;
  final IconData icon;
  final String label, value;

  const _ResultRow({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.displayMedium.copyWith(
                  color: valueColor,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

class _DebugRow extends StatelessWidget {
  final String label, value;
  const _DebugRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:  ',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CONFIDENCE CARD (reusable) ───────────────────────────────────────────────

class _DiseaseSuggestionsCard extends StatelessWidget {
  const _DiseaseSuggestionsCard({required this.suggestions});

  final List<RankedPrediction> suggestions;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: const Color(0xFFFFF8E1),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.compare_arrows_rounded,
                color: AppColors.warning,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Other Possible Diseases',
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'These similar conditions are for the same crop and passed the '
            'comparison threshold. Compare visible symptoms before choosing '
            'a treatment.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 12),
          ...suggestions.asMap().entries.map((entry) {
            final prediction = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == suggestions.length - 1 ? 0 : 10,
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${entry.key + 1}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      prediction.conditionName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    prediction.confidencePercent,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class ConfidenceCard extends StatelessWidget {
  final double confidence;
  const ConfidenceCard({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Detection Confidence',
                style: AppTextStyles.titleMedium,
              ),
              const Spacer(),
              Text(
                '${(confidence * 100).toInt()}%',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 10,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                confidence > 0.8 ? AppColors.primaryLight : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── RESULT INFO CHIP ─────────────────────────────────────────────────────────

class ResultInfoChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const ResultInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.titleMedium.copyWith(fontSize: 12)),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
