MobileNetV2 - Flutter deployment

Model file: assets/MobileNetV2_best_model.tflite
Input: [1, 224, 224, 3] Float32 RGB, values 0-255
Preprocessing: x / 127.5 - 1 is embedded; do not normalize again in Flutter
Output: [1, 18] Float32 softmax probabilities
Label order: assets/labels.json

Decision mechanic used by the app:
  confidence >= 0.50 AND top1-minus-top2 margin >= 0.30
  suggestion confidence >= 0.10

The values are a conservative usability adjustment. On the 1,173 exported plant
test_predictions.csv rows for this 18-class model, the rule accepted 1,136
predictions (96.85% coverage), with 93.93% accuracy among accepted results, and
rejected 16.87% of the model's errors. This is not an independent calibration
estimate, and no unsupported/non-leaf examples were supplied.

Rebuild the app after changing model assets and verify predictions on a target
device with representative pineapple, banana, lettuce, and tomato images.
