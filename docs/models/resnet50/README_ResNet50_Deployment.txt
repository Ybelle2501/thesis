ResNet50 Refined — Flutter Deployment
================================================

Model file: ResNet50_refined_best.tflite
Input: RGB Float32 [1, 224, 224, 3]
Pixel range supplied by Flutter: 0 to 255
App-side ResNet50 normalization: DO NOT APPLY
Output: 23 Float32 softmax probabilities
Label order: labels.txt

Decision rule:
Accept only when confidence >= 0.0
and top1 - top2 margin >= 0.0.
Otherwise return an uncertain result and request a clearer image.

Use one clear leaf, adequate lighting, and close framing. A confidence
threshold reduces unsupported predictions but does not guarantee that every
unknown object will be rejected.
