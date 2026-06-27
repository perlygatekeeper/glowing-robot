#!/usr/bin/env python3
import random
import re
import readline
from os import system, name
from sys import exit
import argparse
from collections import Counter

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
    "puzzle_size", nargs="?", type=int, default=4,
    help="Number of digits in the puzzle (default: 4)",
)
parser.add_argument(
    "--range", "-r", dest="digit_range", type=int, default=10, metavar="N",
    help="Use the N left-most digits from 0-F, N must be 2-16 (default: 10)",
)
parser.add_argument(
    "--no-duplicates", "-u", dest="no_duplicates", action="store_true",
    help="Puzzle digits are all unique (no repeated digits)",
)

args        = parser.parse_args()
puzzle_size   = args.puzzle_size
digit_range   = args.digit_range
no_duplicates = args.no_duplicates

if not (2 <= digit_range <= 16):
    parser.error("--range must be between 2 and 16")

ALL_SYMBOLS = "0123456789ABCDEF"
SYMBOLS     = ALL_SYMBOLS[:digit_range]

if no_duplicates and puzzle_size > digit_range:
    parser.error(
        f"puzzle_size ({puzzle_size}) exceeds digit_range ({digit_range}) "
        "- not enough unique digits to fill the puzzle"
    )

SEP_LINE = "=" * (56 + digit_range)

# ---------------------------------------------------------------------------
# readline setup
# ---------------------------------------------------------------------------
# Ctrl-L sentinel: a private-use Unicode char that can't appear in any guess.
# We bind Ctrl-L to insert it; after input() returns we check for it.
_REDRAW_SENTINEL = "\U0010FFFD"

readline.parse_and_bind("tab: complete")
readline.parse_and_bind('"' + chr(12) + '": "' + _REDRAW_SENTINEL + '"')

# ---------------------------------------------------------------------------
# Game state (module-level so the startup_hook closure can see it)
# ---------------------------------------------------------------------------
guess_history: list = []

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def clear():
    if name == "nt":
        _ = system("cls")
    else:
        _ = system("clear")


def describe_settings() -> str:
    dup_str = "no duplicates" if no_duplicates else "duplicates allowed"
    return (
        f"Puzzle: {puzzle_size} digits  |  "
        f"Pool: {SYMBOLS} ({digit_range} symbols)  |  {dup_str}"
    )


def draw_screen(extra_msg: str = ""):
    """Redraw the full game screen."""
    clear()
    print(SEP_LINE)
    print("  M A S T E R M I N D")
    print(SEP_LINE)
    print(f"  {describe_settings()}")
    print(f"  up/down: history | Ctrl-L: redraw | end with ?: cheat | q: quit")
    print(SEP_LINE)
    print(f"\nPast guesses ({len(guess_history)}):")
    print_history(guess_history)
    if extra_msg:
        print(extra_msg)


def make_puzzle(size: int, symbols: str, unique: bool) -> tuple:
    pool = list(symbols)
    if unique:
        return tuple(random.sample(pool, size))
    return tuple(random.choices(pool, k=size))


def parse_guess(raw: str, symbols: str) -> list:
    pattern = "[" + re.escape(symbols) + re.escape(symbols.lower()) + "]"
    tokens = re.findall(pattern, raw)
    return [t.upper() for t in tokens] if tokens else []


def determine_number_correct(puzzle: tuple, guess: list) -> int:
    p_counts = Counter(puzzle)
    g_counts = Counter(guess)
    return sum(min(p_counts[sym], g_counts[sym]) for sym in p_counts)


def determine_number_in_place(puzzle: tuple, guess: list) -> int:
    return sum(p == g for p, g in zip(puzzle, guess))


def process_guess(puzzle: tuple, raw: str) -> dict:
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
    guess_history.append({"guess": guess, "correct": correct, "in_place": in_place})
    return {"correct": correct, "in_place": in_place}


def format_guess(event: dict) -> str:
    g = " ".join(event["guess"])
    return f"{g}: ({event['correct']} correct, {event['in_place']} in place)"


def print_history(history: list):
    if history:
        for event in history:
            print(" ", format_guess(event))
    else:
        print("  (none yet)")


def cheat(candidate_raw: str):
    candidate = parse_guess(candidate_raw, SYMBOLS)
    if len(candidate) != puzzle_size:
        print(f"\n  !  Cheat needs {puzzle_size} valid symbol(s), got {len(candidate)}.")
        return
    cand_tuple = tuple(candidate)
    print(f"\n  Cheat - scoring history as if answer were: {' '.join(candidate)}")
    col = puzzle_size * 2
    print(f"  {'Guess':<{col}}  correct  in-place")
    print(f"  {'-' * (col + 18)}")
    for event in guess_history:
        g = event["guess"]
        c = determine_number_correct(cand_tuple, g)
        p = determine_number_in_place(cand_tuple, g)
        print(f"  {' '.join(g):<{col}}  {c:^7}  {p:^8}")
    if not guess_history:
        print("  (no guesses yet)")
    print()


def ordinal(n: int) -> str:
    suffix = "th" if 11 <= (n % 100) <= 13 else {1: "st", 2: "nd", 3: "rd"}.get(n % 10, "th")
    return f"{n}{suffix}"


def game_input(prompt: str) -> str:
    """
    Wrapper around input() that handles the Ctrl-L redraw sentinel in a loop.
    When the user presses Ctrl-L, readline inserts _REDRAW_SENTINEL into the
    buffer and input() returns it immediately (they hit no Enter — readline
    treats the inserted text as the line). We detect it, redraw, and re-prompt.
    """
    while True:
        raw = input(prompt)
        if _REDRAW_SENTINEL in raw:
            draw_screen()
        else:
            return raw

# ---------------------------------------------------------------------------
# Main game
# ---------------------------------------------------------------------------
puzzle  = make_puzzle(puzzle_size, SYMBOLS, no_duplicates)
guesses = 0

# DEBUG - uncomment to reveal the answer:
# print("DEBUG answer:", puzzle)

draw_screen()

while True:
    guesses += 1
    # The prompt must be a single, purely printable line with no embedded
    # newlines or escape sequences.  Readline measures its visible length to
    # track cursor position during history navigation; a stray \n throws that
    # count off by one, causing the first character of recalled lines to
    # bleed left into the prompt area.  Print the blank line separately and
    # pad the guess number to a fixed width (4 digits = up to 9999 guesses)
    # so the prompt length never changes between turns.
    print()
    prompt = f"  Guess #{guesses:<4d}- enter {puzzle_size} symbol(s) from [{SYMBOLS}], or q: "
    try:
        user_input = game_input(prompt).strip()
    except (EOFError, KeyboardInterrupt):
        print("\nGoodbye!")
        break

    if user_input.lower() == "q":
        answer = " ".join(puzzle)
        print(f"\nOK, quitting. The answer was: {answer}")
        break

    if user_input == "":
        print("  Please enter something!")
        guesses -= 1
        continue

    # --- Cheat mode: input ending with '?' ---
    if user_input.endswith("?"):
        cheat(user_input[:-1].strip())
        guesses -= 1
        continue

    # --- Normal guess ---
    results = process_guess(puzzle, user_input)

    if "error" in results:
        draw_screen(extra_msg=f"\n  !  {results['error']}")
        guesses -= 1
        continue

    if results["correct"] == results["in_place"] == puzzle_size:
        draw_screen()
        print(f"\n  YOU SOLVED IT ON YOUR {ordinal(guesses)} GUESS!\n")
        break
    else:
        draw_screen(
            extra_msg=f"\n  Last guess -> {results['correct']} correct digit(s), "
                      f"{results['in_place']} in the right position."
        )
