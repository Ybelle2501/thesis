import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';

import 'scan_history_database.dart';

class DataBackupService {
  DataBackupService._();

  static const backupFileName = 'leaflens_backup.leaflensbackup';
  static const backupFolderName = 'LeafLens Data';
  static const _formatVersion = 1;
  static const _channel = MethodChannel(
    'com.example.thesis_app_ediwow/data_backup',
  );

  static Future<String> exportToDownloads() async {
    final bytes = await createBackup();
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'LeafLens backup export is currently Android-only.',
      );
    }
    final path = await _channel.invokeMethod<String>(
      'saveBackup',
      <String, Object>{'filename': backupFileName, 'bytes': bytes},
    );
    if (path == null || path.isEmpty) {
      throw const FileSystemException(
        'Android did not save the LeafLens backup.',
      );
    }
    return path;
  }

  static Future<({String name, Uint8List bytes})?> pickBackup() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'LeafLens backup import is currently Android-only.',
      );
    }
    final picked = await _channel.invokeMapMethod<String, Object?>(
      'pickBackup',
    );
    if (picked == null) return null;
    final name = picked['name'] as String? ?? '';
    final bytes = picked['bytes'];
    if (!name.toLowerCase().endsWith('.leaflensbackup') ||
        bytes is! Uint8List) {
      throw const FormatException('Select a valid LeafLens backup file.');
    }
    return (name: name, bytes: bytes);
  }

  static Future<Uint8List> createBackup() async {
    final data = await ScanHistoryDatabase.instance.exportBackupData();
    final scans = (data['scans'] as List<Map<String, Object?>>)
        .map((row) => Map<String, Object?>.from(row))
        .toList(growable: false);
    final metadata = (data['metadata'] as List<Map<String, Object?>>)
        .map((row) => Map<String, Object?>.from(row))
        .toList(growable: false);

    final archive = Archive();
    for (final row in scans) {
      final originalPath = row.remove('image_path') as String?;
      String? imageEntry;
      if (originalPath != null && originalPath.isNotEmpty) {
        final image = File(originalPath);
        if (await image.exists()) {
          final id = row['id'] as int? ?? 0;
          final extension = _safeExtension(originalPath);
          imageEntry = 'images/scan_${id}_image$extension';
          final bytes = await image.readAsBytes();
          archive.addFile(ArchiveFile(imageEntry, bytes.length, bytes));
        }
      }
      row['image_entry'] = imageEntry;
    }

    final manifest = <String, Object>{
      'format': 'leaflens-backup',
      'format_version': _formatVersion,
      'database_schema_version': ScanHistoryDatabase.schemaVersion,
      'created_at_utc': DateTime.now().toUtc().toIso8601String(),
      'scan_count': scans.length,
    };
    _addJson(archive, 'manifest.json', manifest);
    _addJson(archive, 'scan_history.json', scans);
    _addJson(archive, 'app_metadata.json', metadata);
    final encoded = ZipEncoder().encode(archive);
    return Uint8List.fromList(encoded);
  }

  static Future<void> restoreBackup(Uint8List bytes) async {
    final decoded = ZipDecoder().decodeBytes(bytes, verify: true);
    final files = <String, List<int>>{};
    for (final file in decoded.files) {
      if (!file.isFile ||
          file.name.contains('..') ||
          file.name.startsWith('/')) {
        continue;
      }
      files[file.name] = List<int>.from(file.content as List<int>);
    }

    final manifest = _decodeJsonMap(files['manifest.json'], 'manifest.json');
    if (manifest['format'] != 'leaflens-backup' ||
        manifest['format_version'] != _formatVersion ||
        manifest['database_schema_version'] !=
            ScanHistoryDatabase.schemaVersion) {
      throw const FormatException(
        'This backup is invalid or was created by an incompatible LeafLens version.',
      );
    }

    final scansJson = _decodeJsonList(
      files['scan_history.json'],
      'scan_history.json',
    );
    final metadataJson = _decodeJsonList(
      files['app_metadata.json'],
      'app_metadata.json',
    );
    final scans = scansJson.map(_validateScan).toList(growable: false);
    final metadata = metadataJson
        .map(_validateMetadata)
        .toList(growable: false);
    if (manifest['scan_count'] != scans.length) {
      throw const FormatException(
        'The backup scan count does not match its contents.',
      );
    }

    final imageFiles = <String, List<int>>{};
    for (final scan in scans) {
      final imageEntry = scan['image_entry'] as String?;
      if (imageEntry != null) {
        if (!imageEntry.startsWith('images/') ||
            !files.containsKey(imageEntry)) {
          throw const FormatException('The backup is missing a scan image.');
        }
        imageFiles[imageEntry] = files[imageEntry]!;
      }
    }

    await ScanHistoryDatabase.instance.restoreBackupData(
      scans: scans,
      metadata: metadata,
      imageFiles: imageFiles,
    );
  }

  static String _safeExtension(String path) {
    final name = path.split(RegExp(r'[/\\]')).last;
    final dot = name.lastIndexOf('.');
    if (dot < 0) return '.jpg';
    final extension = name.substring(dot).toLowerCase();
    if (!RegExp(r'^\.[a-z0-9]{1,8}$').hasMatch(extension)) return '.jpg';
    return extension;
  }

  static void _addJson(Archive archive, String name, Object value) {
    final bytes = utf8.encode(jsonEncode(value));
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  static Map<String, Object?> _decodeJsonMap(List<int>? bytes, String name) {
    if (bytes == null) throw FormatException('Backup is missing $name.');
    final value = jsonDecode(utf8.decode(bytes));
    if (value is! Map<String, Object?>) {
      throw FormatException('Backup file $name has an invalid format.');
    }
    return value;
  }

  static List<Object?> _decodeJsonList(List<int>? bytes, String name) {
    if (bytes == null) throw FormatException('Backup is missing $name.');
    final value = jsonDecode(utf8.decode(bytes));
    if (value is! List<Object?>) {
      throw FormatException('Backup file $name has an invalid format.');
    }
    return value;
  }

  static Map<String, Object?> _validateScan(Object? value) {
    if (value is! Map<String, Object?>) {
      throw const FormatException('A scan record in the backup is invalid.');
    }
    final scan = Map<String, Object?>.from(value);
    final requiredText = [
      'plant',
      'disease',
      'status',
      'raw_label',
      'source',
      'scan_mode',
      'location',
    ];
    if (requiredText.any((key) => scan[key] is! String) ||
        !['Healthy', 'Infected'].contains(scan['status']) ||
        scan['id'] is! int ||
        scan['confidence'] is! num ||
        scan['class_index'] is! int ||
        scan['captured_at'] is! int ||
        (scan['grid_cell'] != null && scan['grid_cell'] is! int) ||
        (scan['image_entry'] != null && scan['image_entry'] is! String)) {
      throw const FormatException(
        'A scan record in the backup has invalid fields.',
      );
    }
    return scan;
  }

  static Map<String, Object?> _validateMetadata(Object? value) {
    if (value is! Map<String, Object?> ||
        value['key'] is! String ||
        value['value'] is! String) {
      throw const FormatException('App metadata in the backup is invalid.');
    }
    return Map<String, Object?>.from(value);
  }
}
