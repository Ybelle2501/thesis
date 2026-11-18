import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:thesis_app_ediwow/models/models.dart';
import 'package:thesis_app_ediwow/screens/plant_monitoring_screen.dart';
import 'package:thesis_app_ediwow/screens/result_screen.dart';
import 'package:thesis_app_ediwow/services/classifier.dart';
import 'package:thesis_app_ediwow/services/scan_history_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = _MemoryDatabase();
  late ScanHistoryDatabase store;
  late Directory directory;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp(
      'leaflens_monitoring_test_',
    );
    store = ScanHistoryDatabase.withFactory(
      _MemoryFactory(database, directory.path),
    );
  });
  setUp(() => database.rows.clear());
  tearDownAll(() => directory.delete(recursive: true));

  test(
    'legacy records keep independent plant identities at the same location',
    () {
      final legacy = _scan(7).toMap()
        ..remove('plant_id')
        ..remove('care_notes');
      final restored = ScanData.fromMap(legacy);
      expect(restored.monitoringId, 'scan_7');
      expect(restored.careNotes, isEmpty);
      expect(restored.monitoringId, isNot(_scan(8).monitoringId));
    },
  );

  test('repeated scans preserve prior observations and notes', () async {
    final first = await _save(store);
    await store.updateCareNotes(
      first.id!,
      '  Nov 18: removed affected leaves.  ',
    );
    final second = await _save(store, previous: first, healthy: true);
    final third = await _save(store, previous: second);
    final unrelated = await _save(store);
    final timeline = await store.getPlantScans(first.monitoringId);

    expect(timeline.map((scan) => scan.id), [third.id, second.id, first.id]);
    expect(timeline.map((scan) => scan.status), [
      'Infected',
      'Healthy',
      'Infected',
    ]);
    expect(timeline.last.careNotes, 'Nov 18: removed affected leaves.');
    expect(timeline.first.careNotes, isEmpty);
    expect(unrelated.monitoringId, isNot(first.monitoringId));
    expect(timeline.every((scan) => File(scan.imagePath).existsSync()), isTrue);
  });

  test(
    'a different crop or uncertain scan cannot change plant history',
    () async {
      final first = await _save(store);
      await expectLater(
        _save(store, previous: first, crop: 'tomato'),
        throwsArgumentError,
      );
      await expectLater(
        store.saveSuccessfulScan(
          sourceImagePath: 'assets/leaflens_logo.png',
          result: ClassificationResult(
            rawLabel: 'lettuce_fungal',
            confidence: 0.3,
            classIndex: 5,
            status: ScanStatus.lowConfidence,
          ),
          source: 'Camera',
          scanMode: 'Single',
          location: 'Greenhouse 2',
          monitoringScan: first,
        ),
        throwsArgumentError,
      );
      expect(await store.getPlantScans(first.monitoringId), hasLength(1));
    },
  );

  test('deleting the original scan keeps follow-ups linked', () async {
    final first = await _save(store);
    final second = await _save(store, previous: first, healthy: true);
    await store.deleteScans([first.id!]);
    final third = await _save(store, previous: second);
    expect(
      (await store.getPlantScans(first.monitoringId)).map((scan) => scan.id),
      [third.id, second.id],
    );
    await store.deleteScans([second.id!, third.id!]);
    await expectLater(_save(store, previous: third), throwsStateError);
  });

  testWidgets('history result opens the correct plant monitoring timeline', (
    tester,
  ) async {
    final first = _scan(1);
    final latest = _scan(
      2,
      healthy: true,
    ).copyWith(plantId: first.monitoringId);
    database.rows.addAll([first.toMap(), latest.toMap(), _scan(3).toMap()]);
    await tester.pumpWidget(
      MaterialApp(
        home: DiseaseResultScreen(
          historyDatabase: store,
          result: _result(),
          alreadySaved: true,
          savedScan: first,
          existingLocation: first.location,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Monitor Plant'));
    await tester.tap(find.text('Monitor Plant'));
    await tester.pumpAndSettle();
    expect(find.byType(PlantMonitoringScreen), findsOneWidget);
    expect(find.text('Saved scans: 2'), findsOneWidget);
    expect(
      find.text('Now classified as healthy after an infected scan.'),
      findsOneWidget,
    );
    expect(find.text('Scan Again to Update'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('care notes persist when monitoring is reopened', (tester) async {
    final scan = _scan(1);
    database.rows.add(scan.toMap());
    await tester.pumpWidget(
      MaterialApp(
        home: PlantMonitoringScreen(scan: scan, database: store),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Add Care Notes'), 200);
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Care Notes'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'Nov 18: improved ventilation.',
    );
    await tester.tap(find.text('Save Notes'));
    await tester.pumpAndSettle();
    expect(
      (await store.getPlantScans(scan.monitoringId)).single.careNotes,
      'Nov 18: improved ventilation.',
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      MaterialApp(
        home: PlantMonitoringScreen(scan: scan, database: store),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Nov 18: improved ventilation.'),
      200,
    );
    expect(find.text('Nov 18: improved ventilation.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a deleted plant has no enabled rescan action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PlantMonitoringScreen(scan: _scan(1), database: store),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No saved scans remain for this plant.'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
  });

  test(
    'backup restore retains linked observations, photos, and care notes',
    () async {
      final first = await _save(store);
      await store.updateCareNotes(
        first.id!,
        'Nov 18: removed infected leaves.',
      );
      await _save(store, previous: first, healthy: true);
      final exported = await store.exportBackupData();
      final scans = (exported['scans'] as List<Map<String, Object?>>)
          .map(Map<String, Object?>.from)
          .toList();
      final images = <String, List<int>>{};
      for (final scan in scans) {
        final entry = 'images/scan_${scan['id']}.png';
        images[entry] = await File(scan['image_path'] as String).readAsBytes();
        scan['image_entry'] = entry;
      }
      await store.restoreBackupData(
        scans: scans,
        metadata: const [],
        imageFiles: images,
      );
      final restored = await store.getPlantScans(first.monitoringId);
      expect(restored, hasLength(2));
      expect(restored.first.status, 'Healthy');
      expect(restored.last.careNotes, 'Nov 18: removed infected leaves.');
      expect(
        restored.every((scan) => File(scan.imagePath).existsSync()),
        isTrue,
      );
    },
  );

  test(
    'version 2 backup records receive independent monitoring identities',
    () async {
      final oldRows = [_scan(20).toMap(), _scan(21).toMap()];
      for (final row in oldRows) {
        row
          ..remove('plant_id')
          ..remove('care_notes');
      }
      await store.restoreBackupData(
        scans: oldRows,
        metadata: const [],
        imageFiles: const {},
      );
      expect(await store.getPlantScans('scan_20'), hasLength(1));
      expect(await store.getPlantScans('scan_21'), hasLength(1));
      expect((await store.getPlantScans('scan_20')).single.careNotes, isEmpty);
    },
  );
}

ScanData _scan(int id, {bool healthy = false}) => ScanData(
  id: id,
  plant: 'Lettuce',
  disease: healthy ? 'Healthy' : 'Fungal',
  status: healthy ? 'Healthy' : 'Infected',
  confidence: 0.95,
  imagePath: 'missing_test_image.png',
  rawLabel: healthy ? 'lettuce_healthy' : 'lettuce_fungal',
  classIndex: healthy ? 6 : 5,
  capturedAt: DateTime(2026, 11, 18, 9, id),
  source: 'Camera',
  scanMode: 'Single',
  location: 'Greenhouse 2',
  plantId: 'scan_$id',
);

ClassificationResult _result({bool healthy = false, String crop = 'lettuce'}) =>
    ClassificationResult(
      rawLabel: '${crop}_${healthy ? 'healthy' : 'fungal'}',
      confidence: 0.95,
      classIndex: healthy ? 6 : 5,
      status: ScanStatus.success,
    );

Future<ScanData> _save(
  ScanHistoryDatabase store, {
  ScanData? previous,
  bool healthy = false,
  String crop = 'lettuce',
}) => store.saveSuccessfulScan(
  sourceImagePath: 'assets/leaflens_logo.png',
  result: _result(healthy: healthy, crop: crop),
  source: 'Camera',
  scanMode: 'Single',
  location: 'Greenhouse 2',
  monitoringScan: previous,
);

// In-memory persistence double: tests exercise the real store's linking,
// validation, image retention and deletion, without a mobile SQLite plugin.
class _MemoryFactory implements DatabaseFactory {
  _MemoryFactory(this.database, this.path);
  final _MemoryDatabase database;
  final String path;
  @override
  Future<String> getDatabasesPath() async => path;
  @override
  Future<Database> openDatabase(
    String path, {
    OpenDatabaseOptions? options,
  }) async => database;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryDatabase implements Database, Transaction {
  final rows = <Map<String, Object?>>[];
  var nextId = 1;

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    final snapshot = rows.map((row) => Map<String, Object?>.from(row)).toList();
    try {
      return await action(this);
    } catch (_) {
      rows
        ..clear()
        ..addAll(snapshot);
      rethrow;
    }
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (table == 'app_metadata') return 1;
    final id = values['id'] as int? ?? nextId++;
    rows.add({...values, 'id': id});
    return id;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (table == 'app_metadata') {
      return [
        {'key': 'farm_location_options_v1', 'value': '["Greenhouse 2"]'},
      ];
    }
    final matches = rows
        .where((row) => _matches(row, where, whereArgs))
        .toList();
    if (orderBy != null && orderBy.contains('DESC')) {
      matches.sort((a, b) {
        final date = (b['captured_at'] as int).compareTo(
          a['captured_at'] as int,
        );
        return date != 0 ? date : (b['id'] as int).compareTo(a['id'] as int);
      });
    }
    return matches
        .take(limit ?? matches.length)
        .map((row) => Map<String, Object?>.from(row))
        .toList();
  }

  bool _matches(Map<String, Object?> row, String? where, List<Object?>? args) {
    if (where == null) return true;
    if (where == 'plant_id = ?') return row['plant_id'] == args!.first;
    if (where == 'id = ?') return row['id'] == args!.first;
    if (where.startsWith('id IN')) return args!.contains(row['id']);
    throw UnsupportedError('Unexpected test query: $where');
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final matches = rows
        .where((row) => _matches(row, where, whereArgs))
        .toList();
    for (final row in matches) {
      row.addAll(values);
    }
    return matches.length;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    if (table == 'app_metadata') return 0;
    final before = rows.length;
    rows.removeWhere((row) => _matches(row, where, whereArgs));
    return before - rows.length;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
