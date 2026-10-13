#!/usr/bin/env python3
"""Train a tiny neural network to classify seven-segment display patterns.

The input convention is GFEDCBA in the integer pattern and A..G in the
feature columns.  Classes 0..9 are the conventional decimal glyphs; every
other one of the 128 possible patterns is labelled NOTHING.
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path

import numpy as np


CLASS_NAMES = [str(digit) for digit in range(10)] + ["NOTHING"]
DIGIT_PATTERNS = {
    0: 0b00111111,
    1: 0b00000110,
    2: 0b01011011,
    3: 0b01001111,
    4: 0b01100110,
    5: 0b01101101,
    6: 0b01111101,
    7: 0b00000111,
    8: 0b01111111,
    9: 0b01101111,
}
PATTERN_TO_DIGIT = {pattern: digit for digit, pattern in DIGIT_PATTERNS.items()}


def segments(pattern: int) -> list[int]:
    """Return the seven inputs in A, B, C, D, E, F, G order."""
    return [(pattern >> bit) & 1 for bit in range(7)]


def create_training_data(path: Path) -> None:
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(["pattern", "binary", "A", "B", "C", "D", "E", "F", "G", "label"])
        for pattern in range(128):
            label = str(PATTERN_TO_DIGIT.get(pattern, "NOTHING"))
            writer.writerow([pattern, f"{pattern:07b}", *segments(pattern), label])


def read_training_data(path: Path) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    patterns: list[int] = []
    inputs: list[list[float]] = []
    labels: list[int] = []
    name_to_index = {name: index for index, name in enumerate(CLASS_NAMES)}

    with path.open(newline="", encoding="utf-8") as file:
        for row in csv.DictReader(file):
            patterns.append(int(row["pattern"]))
            inputs.append([float(row[name]) for name in "ABCDEFG"])
            labels.append(name_to_index[row["label"]])

    if len(inputs) != 128:
        raise ValueError(f"Expected 128 training rows, found {len(inputs)}")
    return np.asarray(patterns), np.asarray(inputs), np.asarray(labels)


def softmax(scores: np.ndarray) -> np.ndarray:
    shifted = scores - scores.max(axis=1, keepdims=True)
    exponentials = np.exp(shifted)
    return exponentials / exponentials.sum(axis=1, keepdims=True)


def train(
    x: np.ndarray,
    y: np.ndarray,
    hidden_size: int,
    epochs: int,
    learning_rate: float,
    seed: int,
) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, list[float]]:
    rng = np.random.default_rng(seed)
    w1 = rng.normal(0.0, np.sqrt(2.0 / 7), size=(7, hidden_size))
    b1 = np.zeros(hidden_size)
    w2 = rng.normal(0.0, np.sqrt(2.0 / hidden_size), size=(hidden_size, 11))
    b2 = np.zeros(11)

    # Give each of the 11 classes equal total influence.  Without this,
    # NOTHING's 118 examples overwhelm the ten single-example digit classes.
    counts = np.bincount(y, minlength=11)
    sample_weights = 1.0 / counts[y]
    sample_weights /= sample_weights.sum()

    parameters = [w1, b1, w2, b2]
    first_moments = [np.zeros_like(value) for value in parameters]
    second_moments = [np.zeros_like(value) for value in parameters]
    beta1, beta2, epsilon = 0.9, 0.999, 1e-8
    losses: list[float] = []

    for step in range(1, epochs + 1):
        hidden_linear = x @ w1 + b1
        hidden = np.maximum(hidden_linear, 0.0)
        probabilities = softmax(hidden @ w2 + b2)

        loss = -np.sum(sample_weights * np.log(probabilities[np.arange(len(y)), y] + 1e-12))
        losses.append(float(loss))

        output_gradient = probabilities.copy()
        output_gradient[np.arange(len(y)), y] -= 1.0
        output_gradient *= sample_weights[:, None]

        dw2 = hidden.T @ output_gradient
        db2 = output_gradient.sum(axis=0)
        hidden_gradient = (output_gradient @ w2.T) * (hidden_linear > 0.0)
        dw1 = x.T @ hidden_gradient
        db1 = hidden_gradient.sum(axis=0)

        for index, (parameter, gradient) in enumerate(zip(parameters, [dw1, db1, dw2, db2])):
            first_moments[index] = beta1 * first_moments[index] + (1.0 - beta1) * gradient
            second_moments[index] = beta2 * second_moments[index] + (1.0 - beta2) * gradient**2
            corrected_first = first_moments[index] / (1.0 - beta1**step)
            corrected_second = second_moments[index] / (1.0 - beta2**step)
            parameter -= learning_rate * corrected_first / (np.sqrt(corrected_second) + epsilon)

    return w1, b1, w2, b2, losses


def predict(x: np.ndarray, matrices: tuple[np.ndarray, ...]) -> np.ndarray:
    w1, b1, w2, b2 = matrices
    hidden = np.maximum(x @ w1 + b1, 0.0)
    return softmax(hidden @ w2 + b2)


def write_predictions(path: Path, patterns: np.ndarray, y: np.ndarray, probabilities: np.ndarray) -> None:
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(["pattern", "binary", "expected", "predicted", *CLASS_NAMES])
        for pattern, expected, row in zip(patterns, y, probabilities):
            writer.writerow(
                [int(pattern), f"{pattern:07b}", CLASS_NAMES[expected], CLASS_NAMES[int(row.argmax())],
                 *[f"{value:.9f}" for value in row]]
            )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data", type=Path, default=Path("lcd_training_data.csv"))
    parser.add_argument("--create-training-data", action="store_true")
    parser.add_argument("--hidden-size", type=int, default=32)
    parser.add_argument("--epochs", type=int, default=10_000)
    parser.add_argument("--learning-rate", type=float, default=0.01)
    parser.add_argument("--seed", type=int, default=7)
    parser.add_argument("--matrices", type=Path, default=Path("lcd_matrices.npz"))
    parser.add_argument("--predictions", type=Path, default=Path("lcd_predictions.csv"))
    args = parser.parse_args()

    if args.create_training_data:
        create_training_data(args.data)
        print(f"Created {args.data} with all 128 patterns.")

    patterns, x, y = read_training_data(args.data)
    w1, b1, w2, b2, losses = train(
        x, y, args.hidden_size, args.epochs, args.learning_rate, args.seed
    )
    probabilities = predict(x, (w1, b1, w2, b2))
    accuracy = float(np.mean(probabilities.argmax(axis=1) == y))

    np.savez(
        args.matrices,
        W1=w1,
        b1=b1,
        W2=w2,
        b2=b2,
        class_names=np.asarray(CLASS_NAMES),
        segment_order=np.asarray(list("ABCDEFG")),
    )
    write_predictions(args.predictions, patterns, y, probabilities)

    print(f"Architecture: 7 -> {args.hidden_size} -> 11")
    print(f"Matrix shapes: W1={w1.shape}, b1={b1.shape}, W2={w2.shape}, b2={b2.shape}")
    print(f"Final weighted loss: {losses[-1]:.8f}")
    print(f"Training-set accuracy: {accuracy:.2%} ({int(accuracy * len(y))}/{len(y)})")
    print(f"Saved learned matrices to {args.matrices}")
    print(f"Saved all probability vectors to {args.predictions}")


if __name__ == "__main__":
    main()
