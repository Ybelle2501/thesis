# LeafLens

Flutter app for single-leaf and grid scans of crop conditions, with scan history
and reports.

## MobileNetV2 classifier

The app bundles the converted MobileNetV2 export:

- `assets/MobileNetV2_best_model.tflite`
- `assets/labels.json` (17 labels in model-output order)
- `assets/MobileNetV2_decision_thresholds.json`

`lib/services/classifier.dart` corrects image orientation, resizes to 224 x 224
using bilinear interpolation, and supplies RGB float32 values in the 0-255 range
with shape `[1, 224, 224, 3]`. MobileNetV2 preprocessing (`x / 127.5 - 1`)
is embedded in the model, so Flutter supplies raw RGB values in the 0-255
range. The output is `[1, 17]` float32 softmax probabilities.

The deployment rule retains the existing mechanics: accept a result only when
both its top score is at least `0.60` and its top-1/top-2 margin is at least
`0.38`; disease alternatives require `0.10`. On the 1,378 exported held-out test
predictions, this rule accepted 95.50% at 95.06% accepted-result accuracy and
rejected 29.35% of errors. Because the same test export was used to select the
margin and contains no unsupported/non-leaf images, independent calibration and
out-of-distribution validation are still required before deployment claims.

Conversion and contract notes are in `docs/models/mobilenetv2/`. The previous
ResNet50 documentation remains in `docs/models/resnet50/` as historical reference.

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

The four crop tabs cover all 17 model labels with cited treatment and prevention guides. Pineapple replaces eggplant, and the tomato library follows the new six-class taxonomy. Disease Prevention includes a qualitative seasonal outlook using selectable PAGASA stations. See [guidance sources and seasonal methodology](docs/crop-guidance.md) for evidence, limitations and validation.
