import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'classifier.dart';

/// Orchestrates single-image scans while keeping the existing disease
/// classifier as the unchanged Stage 3 inference implementation.
class ThreeStageScanService {
  ThreeStageScanService({
    required PlantDiseaseClassifier diseaseClassifier,
    ScanGateModel? stage1,
    ScanGateModel? stage2,
  }) : _diseaseClassifier = diseaseClassifier,
       _stage1 =
           stage1 ??
           _GateInterpreter(
             modelAsset: 'assets/stage1_model_float32.tflite',
             labelsAsset: 'assets/stage1_labels.json',
             thresholdsAsset: 'assets/stage1_threshold.json',
             expectedLabels: const ['non_plant', 'plant'],
           ),
       _stage2 =
           stage2 ??
           _GateInterpreter(
             modelAsset: 'assets/stage2_model_float32.tflite',
             labelsAsset: 'assets/stage2_labels.json',
             thresholdsAsset: 'assets/stage2_threshold.json',
             expectedLabels: const [
               'banana',
               'lettuce',
               'other_plant',
               'pineapple',
               'tomato',
             ],
           );

  static const supportedCrops = {'banana', 'lettuce', 'pineapple', 'tomato'};

  final PlantDiseaseClassifier _diseaseClassifier;
  final ScanGateModel _stage1;
  final ScanGateModel _stage2;
  bool _disposed = false;

  static bool stage1Accepts(String label, {required bool uncertain}) =>
      !uncertain && label.toLowerCase() == 'plant';

  static bool stage2Accepts(String label, {required bool uncertain}) =>
      !uncertain && supportedCrops.contains(label.toLowerCase());

  static bool stage3SupportsCrop(String crop, Iterable<String> diseaseLabels) =>
      supportedCrops.contains(crop.toLowerCase()) &&
      diseaseLabels.any(
        (label) => label.split('_').first.toLowerCase() == crop.toLowerCase(),
      );

  Future<ClassificationResult> classify(
    String imagePath, {
    void Function(String message)? onStage,
  }) async {
    _checkActive();
    onStage?.call('Checking whether the image contains a plant...');
    final stage1 = await _stage1.classify(imagePath);
    _checkActive();
    if (!stage1Accepts(stage1.label, uncertain: stage1.uncertain)) {
      return _rejection(
        stage1.uncertain
            ? 'The image is unclear. Please take another plant photo.'
            : 'This image does not appear to contain a supported plant. Please scan a plant image.',
        uncertain: stage1.uncertain,
      );
    }

    // Stage 2 is not loaded or invoked until Stage 1 accepted the same image.
    onStage?.call('Identifying crop...');
    final stage2 = await _stage2.classify(imagePath);
    _checkActive();
    if (!stage2Accepts(stage2.label, uncertain: stage2.uncertain)) {
      return _rejection(
        stage2.uncertain
            ? 'The crop could not be identified confidently. Please try another image.'
            : 'This plant is currently not supported by the application. Supported crops are banana, lettuce, pineapple, and tomato.',
        uncertain: stage2.uncertain,
      );
    }

    final crop = stage2.label.toLowerCase();
    // Validate the existing Stage 3 labels before loading/running its model.
    final stage3Labels = PlantDiseaseClassifier.parseLabels(
      await rootBundle.loadString(PlantDiseaseClassifier.labelsAssetPath),
    );
    if (!stage3SupportsCrop(crop, stage3Labels)) {
      return _rejection(
        'Disease scanning is not available for ${_displayCrop(crop)} yet.',
        crop: crop,
      );
    }

    onStage?.call('Analyzing crop condition...');
    await _diseaseClassifier.loadModel();
    _checkActive();
    final disease = await _diseaseClassifier.classify(imagePath);
    _checkActive();
    if (disease.plantName.toLowerCase() != crop) {
      return _rejection(
        'The crop checks did not agree. Please take a clearer image and scan again.',
        uncertain: true,
        crop: crop,
      );
    }

    onStage?.call('Preparing diagnosis...');
    return ClassificationResult(
      rawLabel: disease.rawLabel,
      confidence: disease.confidence,
      classIndex: disease.classIndex,
      status: disease.status,
      rankedPredictions: disease.rankedPredictions,
      suggestedDiseases: disease.suggestedDiseases,
      rejectionMessage: disease.status == ScanStatus.lowConfidence
          ? 'The crop condition could not be identified confidently. Please scan a clearer image.'
          : null,
      detectedCrop: crop,
    );
  }

  static ClassificationResult _rejection(
    String message, {
    bool uncertain = false,
    String? crop,
  }) => ClassificationResult(
    rawLabel: crop ?? 'unknown',
    confidence: 0,
    classIndex: -1,
    status: uncertain ? ScanStatus.lowConfidence : ScanStatus.rejected,
    rejectionMessage: message,
    detectedCrop: crop,
  );

  static String _displayCrop(String crop) =>
      crop[0].toUpperCase() + crop.substring(1);

  void _checkActive() {
    if (_disposed) {
      throw StateError('Scan processing was interrupted.');
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _stage1.dispose();
    _stage2.dispose();
  }
}

class ScanGateResult {
  const ScanGateResult({
    required this.label,
    required this.uncertain,
    required this.confidence,
  });

  final String label;
  final bool uncertain;
  final double confidence;
}

class _GateThresholds {
  const _GateThresholds({required this.confidence, required this.margin});

  final double confidence;
  final double margin;

  factory _GateThresholds.parse(String source, String path) {
    final decoded = jsonDecode(source);
    if (decoded is! Map ||
        decoded['confidence_threshold'] is! num ||
        decoded['margin_threshold'] is! num ||
        decoded['calibration_status'] is! String) {
      throw FormatException('Invalid threshold configuration: $path.');
    }
    final confidence = (decoded['confidence_threshold'] as num).toDouble();
    final margin = (decoded['margin_threshold'] as num).toDouble();
    if (!confidence.isFinite ||
        confidence < 0 ||
        confidence > 1 ||
        !margin.isFinite ||
        margin < 0 ||
        margin > 1) {
      throw FormatException('Thresholds in $path must be between 0 and 1.');
    }
    return _GateThresholds(confidence: confidence, margin: margin);
  }
}

abstract interface class ScanGateModel {
  Future<ScanGateResult> classify(String imagePath);
  void dispose();
}

class _GateInterpreter implements ScanGateModel {
  _GateInterpreter({
    required this.modelAsset,
    required this.labelsAsset,
    required this.thresholdsAsset,
    required this.expectedLabels,
  });

  final String modelAsset;
  final String labelsAsset;
  final String thresholdsAsset;
  final List<String> expectedLabels;
  Interpreter? _interpreter;
  List<String> _labels = const [];
  _GateThresholds? _thresholds;
  Future<void>? _loading;

  Future<void> _load() => _loading ??= _loadOnce();

  Future<void> _loadOnce() async {
    Interpreter? interpreter;
    try {
      final labels = _parseLabels(await rootBundle.loadString(labelsAsset));
      if (labels.length != expectedLabels.length ||
          List.generate(
            labels.length,
            (i) => labels[i] == expectedLabels[i],
          ).any((matches) => !matches)) {
        throw FormatException(
          'Labels do not match the model output: $labelsAsset.',
        );
      }
      final thresholds = _GateThresholds.parse(
        await rootBundle.loadString(thresholdsAsset),
        thresholdsAsset,
      );
      interpreter = await Interpreter.fromAsset(modelAsset);
      final inputs = interpreter.getInputTensors();
      final outputs = interpreter.getOutputTensors();
      if (inputs.length != 1 ||
          outputs.length != 1 ||
          inputs.single.type != TensorType.float32 ||
          !_sameShape(inputs.single.shape, const [1, 224, 224, 3]) ||
          outputs.single.type != TensorType.float32 ||
          !_sameShape(outputs.single.shape, [1, labels.length])) {
        throw StateError('Unsupported tensor contract in $modelAsset.');
      }
      _labels = labels;
      _thresholds = thresholds;
      _interpreter = interpreter;
    } catch (_) {
      interpreter?.close();
      _loading = null;
      rethrow;
    }
  }

  @override
  Future<ScanGateResult> classify(String imagePath) async {
    if (_interpreter == null) await _load();
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const FormatException('Could not decode image.');
    final resized = img.copyResize(
      img.bakeOrientation(decoded),
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear,
    );
    final inputBuffer = Float32List(224 * 224 * 3);
    var offset = 0;
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        inputBuffer[offset++] = pixel.r.toDouble();
        inputBuffer[offset++] = pixel.g.toDouble();
        inputBuffer[offset++] = pixel.b.toDouble();
      }
    }

    // Both exports embed MobileNetV2 preprocessing; provide raw RGB [0,255].
    final output = [List<double>.filled(_labels.length, 0)];
    _interpreter!.run(inputBuffer.reshape<double>([1, 224, 224, 3]), output);
    final scores = output.single;
    if (scores.isEmpty ||
        scores.any((value) => !value.isFinite || value < 0 || value > 1)) {
      throw StateError('The model returned invalid probabilities.');
    }
    final ranked = List<int>.generate(scores.length, (i) => i)
      ..sort((a, b) => scores[b].compareTo(scores[a]));
    final topIndex = ranked.first;
    final topScore = scores[topIndex];
    final runnerUp = ranked.length > 1 ? scores[ranked[1]] : 0.0;
    final thresholds = _thresholds!;
    final uncertain =
        topScore < thresholds.confidence ||
        topScore - runnerUp < thresholds.margin;
    return ScanGateResult(
      label: _labels[topIndex],
      uncertain: uncertain,
      confidence: topScore,
    );
  }

  static List<String> _parseLabels(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Labels must be a JSON object.');
    }
    final indexed = <int, String>{};
    for (final entry in decoded.entries) {
      final index = int.tryParse(entry.key.toString());
      if (index == null ||
          index < 0 ||
          entry.value is! String ||
          (entry.value as String).trim().isEmpty ||
          indexed.containsKey(index)) {
        throw FormatException('Invalid label entry: ${entry.key}.');
      }
      indexed[index] = (entry.value as String).trim().toLowerCase();
    }
    if (indexed.length != decoded.length ||
        List.generate(indexed.length, indexed.containsKey).contains(false)) {
      throw const FormatException(
        'Label indices must be contiguous from zero.',
      );
    }
    return List.unmodifiable(List.generate(indexed.length, (i) => indexed[i]!));
  }

  static bool _sameShape(List<int> actual, List<int> expected) =>
      actual.length == expected.length &&
      List.generate(
        actual.length,
        (i) => actual[i] == expected[i],
      ).every((matches) => matches);

  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = const [];
    _thresholds = null;
    _loading = null;
  }
}
