#!/usr/bin/env python3
import random
import re
import readline
from os import system, name
from sys import argv, exit
import argparse

# ---------------------------------------------------------------------------
# CLI argument parsing
# ---------------------------------------------------------------------------
parser = argparse.ArgumentParser(
    description="Mastermind digit-guessing game",
    formatter_class=argparse.RawDescriptionHelpFormatter,
    epilog="""
Digit pool is always the left-most N symbols from:
  0 1 2 3 4 5 6 7 8 9 A B C D E F

Examples:
  %(prog)s                    # classic 4-digit, 0-9, duplicates allowed
  %(prog)s 5                  # 5-digit puzzle, 0-9, duplicates allowed
  %(prog)s 4 --range 16       # 4-digit, 0-F (hex), duplicates allowed
  %(prog)s 4 --range 6        # 4-digit, 0-5 only, duplicates allowed
  %(prog)s 4 --no-duplicates  # 4-digit, 0-9, no repeated digits
  %(prog)s 5 --range 8 --no-duplicates
""",
)
parser.add_argument(
    "puzzle_size",
    nargs="?",
    type=int,
    default=4,
    help="Number of digits in the puzzle (default: 4)",
)
parser.add_argument(
    "--range", "-r",
    dest="digit_range",
    type=int,
    default=10,
    metavar="N",
    help="Use the N left-most digits from 0-F, N must be 2-16 (default: 10)",
)
parser.add_argument(
    "--no-duplicates", "-u",
    dest="no_duplicates",
    action="store_true",
    help="Puzzle digits are all unique (no repeated digits)",
)

args = parser.parse_args()

puzzle_size   = args.puzzle_size
digit_range   = args.digit_range
no_duplicates = args.no_duplicates

# Validate digit_range
if not (2 <= digit_range <= 16):
    parser.error("--range must be between 2 and 16")

# Build the ordered symbol pool  (0-9 then A-F)
ALL_SYMBOLS = "0123456789ABCDEF"
SYMBOLS = ALL_SYMBOLS[:digit_range]          # e.g. digit_range=12 → "0123456789AB"

# Sanity-check: can't have more unique digits than the pool allows
if no_duplicates and puzzle_size > digit_range:
    parser.error(
        f"puzzle_size ({puzzle_size}) exceeds digit_range ({digit_range}) "
        "– not enough unique digits to fill the puzzle"
    )

# ---------------------------------------------------------------------------
# readline: in-session history, no persistence
# ---------------------------------------------------------------------------
readline.parse_and_bind("tab: complete")   # harmless; keeps readline active
# History is in-memory only – no histfile is set, so nothing is saved/loaded.

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def clear():
    if name == "nt":
        _ = system("cls")
    else:
        _ = system("clear")


def symbol_index(ch: str) -> int:
    """Return the pool-index of a character (case-insensitive)."""
    return SYMBOLS.index(ch.upper())


def make_puzzle(size: int, symbols: str, unique: bool) -> tuple:
    """Generate the secret code."""
    pool = list(symbols)
    if unique:
        return tuple(random.sample(pool, size))
    else:
        return tuple(random.choices(pool, k=size))


def parse_guess(raw: str, symbols: str) -> list | None:
    """
    Extract valid symbol characters from raw input.
    Returns a list of upper-case chars, or None if the input contains
    characters outside the current symbol pool.
    """
    # Build a regex that matches one character from the pool
    # Hex digits need special handling so we use re.escape per char
    pattern = "[" + re.escape(symbols) + re.escape(symbols.lower()) + "]"
    tokens = re.findall(pattern, raw)
    return [t.upper() for t in tokens] if tokens else []


def determine_number_correct(puzzle: tuple, guess: list) -> int:
    """Digits in common (regardless of position) – classic 'white peg' count."""
    from collections import Counter
    p_counts = Counter(puzzle)
    g_counts = Counter(guess)
    return sum(min(p_counts[sym], g_counts[sym]) for sym in p_counts)


def determine_number_in_place(puzzle: tuple, guess: list) -> int:
    """Digits in the right position – classic 'black peg' count."""
    return sum(p == g for p, g in zip(puzzle, guess))


def process_guess(puzzle: tuple, raw: str, history: list) -> dict:
    guess = parse_guess(raw, SYMBOLS)
    if len(guess) == 0 and len(raw.strip()) > 0:
        return {"error": f"No valid symbols found. Use digits/letters from: {SYMBOLS}"}
    if len(guess) != len(puzzle):
        return {
            "error": f"Expected {len(puzzle)} symbols, got {len(guess)}. "
                     f"Valid pool: {SYMBOLS}"
        }
    correct  = determine_number_correct(puzzle, guess)
    in_place = determine_number_in_place(puzzle, guess)
    history.append({"guess": guess, "correct": correct, "in_place": in_place})
    return {"correct": correct, "in_place": in_place}


def format_guess(event: dict) -> str:
    g = " ".join(event["guess"])
    return f"{g}: ({event['correct']} correct, {event['in_place']} in place)"


def print_history(history: list):
    if history:
        for event in history:
            print(" ", format_guess(event))
    else:
        print("  (no history of guesses yet)")


def describe_settings() -> str:
    dup_str = "no duplicates" if no_duplicates else "duplicates allowed"
    return (
        f"Puzzle: {puzzle_size} digits | Pool: {SYMBOLS} ({digit_range} symbols) | {dup_str}"
    )

# ---------------------------------------------------------------------------
# Main game
# ---------------------------------------------------------------------------
puzzle       = make_puzzle(puzzle_size, SYMBOLS, no_duplicates)
guesses      = 0
guess_history: list = []

# DEBUG – uncomment to reveal the answer:
# print("DEBUG answer:", puzzle)

line = 56 + args.digit_range
clear()
print("=" * line)
print(" M A S T E R M I N D")
print("=" * line)
print(f" {describe_settings()}")
print(" Use ↑/↓ to navigate your input history. Type 'q' to quit.")
print("=" * line)

while True:
    guesses += 1
    print(f"\nPast guesses ({guesses - 1}):")
    print_history(guess_history)

    prompt = f"\n  Guess #{guesses} – enter {puzzle_size} symbol(s) from [{SYMBOLS}], or q: "
    try:
        user_input = input(prompt).strip()
    except (EOFError, KeyboardInterrupt):
        print("\nGoodbye!")
        break

    if user_input.lower() == "q":
        answer = " ".join(puzzle)
        print(f"\nOK, quitting. The answer was: {answer}")
        break

    if user_input == "":
        print("  Please enter something!")
        guesses -= 1          # don't count the blank as a guess
        continue

    results = process_guess(puzzle, user_input, guess_history)

    clear()
    print("=" * line)
    print("  M A S T E R M I N D")
    print("=" * line)
    print(f"  {describe_settings()}")
    print("=" * line)

    if "error" in results:
        print(f"\n  ⚠  {results['error']}")
        guesses -= 1          # invalid input doesn't count
        continue

    if results["correct"] == results["in_place"] == puzzle_size:
        print(f"\n  🎉  YOU SOLVED IT IN {guesses} GUESS{'ES' if guesses != 1 else ''}!\n")
        print("Full history:")
        print_history(guess_history)
        print()
        break
    else:
        print(
            f"\n  Last guess → {results['correct']} correct digit(s), "
            f"{results['in_place']} in the right position."
        )
