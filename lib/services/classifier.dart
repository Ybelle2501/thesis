import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassifierDecisionThresholds {
  const ClassifierDecisionThresholds({
    required this.confidence,
    required this.margin,
  });

  final double confidence;
  final double margin;

  bool accepts({required double topScore, required double top1Top2Margin}) =>
      topScore >= confidence && top1Top2Margin >= margin;
}

enum ScanStatus {
  /// The result passed the deployment decision thresholds.
  success,

  /// The result did not pass the deployment decision thresholds.
  lowConfidence,

  /// Reserved for classifiers that explicitly support no-leaf detection.
  noLeafDetected,
}

class RankedPrediction {
  final String rawLabel;
  final String label;
  final String plantName;
  final String conditionName;
  final double confidence;
  final int classIndex;

  RankedPrediction({
    required this.rawLabel,
    required this.confidence,
    required this.classIndex,
  }) : label = _formatLabel(rawLabel),
       plantName = _plantName(rawLabel),
       conditionName = _conditionName(rawLabel);

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  bool get isHealthy => _isHealthyLabel(rawLabel);
}

class ClassificationResult {
  final String rawLabel;
  final String label;
  final String plantName;
  final String conditionName;
  final double confidence;
  final int classIndex;
  final ScanStatus status;
  final List<RankedPrediction> rankedPredictions;

  ClassificationResult({
    required this.rawLabel,
    required this.confidence,
    required this.classIndex,
    required this.status,
    this.rankedPredictions = const [],
  }) : label = _formatLabel(rawLabel),
       plantName = _plantName(rawLabel),
       conditionName = _conditionName(rawLabel);

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  bool get isHealthy => _isHealthyLabel(rawLabel);

  /// True when the result should be shown to the user.
  bool get isReliable => status == ScanStatus.success;
}

String _formatLabel(String rawLabel) {
  final plant = _plantName(rawLabel);
  final condition = _conditionName(rawLabel);
  return condition.isEmpty ? plant : '$plant — $condition';
}

String _plantName(String rawLabel) {
  final parts = _labelParts(rawLabel);
  return parts.isEmpty ? rawLabel : _titleCase(parts.first);
}

String _conditionName(String rawLabel) {
  final parts = _labelParts(rawLabel);
  if (parts.length < 2) return '';

  final plant = parts.first.toLowerCase();
  final conditionParts = parts.sublist(1);

  // Some dataset labels repeat the crop name or carry a training-only new
  // suffix. Keep the raw label intact while presenting a clean user-facing name.
  if (conditionParts.isNotEmpty &&
      conditionParts.first.toLowerCase() == plant) {
    conditionParts.removeAt(0);
  }
  if (conditionParts.length == 2 &&
      conditionParts.first.toLowerCase() == 'healthy' &&
      conditionParts.last.toLowerCase() == 'new') {
    conditionParts.removeLast();
  }

  return conditionParts.map(_titleCase).join(' ');
}

List<String> _labelParts(String rawLabel) => rawLabel
    .split('_')
    .map((part) => part.trim())
    .where((part) => part.isNotEmpty)
    .toList(growable: true);

String _titleCase(String value) => value
    .split(' ')
    .map(
      (word) => word.isEmpty
          ? word
          : word[0].toUpperCase() + word.substring(1).toLowerCase(),
    )
    .join(' ');

bool _isHealthyLabel(String rawLabel) =>
    _labelParts(rawLabel).any((part) => part.toLowerCase() == 'healthy');

class PlantDiseaseClassifier {
  static const String modelAssetPath = 'assets/ResNet50_refined_best.tflite';
  static const String labelsAssetPath = 'assets/labels.json';
  static const String thresholdsAssetPath =
      'assets/ResNet50_decision_thresholds.json';
  static const String modelName = 'ResNet50_refined_best.tflite';
  static const int inputSize = 224;
  static const int expectedClassCount = 23;

  Interpreter? _interpreter;
  List<String> _labels = const [];
  ClassifierDecisionThresholds? _thresholds;
  bool _isLoaded = false;
  Future<void>? _loadingModel;

  Future<void> loadModel() {
    if (_isLoaded) return Future<void>.value();
    return _loadingModel ??= _loadModel();
  }

  Future<void> _loadModel() async {
    Interpreter? interpreter;
    try {
      final labelsJson = await rootBundle.loadString(labelsAssetPath);
      final labels = parseLabels(labelsJson);
      final thresholdsJson = await rootBundle.loadString(thresholdsAssetPath);
      final thresholds = parseThresholds(thresholdsJson);
      interpreter = await Interpreter.fromAsset(modelAssetPath);

      _validateModelContract(interpreter, labels);

      _labels = labels;
      _thresholds = thresholds;
      _interpreter = interpreter;
      _isLoaded = true;
    } catch (error, stackTrace) {
      interpreter?.close();
      _interpreter = null;
      _labels = const [];
      _thresholds = null;
      _isLoaded = false;
      Error.throwWithStackTrace(
        Exception('Failed to load classifier assets: $error'),
        stackTrace,
      );
    } finally {
      _loadingModel = null;
    }
  }

  /// Converts the numeric-keyed label object into model-output order.
  static List<String> parseLabels(String source) {
    final dynamic decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException(
        'Classifier labels must be a JSON object keyed by class index.',
      );
    }

    final labelsByIndex = <int, String>{};
    for (final entry in decoded.entries) {
      final index = int.tryParse(entry.key.toString());
      final value = entry.value;
      if (index == null ||
          index < 0 ||
          value is! String ||
          value.trim().isEmpty) {
        throw FormatException('Invalid classifier label entry: ${entry.key}.');
      }
      if (labelsByIndex.containsKey(index)) {
        throw FormatException('Duplicate classifier label index: $index.');
      }
      labelsByIndex[index] = value.trim();
    }

    if (labelsByIndex.length != expectedClassCount) {
      throw FormatException(
        'Expected $expectedClassCount classifier labels, '
        'found ${labelsByIndex.length}.',
      );
    }

    return List<String>.unmodifiable(
      List<String>.generate(expectedClassCount, (index) {
        final label = labelsByIndex[index];
        if (label == null) {
          throw FormatException('Missing classifier label index: $index.');
        }
        return label;
      }),
    );
  }

  /// Reads and validates the deployment decision rule exported with the model.
  static ClassifierDecisionThresholds parseThresholds(String source) {
    final dynamic decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException(
        'Classifier thresholds must be a JSON object.',
      );
    }

    final confidenceValue = decoded['confidence_threshold'];
    final marginValue = decoded['margin_threshold'];
    if (confidenceValue is! num || marginValue is! num) {
      throw const FormatException(
        'Classifier thresholds must contain numeric confidence_threshold '
        'and margin_threshold values.',
      );
    }

    final confidence = confidenceValue.toDouble();
    final margin = marginValue.toDouble();
    if (!confidence.isFinite || confidence < 0 || confidence > 1) {
      throw FormatException(
        'Invalid classifier confidence threshold: $confidence.',
      );
    }
    if (!margin.isFinite || margin < 0 || margin > 1) {
      throw FormatException('Invalid classifier margin threshold: $margin.');
    }

    return ClassifierDecisionThresholds(confidence: confidence, margin: margin);
  }

  static void _validateModelContract(
    Interpreter interpreter,
    List<String> labels,
  ) {
    final inputTensors = interpreter.getInputTensors();
    final outputTensors = interpreter.getOutputTensors();

    if (inputTensors.length != 1 || outputTensors.length != 1) {
      throw StateError(
        'Expected one model input and one model output, found '
        '${inputTensors.length} and ${outputTensors.length}.',
      );
    }

    final input = inputTensors.single;
    final output = outputTensors.single;
    const expectedInputShape = [1, inputSize, inputSize, 3];
    final expectedOutputShape = [1, labels.length];

    if (!_sameShape(input.shape, expectedInputShape) ||
        input.type != TensorType.float32) {
      throw StateError(
        'Unsupported model input: expected float32 $expectedInputShape, '
        'found ${input.type} ${input.shape}.',
      );
    }
    if (!_sameShape(output.shape, expectedOutputShape) ||
        output.type != TensorType.float32) {
      throw StateError(
        'Unsupported model output: expected float32 $expectedOutputShape, '
        'found ${output.type} ${output.shape}.',
      );
    }
  }

  static bool _sameShape(List<int> actual, List<int> expected) {
    if (actual.length != expected.length) return false;
    for (int index = 0; index < actual.length; index++) {
      if (actual[index] != expected[index]) return false;
    }
    return true;
  }

  Future<ClassificationResult> classify(String imagePath) async {
    if (!_isLoaded || _interpreter == null) await loadModel();
    final thresholds = _thresholds;
    if (thresholds == null) {
      throw StateError('Classifier decision thresholds are not loaded.');
    }

    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) {
      throw const FormatException('Could not decode image.');
    }

    final oriented = img.bakeOrientation(original);
    final resized = img.copyResize(
      oriented,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    // ResNet50 preprocess_input is embedded in the exported model. Feed raw
    // RGB values in the 0-255 range so preprocessing is applied exactly once.
    final buffer = Float32List(inputSize * inputSize * 3);
    int index = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        buffer[index++] = pixel.r.toDouble();
        buffer[index++] = pixel.g.toDouble();
        buffer[index++] = pixel.b.toDouble();
      }
    }

    // Preserve the NHWC rank required by the model's convolution layers.
    final input = buffer.reshape<double>([1, inputSize, inputSize, 3]);
    final output = [List<double>.filled(_labels.length, 0.0)];
    _interpreter!.run(input, output);

    final scores = output.single;
    if (scores.isEmpty || scores.any((score) => !score.isFinite)) {
      throw StateError('The classifier returned invalid output scores.');
    }

    int bestIndex = 0;
    double bestScore = scores.first;
    for (int index = 1; index < scores.length; index++) {
      if (scores[index] > bestScore) {
        bestScore = scores[index];
        bestIndex = index;
      }
    }

    final rankedPredictions = List<RankedPrediction>.generate(
      scores.length,
      (index) => RankedPrediction(
        rawLabel: _labels[index],
        confidence: scores[index].clamp(0.0, 1.0).toDouble(),
        classIndex: index,
      ),
    )..sort((a, b) => b.confidence.compareTo(a.confidence));

    final topScore = rankedPredictions.first.confidence;
    final secondScore = rankedPredictions.length > 1
        ? rankedPredictions[1].confidence
        : 0.0;
    final top1Top2Margin = topScore - secondScore;
    final status =
        thresholds.accepts(topScore: topScore, top1Top2Margin: top1Top2Margin)
        ? ScanStatus.success
        : ScanStatus.lowConfidence;

    return ClassificationResult(
      rawLabel: _labels[bestIndex],
      confidence: bestScore.clamp(0.0, 1.0).toDouble(),
      classIndex: bestIndex,
      status: status,
      rankedPredictions: rankedPredictions.take(3).toList(growable: false),
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = const [];
    _thresholds = null;
    _isLoaded = false;
  }
}
