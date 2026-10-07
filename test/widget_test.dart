import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thesis_app_ediwow/main.dart';
import 'package:thesis_app_ediwow/models/models.dart';
import 'package:thesis_app_ediwow/screens/reports_dashboard_screen.dart';
import 'package:thesis_app_ediwow/screens/reports_screen.dart';
import 'package:thesis_app_ediwow/screens/result_screen.dart';
import 'package:thesis_app_ediwow/screens/scan_history_screen.dart';
import 'package:thesis_app_ediwow/services/classifier.dart';
import 'package:thesis_app_ediwow/services/grid_scan_service.dart';
import 'package:thesis_app_ediwow/services/pdf_report_service.dart';
import 'package:thesis_app_ediwow/widgets/location_tag_dialog.dart';
import 'package:thesis_app_ediwow/widgets/shared_widgets.dart';

void main() {
  testWidgets('dashboard loads the existing single-scan entry point', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LeafLensApp());

    expect(find.text('LeafLens'), findsOneWidget);
    expect(find.text('See the leaf. Understand the problem.'), findsOneWidget);
    expect(find.text(AiDisclaimer.message), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Scan Now'), findsOneWidget);
    expect(find.text('LeafLens'), findsOneWidget);
    expect(find.text('AI Crop\nScanner'), findsOneWidget);
    expect(find.text(AiDisclaimer.compactMessage), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);
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

  test('grid scans disregard non-plant and unreliable tiles', () {
    GridCellScan cellWith(ScanStatus status) => GridCellScan(
      cellNumber: 1,
      imagePath: '/cell.jpg',
      result: ClassificationResult(
        rawLabel: 'tomato_healthy',
        confidence: 0.9,
        classIndex: 22,
        status: status,
      ),
    );

    expect(cellWith(ScanStatus.noLeafDetected).isIgnored, isTrue);
    expect(cellWith(ScanStatus.lowConfidence).isIgnored, isTrue);
    expect(cellWith(ScanStatus.success).isIgnored, isFalse);
    expect(cellWith(ScanStatus.success).hasPlantResult, isTrue);
  });

  testWidgets('reports tab identifies scan history as its live data source', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ReportsScreen()));

    expect(find.text('Crop Reports'), findsOneWidget);
    expect(find.textContaining('Live data from scan history.'), findsOneWidget);
  });

  testWidgets('successful results collect location on the result screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DiseaseResultScreen(
          result: ClassificationResult(
            rawLabel: 'tomato_early-late_blight',
            confidence: 0.92,
            classIndex: 14,
            status: ScanStatus.success,
          ),
        ),
      ),
    );

    expect(find.text('Tag this crop location'), findsOneWidget);
    expect(find.text('Save Scan & Location'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Crop location'), findsOneWidget);
  });

  testWidgets('scan history overflow menu exposes location renaming', (
    WidgetTester tester,
  ) async {
    var renameRequested = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScanHistoryOverflowMenu(
            hasLocation: true,
            onRenameLocation: () => renameRequested = true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Rename location'), findsOneWidget);

    await tester.tap(find.text('Rename location'));
    await tester.pumpAndSettle();
    expect(renameRequested, isTrue);
  });

  testWidgets('rename dialog selects the old location for quick replacement', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showLocationTagDialog(
              context,
              initialLocation: 'Greenhouse 1',
              title: 'Rename location',
              actionLabel: 'Save changes',
              selectAllOnOpen: true,
              required: false,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(
      field.controller!.selection,
      const TextSelection(baseOffset: 0, extentOffset: 12),
    );
    expect(find.text('Save changes'), findsOneWidget);
  });

  testWidgets(
    'confidence chart stays usable with many scans on a narrow screen',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final scans = List<ScanData>.generate(
        18,
        (index) => ScanData(
          id: index,
          plant: index.isEven ? 'Tomato' : 'Lettuce',
          disease: index.isEven ? 'Early Blight' : 'Healthy',
          status: index.isEven ? 'Infected' : 'Healthy',
          confidence: index == 0 ? 1.2 : 0.72 + (index % 4) * 0.05,
          imagePath: '/scan_$index.jpg',
          rawLabel: index.isEven
              ? 'tomato_early-late_blight'
              : 'lettuce_healthy',
          classIndex: index.isEven ? 14 : 12,
          capturedAt: DateTime(2026, 9, 22, 12, index),
          source: 'Camera',
          scanMode: 'Single',
          location: 'Greenhouse 1',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ConfidenceByScanChart(scans: scans)),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('100%'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('bundled classifier labels match the 17-class model', (
    WidgetTester _,
  ) async {
    final source = await rootBundle.loadString(
      PlantDiseaseClassifier.labelsAssetPath,
    );
    final labels = PlantDiseaseClassifier.parseLabels(source);

    expect(labels, hasLength(PlantDiseaseClassifier.expectedClassCount));
    expect(labels.first, 'Pineapple_fusarium');
    expect(labels[11], 'tomato_early-late_blight');
    expect(labels.last, 'tomato_leaf_mold');
  });

  testWidgets(
    'bundled decision thresholds retain the MobileNetV2 deployment rule',
    (WidgetTester _) async {
      final source = await rootBundle.loadString(
        PlantDiseaseClassifier.thresholdsAssetPath,
      );
      final thresholds = PlantDiseaseClassifier.parseThresholds(source);

      expect(thresholds.confidence, 0.6);
      expect(thresholds.margin, 0.38);
      expect(thresholds.suggestionConfidence, 0.1);
      expect(thresholds.accepts(topScore: 0.59, top1Top2Margin: 0.3), isFalse);
      expect(thresholds.accepts(topScore: 0.8, top1Top2Margin: 0.37), isFalse);
      expect(thresholds.accepts(topScore: 0.6, top1Top2Margin: 0.38), isTrue);
    },
  );

  testWidgets('low-confidence results require a clearer plant picture', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DiseaseResultScreen(
          result: ClassificationResult(
            rawLabel: 'tomato_early-late_blight',
            confidence: 0.42,
            classIndex: 14,
            status: ScanStatus.lowConfidence,
          ),
        ),
      ),
    );

    expect(find.text('Unable to Identify Clearly'), findsOneWidget);
    expect(find.textContaining('may not be a supported plant'), findsOneWidget);
    expect(find.text('Scan or Take a Clear Picture'), findsOneWidget);
    expect(find.text('Use This Result Anyway'), findsNothing);
    expect(find.text('Tomato'), findsNothing);
    expect(find.text('Early Blight'), findsNothing);
  });

  test(
    'disease suggestions are thresholded, crop-scoped, and capped at two',
    () {
      final primary = RankedPrediction(
        rawLabel: 'tomato_early-late_blight',
        confidence: 0.46,
        classIndex: 14,
      );
      final predictions = [
        primary,
        RankedPrediction(
          rawLabel: 'lettuce_fungal',
          confidence: 0.31,
          classIndex: 11,
        ),
        RankedPrediction(
          rawLabel: 'tomato_leaf_mold',
          confidence: 0.22,
          classIndex: 15,
        ),
        RankedPrediction(
          rawLabel: 'tomato_healthy',
          confidence: 0.18,
          classIndex: 22,
        ),
        RankedPrediction(
          rawLabel: 'tomato_insect_damage',
          confidence: 0.14,
          classIndex: 16,
        ),
        RankedPrediction(
          rawLabel: 'tomato_leaf_miner',
          confidence: 0.09,
          classIndex: 19,
        ),
      ];

      final suggestions = PlantDiseaseClassifier.selectDiseaseSuggestions(
        rankedPredictions: predictions,
        primary: primary,
        confidenceThreshold: 0.1,
      );

      expect(suggestions.map((prediction) => prediction.rawLabel), [
        'tomato_leaf_mold',
        'tomato_insect_damage',
      ]);
      expect(suggestions, hasLength(2));
    },
  );

  test('a crop with two diseases can return one eligible alternative', () {
    final primary = RankedPrediction(
      rawLabel: 'lettuce_Bacterial',
      confidence: 0.55,
      classIndex: 10,
    );
    final suggestions = PlantDiseaseClassifier.selectDiseaseSuggestions(
      rankedPredictions: [
        primary,
        RankedPrediction(
          rawLabel: 'lettuce_fungal',
          confidence: 0.35,
          classIndex: 11,
        ),
        RankedPrediction(
          rawLabel: 'lettuce_healthy',
          confidence: 0.1,
          classIndex: 12,
        ),
        RankedPrediction(
          rawLabel: 'tomato_insect_damage',
          confidence: 0.2,
          classIndex: 13,
        ),
      ],
      primary: primary,
      confidenceThreshold: 0.1,
    );

    expect(suggestions, hasLength(1));
    expect(suggestions.single.rawLabel, 'lettuce_fungal');
  });

  test('new classifier labels are formatted without training artifacts', () {
    final lettuce = ClassificationResult(
      rawLabel: 'lettuce_healthy',
      confidence: 0.9,
      classIndex: 12,
      status: ScanStatus.success,
    );
    final tomato = ClassificationResult(
      rawLabel: 'tomato_leaf_curl_virus',
      confidence: 0.9,
      classIndex: 20,
      status: ScanStatus.success,
    );

    expect(lettuce.conditionName, 'Healthy');
    expect(lettuce.isHealthy, isTrue);
    expect(tomato.conditionName, 'Leaf Curl Virus');
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
      rawLabel: 'tomato_early-late_blight',
      classIndex: 14,
      capturedAt: capturedAt,
      source: 'Camera',
      scanMode: 'Single',
      location: 'Greenhouse 1',
    );

    final restored = ScanData.fromMap(scan.toMap());

    expect(restored.id, 7);
    expect(restored.status, 'Infected');
    expect(restored.rawLabel, 'tomato_early-late_blight');
    expect(restored.imagePath, '/saved/scan.jpg');
    expect(restored.capturedAt, capturedAt);
    expect(restored.contextLabel, 'Camera - Single');
    expect(restored.location, 'Greenhouse 1');
    expect(
      dateGroupLabel(capturedAt, relativeTo: DateTime(2026, 9, 1)),
      'Today',
    );
  });

  test(
    'location tags reject special characters and match case-insensitively',
    () {
      expect(locationTagPattern.hasMatch('Greenhouse 12'), isTrue);
      expect(locationTagPattern.hasMatch('Greenhouse-12'), isFalse);
      expect(locationTagsMatch('  Greenhouse  12 ', 'greenHOUSE 12'), isTrue);
    },
  );

  test('scouting PDF supports affected-crop attachments', () async {
    final scans = List<ScanData>.generate(
      8,
      (index) => ScanData(
        id: index,
        plant: index.isEven ? 'Tomato' : 'Lettuce',
        disease: index.isEven ? 'Early Blight' : 'Bacterial Leaf Spot',
        status: 'Infected',
        confidence: 0.9,
        imagePath: 'assets/leaflens_logo.png',
        rawLabel: 'tomato_early-late_blight',
        classIndex: 14,
        capturedAt: DateTime(2026, 9, 25, 9, index),
        source: 'Camera',
        scanMode: 'Single',
        location: 'Greenhouse 1',
      ),
    );

    final bytes = await PapusoyReportService.buildPdf(
      scans: scans,
      location: 'Greenhouse 1',
      scoutedBy: 'Test Scout',
      exportedAt: DateTime(2026, 9, 25),
    );

    expect(bytes, isNotEmpty);
    expect(bytes.length, greaterThan(10000));
  });
}
