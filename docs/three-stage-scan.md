# Three-stage offline scan

Single-image camera and gallery scans use `ThreeStageScanService`. Every grid
cell also uses that service after cropping, so each cell invokes Stage 1 and
returns immediately on rejection or uncertainty, invokes Stage 2 only after
Stage 1 acceptance, and invokes the existing disease classifier only after
Stage 2 accepts a supported crop and the Stage 3 labels contain that crop. Grid
cropping, cell progress, result aggregation, and history behavior remain in
`GridScanService` and the existing grid result screen.

The Stage 1 and Stage 2 export metadata identifies 224 x 224 RGB inputs in the
0–255 range with `tf.keras.applications.mobilenet_v2.preprocess_input`. Both
TFLite graphs start with `MUL` and `SUB` preprocessing operators and end with a
`SOFTMAX`; normalization is embedded in each model. The app corrects image
orientation, resizes using bilinear interpolation, and provides float32 RGB
values in the raw 0–255 range. The verified tensor contracts are `[1,224,224,3]`
float32 input with `[1,2]` and `[1,5]` float32 gate outputs. Stage 3 continues
to use its existing classifier and preprocessing implementation.

Stage 1's label file uses `non_plant` and `plant`; the pipeline compares the
actual `plant` label. Its `0.50` confidence and `0.10` top-two margin values
come from the supplied Stage 1 `thresholds.json`. The export reports zero
unknown validation images, so the values remain provisional for camera use.

The Stage 2 export has no threshold file. The workspace's configurable
`stage2_threshold.json` values (`0.65` confidence and `0.15` margin) are marked
provisional and are not calibrated probabilities. Replace them only after
calibration on a dedicated validation set that includes supported crops and
diverse unsupported plants. Each threshold file also records its status.

The gate models are independently loaded and validated against their label
counts and tensor shapes. Any loading, decoding, preprocessing, or inference
error throws before the next stage can run. Stage 3 treatment and prevention
content remains local in `crop_guides.dart` and is shown through the existing
result screens.
