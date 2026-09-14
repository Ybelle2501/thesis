import 'dart:io';

import 'package:image/image.dart' as img;

import 'classifier.dart';

enum ScanCaptureMode {
  single(title: 'Single scan', shortLabel: 'Single', rows: 1, columns: 1),
  grid2x2(title: '2x2 grid', shortLabel: '2x2', rows: 2, columns: 2),
  grid2x3(
    title: '2x3 grid - landscape cells',
    shortLabel: '2x3 H',
    rows: 2,
    columns: 3,
  ),
  grid3x2(
    title: '2x3 grid - portrait cells',
    shortLabel: '2x3 V',
    rows: 3,
    columns: 2,
  );

  const ScanCaptureMode({
    required this.title,
    required this.shortLabel,
    required this.rows,
    required this.columns,
  });

  final String title;
  final String shortLabel;
  final int rows;
  final int columns;

  int get cellCount => rows * columns;
  bool get isGrid => cellCount > 1;
  String get gridName => cellCount == 4 ? '2x2' : '2x3';
  String get dimensionsLabel => '$rows rows x $columns columns';
}

class GridCellScan {
  const GridCellScan({
    required this.cellNumber,
    required this.imagePath,
    this.result,
    this.error,
  });

  final int cellNumber;
  final String imagePath;
  final ClassificationResult? result;
  final String? error;
}

class GridScanService {
  const GridScanService(this.classifier);

  final PlantDiseaseClassifier classifier;

  Future<List<GridCellScan>> scanImage({
    required String imagePath,
    required ScanCaptureMode mode,
    void Function(int cellNumber, int totalCells)? onProgress,
  }) async {
    if (!mode.isGrid) {
      throw ArgumentError.value(mode, 'mode', 'A grid mode is required.');
    }

    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('Could not decode the captured image.');
    }

    final source = img.bakeOrientation(decoded);
    final baseCellWidth = source.width ~/ mode.columns;
    final baseCellHeight = source.height ~/ mode.rows;
    final outputDirectory = File(imagePath).parent;
    final captureId = DateTime.now().microsecondsSinceEpoch;
    final scans = <GridCellScan>[];

    for (int index = 0; index < mode.cellCount; index++) {
      final row = index ~/ mode.columns;
      final column = index % mode.columns;
      final x = column * baseCellWidth;
      final y = row * baseCellHeight;
      final width = column == mode.columns - 1
          ? source.width - x
          : baseCellWidth;
      final height = row == mode.rows - 1 ? source.height - y : baseCellHeight;
      final cellNumber = index + 1;

      final crop = img.copyCrop(
        source,
        x: x,
        y: y,
        width: width,
        height: height,
      );
      final cellPath =
          '${outputDirectory.path}${Platform.pathSeparator}grid_${captureId}_cell_$cellNumber.jpg';
      await File(cellPath).writeAsBytes(img.encodeJpg(crop, quality: 92));

      onProgress?.call(cellNumber, mode.cellCount);
      try {
        final result = await classifier.classify(cellPath);
        scans.add(
          GridCellScan(
            cellNumber: cellNumber,
            imagePath: cellPath,
            result: result,
          ),
        );
      } catch (error) {
        scans.add(
          GridCellScan(
            cellNumber: cellNumber,
            imagePath: cellPath,
            error: error.toString(),
          ),
        );
      }
    }

    return scans;
  }
}
