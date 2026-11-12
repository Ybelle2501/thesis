import 'package:flutter/material.dart' hide Text;

import '../l10n/app_language.dart';
import '../l10n/localized_text.dart';
import '../theme/app_theme.dart';
import '../services/farm_location_store.dart';
import '../widgets/location_tag_dialog.dart';
import 'data_recovery_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primary,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(child: Text('Language')),
              Tab(child: Text('Farm Locations')),
              Tab(child: Text('Data Recovery')),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LanguageTab(),
            _FarmLocationsTab(),
            DataRecoveryScreen(showAppBar: false),
          ],
        ),
      ),
    );
  }
}

class _FarmLocationsTab extends StatefulWidget {
  const _FarmLocationsTab();

  @override
  State<_FarmLocationsTab> createState() => _FarmLocationsTabState();
}

class _FarmLocationsTabState extends State<_FarmLocationsTab> {
  List<String> _locations = const [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await FarmLocationStore.instance.getLocations();
      if (!mounted) return;
      setState(() {
        _locations = locations;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  Future<void> _addLocation() async {
    final value = await showLocationTagDialog(
      context,
      title: 'Add farm location',
      description: 'Add a location to the list used when saving scans.',
      actionLabel: 'Add location',
    );
    if (value == null) return;
    try {
      final locations = await FarmLocationStore.instance.addLocation(value);
      if (mounted) setState(() => _locations = locations);
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _editLocation(String location) async {
    final value = await showLocationTagDialog(
      context,
      initialLocation: location,
      title: 'Edit farm location',
      description: 'Change the name shown in the scan location list.',
      actionLabel: 'Save changes',
      selectAllOnOpen: true,
    );
    if (value == null) return;
    try {
      final locations = await FarmLocationStore.instance.renameLocation(
        location,
        value,
      );
      if (mounted) setState(() => _locations = locations);
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _deleteLocation(String location) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete farm location?'),
        content: Text(
          'Remove "$location" from the selectable location list? Existing scan records will keep their saved location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final locations = await FarmLocationStore.instance.deleteLocation(
        location,
      );
      if (mounted) setState(() => _locations = locations);
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not update locations: $error')),
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
    children: [
      const Text('Farm Locations', style: AppTextStyles.titleLarge),
      const SizedBox(height: 8),
      const Text(
        'Save common locations such as G1 or Greenhouse 2 to select them when recording a scan. Renaming or deleting a saved choice does not alter existing scan records.',
        style: AppTextStyles.bodyMedium,
      ),
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(
          onPressed: _addLocation,
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Add location'),
        ),
      ),
      const SizedBox(height: 12),
      if (_loading)
        const Center(child: CircularProgressIndicator())
      else if (_error != null)
        Text('Could not load locations: $_error')
      else if (_locations.isEmpty)
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('No saved farm locations yet.'),
          ),
        )
      else
        Card(
          child: Column(
            children: [
              for (var index = 0; index < _locations.length; index++) ...[
                if (index > 0) const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(_locations[index]),
                  trailing: Wrap(
                    spacing: 2,
                    children: [
                      IconButton(
                        tooltip: 'Edit location',
                        onPressed: () => _editLocation(_locations[index]),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete location',
                        onPressed: () => _deleteLocation(_locations[index]),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
    ],
  );
}

class _LanguageTab extends StatelessWidget {
  const _LanguageTab();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguage.locale,
      builder: (context, locale, _) {
        final selected = locale.languageCode;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            const Text(
              'Choose your preferred language',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your choice applies throughout LeafLens and is saved on this device.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE1EAE3)),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'en',
                    groupValue: selected,
                    title: const Text('English'),
                    onChanged: (value) => _changeLanguage(value),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  RadioListTile<String>(
                    value: 'tl',
                    groupValue: selected,
                    title: const Text('Tagalog'),
                    onChanged: (value) => _changeLanguage(value),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeLanguage(String? code) async {
    if (code == null) return;
    await AppLanguage.setLanguage(Locale(code));
  }
}
