import 'dart:io';

import 'package:flutter/material.dart' hide Text;

import '../l10n/localized_text.dart';
import '../models/models.dart';
import '../services/classifier.dart';
import '../services/scan_history_database.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'result_screen.dart';
import 'scanner_screen.dart';

class PlantMonitoringScreen extends StatefulWidget {
  const PlantMonitoringScreen({super.key, required this.scan, this.database});

  final ScanData scan;
  final ScanHistoryDatabase? database;

  @override
  State<PlantMonitoringScreen> createState() => _PlantMonitoringScreenState();
}

class _PlantMonitoringScreenState extends State<PlantMonitoringScreen> {
  ScanHistoryDatabase get _database =>
      widget.database ?? ScanHistoryDatabase.instance;
  List<ScanData> _scans = const [];
  bool _loading = true;
  bool _scanning = false;
  bool _editing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final scans = await _database.getPlantScans(widget.scan.monitoringId);
      if (!mounted) return;
      setState(() {
        _scans = scans;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load plant monitoring. Please try again.';
      });
    }
  }

  Future<void> _scanAgain() async {
    if (_scanning || _scans.isEmpty) return;
    setState(() => _scanning = true);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CropScannerScreen(
          monitoringScan: _scans.first,
          historyDatabase: _database,
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _scanning = false);
    await _load();
  }

  Future<void> _editNotes(ScanData scan) async {
    if (_editing || scan.id == null) return;
    setState(() => _editing = true);
    final notes = await showDialog<String>(
      context: context,
      builder: (_) => _CareNotesDialog(scan: scan),
    );
    if (!mounted) return;
    if (notes != null) {
      try {
        await _database.updateCareNotes(scan.id!, notes);
        await _load();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not save care notes. Please try again.'),
            ),
          );
        }
      }
    }
    if (mounted) setState(() => _editing = false);
  }

  Future<void> _viewScan(ScanData scan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiseaseResultScreen(
          capturedImagePath: File(scan.imagePath).existsSync()
              ? scan.imagePath
              : null,
          result: ClassificationResult(
            rawLabel: scan.rawLabel,
            confidence: scan.confidence,
            classIndex: scan.classIndex,
            status: ScanStatus.success,
          ),
          alreadySaved: true,
          savedScan: scan,
          historyDatabase: _database,
          existingLocation: scan.location,
          historySource: scan.source,
          scanMode: scan.scanMode,
        ),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    appBar: AppBar(
      title: const Text('Plant Monitoring'),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: AppButton(
          label: 'Scan Again to Update',
          icon: Icons.document_scanner_outlined,
          onPressed: _loading || _scanning || _error != null || _scans.isEmpty
              ? null
              : _scanAgain,
        ),
      ),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            ),
          )
        : _scans.isEmpty
        ? const Center(child: Text('No saved scans remain for this plant.'))
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                _summary(),
                const SizedBox(height: 20),
                const SectionLabel('Scan Timeline'),
                const SizedBox(height: 8),
                const Text(
                  'Newest scans appear first. Rescan the same plant after care to follow its condition.',
                ),
                const SizedBox(height: 14),
                for (var index = 0; index < _scans.length; index++)
                  _timelineEntry(_scans[index], index),
                const AiDisclaimer(useSafeArea: false),
              ],
            ),
          ),
  );

  Widget _summary() {
    final latest = _scans.first;
    final healthy = latest.status == 'Healthy';
    final previous = _scans.length > 1 ? _scans[1] : null;
    final comparison = previous == null
        ? 'First scan recorded. Add care notes and scan again to track changes.'
        : healthy
        ? (previous.status == 'Healthy'
              ? 'Still classified as healthy.'
              : 'Now classified as healthy after an infected scan.')
        : (previous.status == 'Healthy'
              ? 'An infection was detected after a healthy scan.'
              : 'Still classified as infected. Review the latest result and care advice.');
    return AppCard(
      color: healthy ? AppColors.accent : const Color(0xFFFDEAE4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(latest.plant, style: AppTextStyles.displayMedium),
          Text(
            'Plant record: ${latest.monitoringId}',
            style: AppTextStyles.bodyMedium,
          ),
          if (latest.location.isNotEmpty)
            Text(latest.location, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 12),
          const SectionLabel('Latest Status'),
          Text(
            latest.status,
            style: AppTextStyles.titleLarge.copyWith(
              color: healthy ? AppColors.primary : AppColors.error,
            ),
          ),
          Text(latest.disease, style: AppTextStyles.titleMedium),
          Text(latest.date, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 12),
          Text(
            'Saved scans: ${_scans.length}',
            style: AppTextStyles.bodyMedium,
          ),
          Text(comparison, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          const Text(
            'Scan results show changes in classification; they do not confirm that a treatment caused recovery.',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _timelineEntry(ScanData scan, int index) {
    final healthy = scan.status == 'Healthy';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(scan.imagePath),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 64,
                      height: 64,
                      child: Icon(
                        Icons.eco_outlined,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        index == 0 ? 'Latest Scan' : 'Earlier Scan',
                        style: AppTextStyles.labelSmall,
                      ),
                      Text(
                        scan.status,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: healthy ? AppColors.primary : AppColors.error,
                        ),
                      ),
                      Text(scan.disease, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(scan.date, style: AppTextStyles.bodyMedium),
            Text(
              '${(scan.confidence * 100).toStringAsFixed(1)}% confidence',
              style: AppTextStyles.bodyMedium,
            ),
            const Divider(height: 24, color: AppColors.divider),
            const Text(
              'Care after this scan',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              scan.careNotes.isEmpty
                  ? 'No treatment or prevention notes yet.'
                  : scan.careNotes,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: _editing ? null : () => _editNotes(scan),
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: Text(
                    scan.careNotes.isEmpty
                        ? 'Add Care Notes'
                        : 'Edit Care Notes',
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _viewScan(scan),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('View Scan Result'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CareNotesDialog extends StatefulWidget {
  const _CareNotesDialog({required this.scan});
  final ScanData scan;

  @override
  State<_CareNotesDialog> createState() => _CareNotesDialogState();
}

class _CareNotesDialogState extends State<_CareNotesDialog> {
  late final _controller = TextEditingController(text: widget.scan.careNotes);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Treatment & Prevention Notes'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.scan.date, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 12),
          const Text(
            'Record care applied after this scan, including the date.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 6,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText: localizeCopy(
                context,
                'Treatment, prevention, and observations',
              ),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, _controller.text.trim()),
        child: const Text('Save Notes'),
      ),
    ],
  );
}
