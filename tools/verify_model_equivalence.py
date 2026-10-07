"""Compare Keras and TFLite probabilities on deterministic synthetic inputs."""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import tensorflow as tf


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("keras_model", type=Path)
    parser.add_argument("tflite_model", type=Path)
    args = parser.parse_args()

    keras_model = tf.keras.models.load_model(args.keras_model, compile=False)
    interpreter = tf.lite.Interpreter(model_path=str(args.tflite_model))
    interpreter.allocate_tensors()
    input_detail = interpreter.get_input_details()[0]
    output_detail = interpreter.get_output_details()[0]

    rng = np.random.default_rng(20260928)
    batches = [
        np.zeros((1, 224, 224, 3), dtype=np.float32),
        np.full((1, 224, 224, 3), 127.5, dtype=np.float32),
        rng.uniform(0, 255, (1, 224, 224, 3)).astype(np.float32),
    ]
    maximum_difference = 0.0
    for index, values in enumerate(batches):
        keras_output = keras_model(values, training=False).numpy()
        interpreter.set_tensor(input_detail["index"], values)
        interpreter.invoke()
        tflite_output = interpreter.get_tensor(output_detail["index"])
        difference = float(np.max(np.abs(keras_output - tflite_output)))
        maximum_difference = max(maximum_difference, difference)
        if int(np.argmax(keras_output)) != int(np.argmax(tflite_output)):
            raise AssertionError(f"Top-1 mismatch for sample {index}")
        print(f"Sample {index}: max absolute difference {difference:.9g}")
    if maximum_difference > 1e-4:
        raise AssertionError(f"Difference too large: {maximum_difference}")
    print(f"PASS: maximum absolute difference {maximum_difference:.9g}")


if __name__ == "__main__":
    main()
