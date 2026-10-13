#!/usr/bin/env python3
"""Train a seven-segment network for digits, selected symbols, and NOTHING."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path

import numpy as np


DIGIT_PATTERNS = {
    "0": [0b00111111], "1": [0b00000110], "2": [0b01011011],
    "3": [0b01001111], "4": [0b01100110], "5": [0b01101101],
    "6": [0b01111101], "7": [0b00000111], "8": [0b01111111],
    "9": [0b01101111],
}

# These are the interpretations recorded in Notes.txt.  J has two accepted
# segment forms there; the other requested symbols have one form each.
SYMBOL_PATTERNS = {
    "J": [0b0001110, 0b0011110],
    "L": [0b0111000],
    "C": [0b0111001],
    "G": [0b0111101],
    "U": [0b0111110],
    "-": [0b1000000],
    "?": [0b1010011],
    "n": [0b1010100],
    "c": [0b1011000],
    "o": [0b1011100],
    "d": [0b1011110],
    "F": [0b1110001],
    "P": [0b1110011],
    "H": [0b1110110],
    "A": [0b1110111],
    "t": [0b1111000],
    "E": [0b1111001],
}

CLASS_NAMES = list(DIGIT_PATTERNS) + list(SYMBOL_PATTERNS) + ["NOTHING"]
LABEL_BY_PATTERN = {
    pattern: label
    for label, patterns in (DIGIT_PATTERNS | SYMBOL_PATTERNS).items()
    for pattern in patterns
}


def segments(pattern: int) -> list[int]:
    """Return the seven binary inputs in A, B, C, D, E, F, G order."""
    return [(pattern >> bit) & 1 for bit in range(7)]


def create_training_data(path: Path) -> None:
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(["pattern", "binary", *list("ABCDEFG"), "label"])
        for pattern in range(128):
            writer.writerow(
                [pattern, f"{pattern:07b}", *segments(pattern), LABEL_BY_PATTERN.get(pattern, "NOTHING")]
            )


def read_training_data(path: Path) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    name_to_index = {name: index for index, name in enumerate(CLASS_NAMES)}
    patterns, inputs, labels = [], [], []
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
    values = np.exp(shifted)
    return values / values.sum(axis=1, keepdims=True)


def train(
    x: np.ndarray, y: np.ndarray, hidden_size: int, epochs: int,
    learning_rate: float, seed: int,
) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, float]:
    rng = np.random.default_rng(seed)
    class_count = len(CLASS_NAMES)
    w1 = rng.normal(0.0, np.sqrt(2.0 / 7), (7, hidden_size))
    b1 = np.zeros(hidden_size)
    w2 = rng.normal(0.0, np.sqrt(2.0 / hidden_size), (hidden_size, class_count))
    b2 = np.zeros(class_count)

    # Each class has equal total influence despite NOTHING containing most rows.
    counts = np.bincount(y, minlength=class_count)
    sample_weights = 1.0 / counts[y]
    sample_weights /= sample_weights.sum()

    parameters = [w1, b1, w2, b2]
    first = [np.zeros_like(parameter) for parameter in parameters]
    second = [np.zeros_like(parameter) for parameter in parameters]
    beta1, beta2, epsilon = 0.9, 0.999, 1e-8
    loss = float("inf")

    for step in range(1, epochs + 1):
        hidden_linear = x @ w1 + b1
        hidden = np.maximum(hidden_linear, 0.0)
        probabilities = softmax(hidden @ w2 + b2)
        loss = float(-np.sum(sample_weights * np.log(probabilities[np.arange(len(y)), y] + 1e-12)))

        output_gradient = probabilities.copy()
        output_gradient[np.arange(len(y)), y] -= 1.0
        output_gradient *= sample_weights[:, None]
        dw2 = hidden.T @ output_gradient
        db2 = output_gradient.sum(axis=0)
        hidden_gradient = (output_gradient @ w2.T) * (hidden_linear > 0.0)
        dw1 = x.T @ hidden_gradient
        db1 = hidden_gradient.sum(axis=0)

        for index, (parameter, gradient) in enumerate(zip(parameters, [dw1, db1, dw2, db2])):
            first[index] = beta1 * first[index] + (1.0 - beta1) * gradient
            second[index] = beta2 * second[index] + (1.0 - beta2) * gradient**2
            first_corrected = first[index] / (1.0 - beta1**step)
            second_corrected = second[index] / (1.0 - beta2**step)
            parameter -= learning_rate * first_corrected / (np.sqrt(second_corrected) + epsilon)

    return w1, b1, w2, b2, loss


def predict(x: np.ndarray, w1: np.ndarray, b1: np.ndarray, w2: np.ndarray, b2: np.ndarray) -> np.ndarray:
    return softmax(np.maximum(x @ w1 + b1, 0.0) @ w2 + b2)


def write_predictions(
    path: Path, patterns: np.ndarray, expected: np.ndarray, probabilities: np.ndarray
) -> None:
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(["pattern", "binary", "expected", "predicted", *CLASS_NAMES])
        for pattern, label, row in zip(patterns, expected, probabilities):
            writer.writerow([
                int(pattern), f"{pattern:07b}", CLASS_NAMES[label], CLASS_NAMES[int(row.argmax())],
                *[f"{value:.9f}" for value in row],
            ])


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data", type=Path, default=Path("lcd_symbol_training_data.csv"))
    parser.add_argument("--create-training-data", action="store_true")
    parser.add_argument("--hidden-size", type=int, default=64)
    parser.add_argument("--epochs", type=int, default=15_000)
    parser.add_argument("--learning-rate", type=float, default=0.01)
    parser.add_argument("--seed", type=int, default=7)
    parser.add_argument("--matrices", type=Path, default=Path("lcd_symbol_matrices.npz"))
    parser.add_argument("--predictions", type=Path, default=Path("lcd_symbol_predictions.csv"))
    args = parser.parse_args()

    if args.create_training_data:
        create_training_data(args.data)
        print(f"Created {args.data} with all 128 patterns.")

    patterns, x, y = read_training_data(args.data)
    w1, b1, w2, b2, loss = train(
        x, y, args.hidden_size, args.epochs, args.learning_rate, args.seed
    )
    probabilities = predict(x, w1, b1, w2, b2)
    correct = int(np.sum(probabilities.argmax(axis=1) == y))

    np.savez(
        args.matrices, W1=w1, b1=b1, W2=w2, b2=b2,
        class_names=np.asarray(CLASS_NAMES), segment_order=np.asarray(list("ABCDEFG")),
    )
    write_predictions(args.predictions, patterns, y, probabilities)

    print(f"Classes ({len(CLASS_NAMES)}): {', '.join(CLASS_NAMES)}")
    print(f"Architecture: 7 -> {args.hidden_size} -> {len(CLASS_NAMES)}")
    print(f"Matrix shapes: W1={w1.shape}, b1={b1.shape}, W2={w2.shape}, b2={b2.shape}")
    print(f"Final weighted loss: {loss:.8f}")
    print(f"Training-set accuracy: {correct / len(y):.2%} ({correct}/{len(y)})")
    print(f"Saved learned matrices to {args.matrices}")
    print(f"Saved all probability vectors to {args.predictions}")


if __name__ == "__main__":
    main()
