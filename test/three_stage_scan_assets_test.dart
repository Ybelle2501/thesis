import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:thesis_app_ediwow/services/classifier.dart';
import 'package:thesis_app_ediwow/services/grid_scan_service.dart';
import 'package:thesis_app_ediwow/services/three_stage_scan_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'gate labels preserve the model output order and actual plant name',
    () async {
      final stage1Json =
          jsonDecode(await rootBundle.loadString('assets/stage1_labels.json'))
              as Map<String, dynamic>;
      final stage2Json =
          jsonDecode(await rootBundle.loadString('assets/stage2_labels.json'))
              as Map<String, dynamic>;
      final stage1 = [
        for (var i = 0; i < stage1Json.length; i++) stage1Json['$i'],
      ];
      final stage2 = [
        for (var i = 0; i < stage2Json.length; i++) stage2Json['$i'],
      ];

      expect(stage1, ['non_plant', 'plant']);
      expect(stage2, [
        'banana',
        'lettuce',
        'other_plant',
        'pineapple',
        'tomato',
      ]);
    },
  );

  test('only confident plants and supported crops pass their gates', () {
    expect(
      ThreeStageScanService.stage1Accepts('non_plant', uncertain: false),
      isFalse,
    );
    expect(
      ThreeStageScanService.stage1Accepts('plant', uncertain: true),
      isFalse,
    );
    expect(
      ThreeStageScanService.stage1Accepts('plant', uncertain: false),
      isTrue,
    );
    for (final crop in ['banana', 'lettuce', 'pineapple', 'tomato']) {
      expect(
        ThreeStageScanService.stage2Accepts(crop, uncertain: false),
        isTrue,
      );
    }
    expect(
      ThreeStageScanService.stage2Accepts('other_plant', uncertain: false),
      isFalse,
    );
    expect(
      ThreeStageScanService.stage2Accepts('banana', uncertain: true),
      isFalse,
    );
  });

  test('Stage 3 requires disease labels for the selected crop', () {
    const labels = ['banana_healthy', 'tomato_leaf_mold'];
    expect(ThreeStageScanService.stage3SupportsCrop('banana', labels), isTrue);
    expect(
      ThreeStageScanService.stage3SupportsCrop('lettuce', labels),
      isFalse,
    );
    expect(
      ThreeStageScanService.stage3SupportsCrop('other_plant', labels),
      isFalse,
    );
  });

  test(
    'Stage 2 is never called when Stage 1 rejects or is uncertain',
    () async {
      for (final stage1Result in [
        const ScanGateResult(
          label: 'non_plant',
          uncertain: false,
          confidence: 0.99,
        ),
        const ScanGateResult(label: 'plant', uncertain: true, confidence: 0.51),
      ]) {
        final stage1 = _FakeGate(stage1Result);
        final stage2 = _FakeGate(
          const ScanGateResult(
            label: 'banana',
            uncertain: false,
            confidence: 0.99,
          ),
        );
        final stage3 = _FakeDiseaseClassifier();
        final service = ThreeStageScanService(
          diseaseClassifier: stage3,
          stage1: stage1,
          stage2: stage2,
        );

        await service.classify('original-image.jpg');

        expect(stage1.calls, 1);
        expect(stage2.calls, 0);
        expect(stage3.inferenceCalls, 0);
        service.dispose();
      }
    },
  );

  test('Stage 3 is never called after Stage 2 rejects the crop', () async {
    final stage1 = _FakeGate(
      const ScanGateResult(label: 'plant', uncertain: false, confidence: 0.99),
    );
    final stage2 = _FakeGate(
      const ScanGateResult(
        label: 'other_plant',
        uncertain: false,
        confidence: 0.99,
      ),
    );
    final stage3 = _FakeDiseaseClassifier();
    final service = ThreeStageScanService(
      diseaseClassifier: stage3,
      stage1: stage1,
      stage2: stage2,
    );

    await service.classify('original-image.jpg');

    expect(stage1.calls, 1);
    expect(stage2.calls, 1);
    expect(stage3.loadCalls, 0);
    expect(stage3.inferenceCalls, 0);
    service.dispose();
  });

  test('an inference error stops the pipeline immediately', () async {
    final stage1 = _FakeGate(
      const ScanGateResult(label: 'plant', uncertain: false, confidence: 0.99),
    );
    final stage2 = _FakeGate(
      const ScanGateResult(label: 'banana', uncertain: false, confidence: 0.99),
      failure: StateError('synthetic inference error'),
    );
    final stage3 = _FakeDiseaseClassifier();
    final service = ThreeStageScanService(
      diseaseClassifier: stage3,
      stage1: stage1,
      stage2: stage2,
    );

    await expectLater(
      service.classify('original-image.jpg'),
      throwsA(isA<StateError>()),
    );
    expect(stage1.calls, 1);
    expect(stage2.calls, 1);
    expect(stage3.loadCalls, 0);
    expect(stage3.inferenceCalls, 0);
    service.dispose();
  });

  test('interruption during Stage 1 prevents Stage 2 from starting', () async {
    final stage1 = _FakeGate(
      const ScanGateResult(label: 'plant', uncertain: false, confidence: 0.99),
    )..pending = Completer<ScanGateResult>();
    final stage2 = _FakeGate(
      const ScanGateResult(label: 'banana', uncertain: false, confidence: 0.99),
    );
    final service = ThreeStageScanService(
      diseaseClassifier: _FakeDiseaseClassifier(),
      stage1: stage1,
      stage2: stage2,
    );

    final resultFuture = service.classify('original-image.jpg');
    await Future<void>.delayed(Duration.zero);
    service.dispose();
    stage1.pending!.complete(
      const ScanGateResult(label: 'plant', uncertain: false, confidence: 0.99),
    );

    await expectLater(resultFuture, throwsA(isA<StateError>()));
    expect(stage2.calls, 0);
  });

  test('accepted stages pass the original image path to each stage', () async {
    const imagePath = 'original-image.jpg';
    final stage1 = _FakeGate(
      const ScanGateResult(label: 'plant', uncertain: false, confidence: 0.99),
    );
    final stage2 = _FakeGate(
      const ScanGateResult(label: 'banana', uncertain: false, confidence: 0.99),
    );
    final stage3 = _FakeDiseaseClassifier();
    final service = ThreeStageScanService(
      diseaseClassifier: stage3,
      stage1: stage1,
      stage2: stage2,
    );

    final result = await service.classify(imagePath);

    expect(stage1.imagePaths, [imagePath]);
    expect(stage2.imagePaths, [imagePath]);
    expect(stage3.imagePaths, [imagePath]);
    expect(stage3.loadCalls, 1);
    expect(stage3.inferenceCalls, 1);
    expect(result.detectedCrop, 'banana');
    service.dispose();
  });

  test(
    'grid cells run Stage 1 and stop rejected cells before Stage 2',
    () async {
      final directory = await Directory.systemTemp.createTemp('grid-gates-');
      final imagePath = '${directory.path}${Platform.pathSeparator}grid.jpg';
      await File(
        imagePath,
      ).writeAsBytes(img.encodeJpg(img.Image(width: 60, height: 40)));
      final stage1 = _FakeGate(
        const ScanGateResult(
          label: 'non_plant',
          uncertain: false,
          confidence: 0.99,
        ),
      );
      final stage2 = _FakeGate(
        const ScanGateResult(
          label: 'banana',
          uncertain: false,
          confidence: 0.99,
        ),
      );
      final stage3 = _FakeDiseaseClassifier();
      final pipeline = ThreeStageScanService(
        diseaseClassifier: stage3,
        stage1: stage1,
        stage2: stage2,
      );

      try {
        final cells = await GridScanService(
          pipeline,
        ).scanImage(imagePath: imagePath, mode: ScanCaptureMode.grid2x3);
        expect(cells, hasLength(6));
        expect(
          cells.every((cell) => cell.result?.status == ScanStatus.rejected),
          isTrue,
        );
        expect(cells.every((cell) => cell.isIgnored), isTrue);
        expect(stage1.calls, 6);
        expect(stage2.calls, 0);
        expect(stage3.inferenceCalls, 0);
      } finally {
        pipeline.dispose();
        await directory.delete(recursive: true);
      }
    },
  );

  test(
    'thresholds are bounded and their calibration state is explicit',
    () async {
      for (final asset in [
        'assets/stage1_threshold.json',
        'assets/stage2_threshold.json',
      ]) {
        final config = jsonDecode(await rootBundle.loadString(asset)) as Map;
        expect(config['confidence_threshold'], inInclusiveRange(0, 1));
        expect(config['margin_threshold'], inInclusiveRange(0, 1));
        expect(
          config['calibration_status'].toString().toLowerCase(),
          contains('provisional'),
        );
      }
      final stage1 =
          jsonDecode(
                await rootBundle.loadString('assets/stage1_threshold.json'),
              )
              as Map;
      expect(stage1['confidence_threshold'], 0.5);
      expect(stage1['margin_threshold'], 0.1);
    },
  );
}

class _FakeGate implements ScanGateModel {
  _FakeGate(this.result, {this.failure});
  final ScanGateResult result;
  final Object? failure;
  Completer<ScanGateResult>? pending;
  int calls = 0;
  final imagePaths = <String>[];

  @override
  Future<ScanGateResult> classify(String imagePath) async {
    calls++;
    imagePaths.add(imagePath);
    if (failure != null) throw failure!;
    if (pending != null) return pending!.future;
    return result;
  }

  @override
  void dispose() {}
}

class _FakeDiseaseClassifier extends PlantDiseaseClassifier {
  int loadCalls = 0;
  int inferenceCalls = 0;
  final imagePaths = <String>[];

  @override
  Future<void> loadModel() async {
    loadCalls++;
  }

  @override
  Future<ClassificationResult> classify(String imagePath) async {
    inferenceCalls++;
    imagePaths.add(imagePath);
    return ClassificationResult(
      rawLabel: 'banana_healthy',
      confidence: 0.99,
      classIndex: 1,
      status: ScanStatus.success,
    );
  }
}
