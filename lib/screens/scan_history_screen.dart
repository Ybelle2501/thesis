import 'dart:io';

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/classifier.dart';
import '../services/scan_history_database.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'result_screen.dart';
import 'scanner_screen.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  static const _filters = ['All', 'Infected', 'Healthy'];

  final Set<int> _selectedIds = {};
  List<ScanData> _scans = const [];
  String _filter = 'All';
  bool _loading = true;
  bool _selectionMode = false;
  bool _deleting = false;
  String? _loadError;

  List<ScanData> get _filtered => _filter == 'All'
      ? _scans
      : _scans.where((scan) => scan.status == _filter).toList();

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  Future<void> _loadScans() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final scans = await ScanHistoryDatabase.instance.getScans();
      if (!mounted) return;
      setState(() {
        _scans = scans;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final infected = _scans.where((s) => s.status == 'Infected').length;
    final healthy = _scans.where((s) => s.status == 'Healthy').length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStats(infected, healthy),
            _buildFilters(),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectionMode) _buildSelectionBar(),
          const AppBottomNav(currentIndex: 2),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          CircleButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(_selectionMode ? 'Select records' : 'History'),
                const SizedBox(height: 2),
                Text(
                  _selectionMode
                      ? '${_selectedIds.length} selected'
                      : 'Scan Records',
                  style: AppTextStyles.titleLarge,
                ),
              ],
            ),
          ),
          if (_scans.isNotEmpty)
            Tooltip(
              message: _selectionMode ? 'Cancel selection' : 'Select records',
              child: CircleButton(
                icon: _selectionMode
                    ? Icons.close_rounded
                    : Icons.checklist_rounded,
                onTap: () => setState(() {
                  _selectionMode = !_selectionMode;
                  _selectedIds.clear();
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStats(int infected, int healthy) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _StatChip(
            label: 'Total',
            value: _scans.length,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          _StatChip(label: 'Infected', value: infected, color: AppColors.error),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Healthy',
            value: healthy,
            color: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: _filters.map((filter) {
          final active = _filter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() {
                _filter = filter;
                _selectedIds.clear();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Text(
                  filter,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 13,
                    color: active ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return _HistoryMessage(
        icon: Icons.storage_rounded,
        title: 'History could not be loaded',
        message: 'Check the app storage and try again.',
        actionLabel: 'Retry',
        onAction: _loadScans,
      );
    }
    if (_scans.isEmpty) {
      return _HistoryMessage(
        icon: Icons.history_rounded,
        title: 'No scans yet',
        message: 'Your successful camera and gallery scans will appear here.',
        actionLabel: 'Start a scan',
        onAction: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CropScannerScreen()),
          );
          await _loadScans();
        },
      );
    }

    final scans = _filtered;
    if (scans.isEmpty) {
      return _HistoryMessage(
        icon: Icons.filter_alt_off_rounded,
        title: 'No $_filter scans',
        message: 'Choose another category to view saved records.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadScans,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: scans.length,
        itemBuilder: (_, index) {
          final scan = scans[index];
          final firstInGroup =
              index == 0 ||
              dateGroupLabel(scans[index - 1].capturedAt) !=
                  dateGroupLabel(scan.capturedAt);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (firstInGroup) ...[
                if (index != 0) const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: SectionLabel(dateGroupLabel(scan.capturedAt)),
                ),
              ],
              _HistoryCard(
                scan: scan,
                selectionMode: _selectionMode,
                selected: scan.id != null && _selectedIds.contains(scan.id),
                onTap: () =>
                    _selectionMode ? _toggleSelected(scan) : _openScan(scan),
                onLongPress: () {
                  if (!_selectionMode) setState(() => _selectionMode = true);
                  _toggleSelected(scan);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectionBar() {
    final visibleIds = _filtered
        .map((scan) => scan.id)
        .whereType<int>()
        .toSet();
    final allSelected =
        visibleIds.isNotEmpty && _selectedIds.containsAll(visibleIds);
    return Material(
      color: AppColors.card,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Row(
          children: [
            TextButton.icon(
              onPressed: () => setState(() {
                allSelected
                    ? _selectedIds.removeAll(visibleIds)
                    : _selectedIds.addAll(visibleIds);
              }),
              icon: Icon(
                allSelected ? Icons.deselect_rounded : Icons.select_all_rounded,
              ),
              label: Text(allSelected ? 'Deselect all' : 'Select all'),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _selectedIds.isEmpty || _deleting
                  ? null
                  : _confirmDelete,
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              icon: _deleting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text('Delete (${_selectedIds.length})'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSelected(ScanData scan) {
    final id = scan.id;
    if (id == null) return;
    setState(() {
      if (!_selectedIds.add(id)) _selectedIds.remove(id);
    });
  }

  void _openScan(ScanData scan) {
    final result = ClassificationResult(
      rawLabel: scan.rawLabel,
      confidence: scan.confidence,
      classIndex: scan.classIndex,
      status: ScanStatus.success,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiseaseResultScreen(
          capturedImagePath: File(scan.imagePath).existsSync()
              ? scan.imagePath
              : null,
          result: result,
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $count ${count == 1 ? 'record' : 'records'}?'),
        content: const Text(
          'The selected scan data and saved photos will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final ids = Set<int>.from(_selectedIds);
    setState(() => _deleting = true);
    try {
      await ScanHistoryDatabase.instance.deleteScans(ids);
      if (!mounted) return;
      setState(() {
        _scans = _scans.where((scan) => !ids.contains(scan.id)).toList();
        _selectedIds.clear();
        _selectionMode = false;
        _deleting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count ${count == 1 ? 'record' : 'records'} deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete the selected records.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              '$value',
              style: AppTextStyles.displayMedium.copyWith(
                color: color,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.scan,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final ScanData scan;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final healthy = scan.status == 'Healthy';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        onLongPress: onLongPress,
        color: selected ? AppColors.accent : null,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _Thumbnail(scan: scan, healthy: healthy),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scan.plant, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    scan.disease,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    scan.contextLabel,
                    style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: scan.confidence,
                            minHeight: 4,
                            backgroundColor: AppColors.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              healthy
                                  ? AppColors.primaryLight
                                  : AppColors.error,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(scan.confidence * 100).round()}%',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeLabel(scan.capturedAt),
                  style: AppTextStyles.labelSmall,
                ),
                const SizedBox(height: 10),
                Icon(
                  selectionMode
                      ? selected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded
                      : Icons.chevron_right_rounded,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                  size: selectionMode ? 22 : 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.scan, required this.healthy});

  final ScanData scan;
  final bool healthy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(scan.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: healthy
                      ? const Color(0xFFD8F3DC)
                      : const Color(0xFFFDEAE4),
                  child: Icon(
                    Icons.eco_rounded,
                    color: healthy ? AppColors.primary : AppColors.error,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: healthy ? AppColors.primaryLight : AppColors.error,
              ),
              child: Icon(
                healthy ? Icons.check_rounded : Icons.close_rounded,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(title, style: AppTextStyles.titleLarge),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
