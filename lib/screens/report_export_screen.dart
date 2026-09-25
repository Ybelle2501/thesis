import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../services/pdf_report_service.dart';
import '../theme/app_theme.dart';
import '../widgets/location_tag_dialog.dart';
import '../widgets/shared_widgets.dart';

class ReportExportScreen extends StatefulWidget {
  const ReportExportScreen({super.key, required this.scans});

  final List<ScanData> scans;

  @override
  State<ReportExportScreen> createState() => _ReportExportScreenState();
}

class _ReportExportScreenState extends State<ReportExportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _nameController = TextEditingController();
  bool _exporting = false;
  String? _locationError;

  List<String> get _locations {
    final byKey = <String, String>{};
    for (final scan in widget.scans) {
      final value = normalizeLocationTag(scan.location);
      if (value.isNotEmpty) byKey.putIfAbsent(value.toLowerCase(), () => value);
    }
    final values = byKey.values.toList()..sort();
    return values;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    setState(() => _locationError = null);
    if (!_formKey.currentState!.validate()) return;

    final requested = normalizeLocationTag(_locationController.text);
    final matching = widget.scans
        .where((scan) => locationTagsMatch(scan.location, requested))
        .toList(growable: false);
    if (matching.isEmpty) {
      setState(() {
        _locationError =
            'No scans match this location. Check the tag and try again.';
      });
      return;
    }

    setState(() => _exporting = true);
    try {
      final canonicalLocation = matching.first.location;
      final filename = await PapusoyReportService.export(
        scans: matching,
        location: canonicalLocation,
        scoutedBy: _nameController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$filename is ready to save or share.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not export the PDF: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Export Scouting Report'),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/papusoy_logo.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Image.asset(
                        'assets/leaflens_logo.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Papusoy Hydrofarm',
                      style: AppTextStyles.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const SectionLabel('PDF report'),
              const SizedBox(height: 6),
              const Text(
                'Create a Papusoy Hydrofarm report from every scan tagged with one location.',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _locationController,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Crop location',
                  hintText: 'Example: Greenhouse 1',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  errorText: _locationError,
                ),
                onChanged: (_) {
                  if (_locationError != null) {
                    setState(() => _locationError = null);
                  }
                },
                validator: (value) {
                  final normalized = normalizeLocationTag(value ?? '');
                  if (normalized.isEmpty) return 'Enter a crop location.';
                  if (!locationTagPattern.hasMatch(normalized)) {
                    return 'Use letters, numbers, and spaces only.';
                  }
                  return null;
                },
              ),
              if (_locations.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Known locations', style: AppTextStyles.labelSmall),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _locations
                      .map(
                        (location) => ActionChip(
                          label: Text(location),
                          onPressed: () {
                            _locationController.text = location;
                            setState(() => _locationError = null);
                          },
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Scout name',
                  hintText: 'Name shown as Scouted by',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the scout name.'
                    : null,
              ),
              const SizedBox(height: 22),
              AppButton(
                label: _exporting ? 'Creating PDF...' : 'Export PDF',
                icon: Icons.picture_as_pdf_rounded,
                onPressed: _exporting ? null : _export,
              ),
              const SizedBox(height: 12),
              Text(
                'The scouting date is set when you export. The default file name increments automatically.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'On Android, the export opens the system share sheet. Choose Save to Files, then Downloads, to keep a local copy.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
