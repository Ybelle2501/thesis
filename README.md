# LeafLens

Flutter app for single-leaf and grid scans of crop conditions, with scan history
and reports.

## ResNet50 classifier

The app bundles the selected dynamic-range ResNet50 export:

- `assets/ResNet50_refined_best.tflite`
- `assets/labels.json` (23 labels in model-output order)
- `assets/ResNet50_decision_thresholds.json`

`lib/services/classifier.dart` corrects image orientation, resizes to 224 x 224
using bilinear interpolation, and supplies RGB float32 values in the 0-255 range
with shape `[1, 224, 224, 3]`. ResNet50 preprocessing is embedded in the model;
do not apply normalization or RGB-to-BGR conversion again in Flutter.
The output is `[1, 23]` float32 softmax probabilities.

The exported confidence and top1-minus-top2 margin thresholds are both `0.0`.
This accepts all valid predictions, including low-confidence results. The export
was not validated on unknown objects and does not provide a no-leaf detector.

The export metadata, deployment notes, tensor contracts, and variant selection
report are retained in `docs/models/resnet50/` for reference. The app reads the
numeric-keyed `labels.json`, whose order matches the export's `labels.txt`.

## Development

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

After changing a bundled model, stop the running app and rebuild it so the new
assets are packaged. Test inference on the target device using representative
leaf images to check predictions and performance.

## Treatment and prevention

The four crop tabs cover all 23 model labels with cited treatment and prevention guides. Disease Prevention includes a qualitative seasonal outlook using selectable PAGASA stations. See [guidance sources and seasonal methodology](docs/crop-guidance.md) for evidence, limitations and validation.
