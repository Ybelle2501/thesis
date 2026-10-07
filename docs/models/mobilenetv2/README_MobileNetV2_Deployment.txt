MobileNetV2 - Flutter deployment

Model file: assets/MobileNetV2_best_model.tflite
Input: [1, 224, 224, 3] Float32 RGB, values 0-255
Preprocessing: x / 127.5 - 1 is embedded; do not normalize again in Flutter
Output: [1, 17] Float32 softmax probabilities
Label order: assets/labels.json

Decision mechanic retained from the app:
  confidence >= 0.60 AND top1-minus-top2 margin >= 0.38
  suggestion confidence >= 0.10

Threshold selection used the 1,378 exported test_predictions.csv rows. The new
rule accepted 1,316 predictions (95.50% coverage), with 95.06% accuracy among
accepted results, and rejected 29.35% of the model's errors. The same export was
used to choose and assess the rule, so those figures are not an independent
performance estimate. No unsupported/non-leaf examples were supplied.

Rebuild the app after changing model assets and verify predictions on a target
device with representative pineapple, banana, lettuce, and tomato images.
