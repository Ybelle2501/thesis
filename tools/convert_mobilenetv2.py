"""Convert the supplied Keras classifier to the app's float32 TFLite contract."""

from __future__ import annotations

import argparse
from pathlib import Path

import tensorflow as tf


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()

    model = tf.keras.models.load_model(args.source, compile=False)
    if model.input_shape != (None, 224, 224, 3):
        raise ValueError(f"Unexpected input shape: {model.input_shape}")
    if model.output_shape != (None, 17):
        raise ValueError(f"Unexpected output shape: {model.output_shape}")

    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    args.destination.parent.mkdir(parents=True, exist_ok=True)
    args.destination.write_bytes(tflite_model)

    interpreter = tf.lite.Interpreter(model_content=tflite_model)
    interpreter.allocate_tensors()
    input_detail = interpreter.get_input_details()
    output_detail = interpreter.get_output_details()
    print(f"Wrote {args.destination} ({len(tflite_model)} bytes)")
    print(f"Input: {input_detail[0]['shape'].tolist()} {input_detail[0]['dtype']}")
    print(f"Output: {output_detail[0]['shape'].tolist()} {output_detail[0]['dtype']}")


if __name__ == "__main__":
    main()
