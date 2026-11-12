import 'dart:convert';

import 'scan_history_database.dart';

class FarmLocationStore {
  FarmLocationStore._();

  static final instance = FarmLocationStore._();
  static const _settingKey = 'farm_location_options_v1';
  static final _validLocation = RegExp(r'^[A-Za-z0-9]+(?: [A-Za-z0-9]+)*$');

  Future<List<String>> getLocations() async {
    final database = ScanHistoryDatabase.instance;
    final saved = await database.getAppSetting(_settingKey);
    if (saved != null) {
      return _sorted(_decode(saved));
    }

    // Seed the managed list from existing scan tags once for upgraded installs.
    final db = await database.database;
    final rows = await db.query(
      'scan_history',
      columns: const ['location'],
      distinct: true,
      where: "TRIM(location) <> ''",
    );
    final locations = _unique(
      rows.map((row) => row['location']?.toString() ?? ''),
    );
    final result = _sorted(locations);
    await database.setAppSetting(_settingKey, jsonEncode(result));
    return result;
  }

  Future<List<String>> addLocation(String value) async {
    final location = _normalize(value);
    _validate(location);
    final locations = await getLocations();
    if (locations.any((item) => _same(item, location))) return locations;
    locations.add(location);
    final result = _sorted(locations);
    await _save(result);
    return result;
  }

  Future<List<String>> renameLocation(String oldValue, String newValue) async {
    final oldLocation = _normalize(oldValue);
    final newLocation = _normalize(newValue);
    _validate(newLocation);
    final locations = await getLocations();
    final index = locations.indexWhere((item) => _same(item, oldLocation));
    if (index < 0) return locations;
    final duplicate = locations.any(
      (item) => _same(item, newLocation) && !_same(item, oldLocation),
    );
    if (duplicate) {
      throw StateError('A location with this name already exists.');
    }
    locations[index] = newLocation;
    final result = _sorted(locations);
    await _save(result);
    return result;
  }

  Future<List<String>> deleteLocation(String value) async {
    final locations = await getLocations();
    locations.removeWhere((item) => _same(item, value));
    final result = _sorted(locations);
    await _save(result);
    return result;
  }

  Future<void> _save(List<String> locations) => ScanHistoryDatabase.instance
      .setAppSetting(_settingKey, jsonEncode(locations));

  List<String> _decode(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) return <String>[];
      return _unique(decoded.whereType<String>());
    } on FormatException {
      return <String>[];
    }
  }

  List<String> _unique(Iterable<String> values) {
    final result = <String>[];
    for (final value in values) {
      final normalized = _normalize(value);
      if (normalized.isNotEmpty &&
          _validLocation.hasMatch(normalized) &&
          !result.any((item) => _same(item, normalized))) {
        result.add(normalized);
      }
    }
    return result;
  }

  List<String> _sorted(Iterable<String> values) {
    final result = _unique(values);
    result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return result;
  }

  String _normalize(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  bool _same(String first, String second) =>
      _normalize(first).toLowerCase() == _normalize(second).toLowerCase();

  void _validate(String value) {
    if (value.isEmpty || !_validLocation.hasMatch(value)) {
      throw ArgumentError('Use letters, numbers, and spaces only.');
    }
  }
}
