import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../models/models.dart';
import 'classifier.dart';

class ScanHistoryDatabase {
  ScanHistoryDatabase._();

  static final ScanHistoryDatabase instance = ScanHistoryDatabase._();

  static const _databaseName = 'scan_history.db';
  static const _tableName = 'scan_history';

  Database? _database;

  Future<Database> get _db async {
    final existing = _database;
    if (existing != null) return existing;

    final databasesDirectory = await getDatabasesPath();
    final path = '$databasesDirectory${Platform.pathSeparator}$_databaseName';
    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plant TEXT NOT NULL,
            disease TEXT NOT NULL,
            status TEXT NOT NULL CHECK(status IN ('Healthy', 'Infected')),
            confidence REAL NOT NULL,
            image_path TEXT NOT NULL,
            raw_label TEXT NOT NULL,
            class_index INTEGER NOT NULL,
            captured_at INTEGER NOT NULL,
            source TEXT NOT NULL,
            scan_mode TEXT NOT NULL,
            grid_cell INTEGER
          )
        ''');
        await db.execute(
          'CREATE INDEX scan_history_captured_at '
          'ON $_tableName(captured_at DESC)',
        );
        await db.execute(
          'CREATE INDEX scan_history_status ON $_tableName(status)',
        );
      },
    );
    _database = database;
    return database;
  }

  Future<List<ScanData>> getScans({int? limit}) async {
    final database = await _db;
    final rows = await database.query(
      _tableName,
      orderBy: 'captured_at DESC, id DESC',
      limit: limit,
    );
    return rows.map(ScanData.fromMap).toList(growable: false);
  }

  Future<ScanData> saveSuccessfulScan({
    required String sourceImagePath,
    required ClassificationResult result,
    required String source,
    required String scanMode,
    int? gridCell,
  }) async {
    if (result.status != ScanStatus.success) {
      throw ArgumentError('Only successful classifications can be saved.');
    }

    final savedImagePath = await _copyImageToAppStorage(sourceImagePath);
    final scan = ScanData(
      plant: result.plantName,
      disease: result.conditionName,
      status: result.isHealthy ? 'Healthy' : 'Infected',
      confidence: result.confidence,
      imagePath: savedImagePath,
      rawLabel: result.rawLabel,
      classIndex: result.classIndex,
      capturedAt: DateTime.now(),
      source: source,
      scanMode: scanMode,
      gridCell: gridCell,
    );

    try {
      final database = await _db;
      final id = await database.insert(_tableName, scan.toMap());
      return scan.copyWith(id: id);
    } catch (_) {
      await _deleteFileIfPresent(savedImagePath);
      rethrow;
    }
  }

  Future<void> deleteScans(Iterable<int> ids) async {
    final uniqueIds = ids.toSet().toList(growable: false);
    if (uniqueIds.isEmpty) return;

    final database = await _db;
    final placeholders = List.filled(uniqueIds.length, '?').join(',');
    final where = 'id IN ($placeholders)';
    final rows = await database.query(
      _tableName,
      columns: const ['image_path'],
      where: where,
      whereArgs: uniqueIds,
    );

    await database.delete(_tableName, where: where, whereArgs: uniqueIds);

    for (final row in rows) {
      final path = row['image_path'] as String?;
      if (path != null) await _deleteFileIfPresent(path);
    }
  }

  Future<String> _copyImageToAppStorage(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException(
        'The scan image could not be found.',
        sourcePath,
      );
    }

    final databasesDirectory = await getDatabasesPath();
    final imagesDirectory = Directory(
      '$databasesDirectory${Platform.pathSeparator}scan_history_images',
    );
    await imagesDirectory.create(recursive: true);

    final dotIndex = sourcePath.lastIndexOf('.');
    final extension = dotIndex == -1 ? '.jpg' : sourcePath.substring(dotIndex);
    final fileName = 'scan_${DateTime.now().microsecondsSinceEpoch}$extension';
    final destination =
        '${imagesDirectory.path}${Platform.pathSeparator}$fileName';
    await source.copy(destination);
    return destination;
  }

  Future<void> _deleteFileIfPresent(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // A missing/unavailable thumbnail should not prevent database deletion.
    }
  }
}
