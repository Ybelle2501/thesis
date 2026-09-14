import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thesis_app_ediwow/main.dart';
import 'package:thesis_app_ediwow/models/models.dart';
import 'package:thesis_app_ediwow/screens/reports_screen.dart';
import 'package:thesis_app_ediwow/services/classifier.dart';
import 'package:thesis_app_ediwow/services/grid_scan_service.dart';

void main() {
  testWidgets('dashboard loads the existing single-scan entry point', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CropSenseApp());

    expect(find.text('Scan Now'), findsOneWidget);
    expect(find.text('AI Crop\nScanner'), findsOneWidget);
  });

  test('grid scan modes have the requested independent cell layouts', () {
    expect(ScanCaptureMode.single.cellCount, 1);
    expect(ScanCaptureMode.grid2x2.cellCount, 4);
    expect(
      (ScanCaptureMode.grid2x3.rows, ScanCaptureMode.grid2x3.columns),
      (2, 3),
    );
    expect(
      (ScanCaptureMode.grid3x2.rows, ScanCaptureMode.grid3x2.columns),
      (3, 2),
    );
  });

  testWidgets('reports tab identifies scan history as its live data source', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ReportsScreen()));

    expect(find.text('Crop Reports'), findsOneWidget);
    expect(find.textContaining('Live data from scan history.'), findsOneWidget);
  });

  testWidgets('bundled classifier labels match the 23-class model', (
    WidgetTester _,
  ) async {
    final source = await rootBundle.loadString(
      PlantDiseaseClassifier.labelsAssetPath,
    );
    final labels = PlantDiseaseClassifier.parseLabels(source);

    expect(labels, hasLength(PlantDiseaseClassifier.expectedClassCount));
    expect(labels.first, 'banana_cordana');
    expect(labels[14], 'tomato_Early_blight');
    expect(labels.last, 'tomato_healthy');
  });

  testWidgets('bundled decision thresholds match the ResNet50 deployment rule', (
    WidgetTester _,
  ) async {
    final source = await rootBundle.loadString(
      PlantDiseaseClassifier.thresholdsAssetPath,
    );
    final thresholds = PlantDiseaseClassifier.parseThresholds(source);

    expect(thresholds.confidence, 0.0);
    expect(thresholds.margin, 0.0);
    expect(thresholds.accepts(topScore: 0.0, top1Top2Margin: 0.0), isTrue);
    expect(thresholds.accepts(topScore: 0.289, top1Top2Margin: 0.1), isTrue);
  });

  test('new classifier labels are formatted without training artifacts', () {
    final lettuce = ClassificationResult(
      rawLabel: 'lettuce_healthy_new',
      confidence: 0.9,
      classIndex: 12,
      status: ScanStatus.success,
    );
    final tomato = ClassificationResult(
      rawLabel: 'tomato_Tomato_Yellow_Leaf_Curl_Virus',
      confidence: 0.9,
      classIndex: 20,
      status: ScanStatus.success,
    );

    expect(lettuce.conditionName, 'Healthy');
    expect(lettuce.isHealthy, isTrue);
    expect(tomato.conditionName, 'Yellow Leaf Curl Virus');
    expect(tomato.isHealthy, isFalse);
  });

  test('scan records serialize all history and category fields', () {
    final capturedAt = DateTime(2026, 9, 1, 14, 5);
    final scan = ScanData(
      id: 7,
      plant: 'Tomato',
      disease: 'Early Blight',
      status: 'Infected',
      confidence: 0.94,
      imagePath: '/saved/scan.jpg',
      rawLabel: 'tomato_Early_blight',
      classIndex: 14,
      capturedAt: capturedAt,
      source: 'Camera',
      scanMode: 'Single',
    );

    final restored = ScanData.fromMap(scan.toMap());

    expect(restored.id, 7);
    expect(restored.status, 'Infected');
    expect(restored.rawLabel, 'tomato_Early_blight');
    expect(restored.imagePath, '/saved/scan.jpg');
    expect(restored.capturedAt, capturedAt);
    expect(restored.contextLabel, 'Camera - Single');
    expect(
      dateGroupLabel(capturedAt, relativeTo: DateTime(2026, 9, 1)),
      'Today',
    );
  });
}
