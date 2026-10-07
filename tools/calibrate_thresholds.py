"""Evaluate the app's confidence-and-margin rule on exported predictions."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path


def metrics(rows: list[dict[str, float | bool]], confidence: float, margin: float) -> dict[str, float]:
    accepted = 0
    correct = 0
    rejected_incorrect = 0
    for row in rows:
        is_accepted = row["confidence"] >= confidence and row["margin"] >= margin
        if is_accepted:
            accepted += 1
            correct += int(bool(row["correct"]))
        elif not bool(row["correct"]):
            rejected_incorrect += 1
    incorrect_total = sum(not bool(row["correct"]) for row in rows)
    return {
        "confidence": confidence,
        "margin": margin,
        "coverage": accepted / len(rows),
        "accepted_accuracy": correct / accepted if accepted else 0.0,
        "accepted": float(accepted),
        "accepted_errors": float(accepted - correct),
        "error_rejection": rejected_incorrect / incorrect_total if incorrect_total else 0.0,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("predictions", type=Path)
    args = parser.parse_args()

    rows: list[dict[str, float | bool]] = []
    with args.predictions.open(newline="", encoding="utf-8") as source:
        reader = csv.DictReader(source)
        probability_columns = [
            name for name in (reader.fieldnames or []) if name.startswith("prob_")
        ]
        for source_row in reader:
            probabilities = sorted(
                (float(source_row[name]) for name in probability_columns), reverse=True
            )
            rows.append(
                {
                    "confidence": probabilities[0],
                    "margin": probabilities[0] - probabilities[1],
                    "correct": source_row["correct"].lower() == "true",
                }
            )

    candidates = [
        metrics(rows, confidence / 100, margin / 100)
        for confidence in range(0, 96)
        for margin in range(0, 91)
    ]
    print(f"Rows: {len(rows)}")
    for confidence, margin in [(0.0, 0.0), (0.60, 0.15)]:
        print(metrics(rows, confidence, margin))
    for minimum_confidence in (0.0, 0.5, 0.6):
        for target in (0.95, 0.97):
            eligible = [
                row
                for row in candidates
                if row["confidence"] >= minimum_confidence
                and row["accepted_accuracy"] >= target
            ]
            if not eligible:
                print(
                    f"No candidate at confidence >= {minimum_confidence:.2f} "
                    f"reaches {target:.0%} accepted accuracy"
                )
                continue
            best = max(
                eligible,
                key=lambda row: (
                    row["coverage"],
                    -row["confidence"],
                    -row["margin"],
                ),
            )
            print(
                f"Max coverage at confidence >= {minimum_confidence:.2f} and "
                f">= {target:.0%} accepted accuracy: {best}"
            )


if __name__ == "__main__":
    main()
