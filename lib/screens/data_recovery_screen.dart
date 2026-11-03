import 'package:flutter/material.dart' hide Text;
import '../l10n/localized_text.dart';

import '../services/data_backup_service.dart';
import '../theme/app_theme.dart';

class DataRecoveryScreen extends StatefulWidget {
  const DataRecoveryScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<DataRecoveryScreen> createState() => _DataRecoveryScreenState();
}

class _DataRecoveryScreenState extends State<DataRecoveryScreen> {
  bool _working = false;

  Future<void> _exportBackup() async {
    setState(() => _working = true);
    try {
      final path = await DataBackupService.exportToDownloads();
      if (mounted) _showMessage('Backup saved to $path');
    } catch (error) {
      if (mounted) _showMessage('Could not save backup: $error');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _importBackup() async {
    setState(() => _working = true);
    try {
      final backup = await DataBackupService.pickBackup();
      if (backup == null || !mounted) return;

      final shouldRestore = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore LeafLens data?'),
          content: Text(
            'Restoring ${backup.name} will replace the scan history and report '
            'settings currently on this device. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restore'),
            ),
          ],
        ),
      );
      if (shouldRestore != true || !mounted) return;

      await DataBackupService.restoreBackup(backup.bytes);
      if (mounted) _showMessage('Backup restored. Your history is up to date.');
    } catch (error) {
      if (mounted) _showMessage('Could not restore backup: $error');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const Text(
            'Back up your scan history',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'LeafLens saves scans on this device. Export a backup to '
            'Downloads/LeafLens Data so you can restore your records later.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          _RecoveryActionCard(
            icon: Icons.save_alt_rounded,
            title: 'Save current data',
            description:
                'Create or replace ${DataBackupService.backupFileName} in '
                'Downloads/${DataBackupService.backupFolderName}.',
            buttonLabel: 'Export backup',
            onPressed: _working ? null : _exportBackup,
          ),
          const SizedBox(height: 14),
          _RecoveryActionCard(
            icon: Icons.settings_backup_restore_rounded,
            title: 'Restore from backup',
            description:
                'Choose a LeafLens backup file to restore scan history, '
                'dates, saved images, and report settings.',
            buttonLabel: 'Import backup',
            outlined: true,
            onPressed: _working ? null : _importBackup,
          ),
          if (_working) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
    if (!widget.showAppBar) return content;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Data Recovery'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: content,
    );
  }
}

class _RecoveryActionCard extends StatelessWidget {
  const _RecoveryActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    this.outlined = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE1EAE3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(height: 6),
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: outlined
                  ? OutlinedButton(
                      onPressed: onPressed,
                      child: Text(buttonLabel),
                    )
                  : FilledButton(
                      onPressed: onPressed,
                      child: Text(buttonLabel),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
