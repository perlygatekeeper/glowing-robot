#!/usr/bin/env python3
import hashlib
import re
import sys
from pathlib import Path

def generate_prime_filename(original_filename):

    with open(original_filename, "r") as f:
        content = f.read()

    # Extract all digits
    n_str = ''.join(re.findall(r'\d', content))

    if not n_str:
        raise ValueError("No digits found in file.")

    h = hashlib.sha256(n_str.encode()).hexdigest()[:6].upper()

    new_name = (
        f"P{len(n_str)}_"
        f"{n_str[:5]}_"
        f"{n_str[-5:]}_"
        f"{h}.txt"
    )

    return new_name


if __name__ == "__main__":

    if len(sys.argv) != 2:
        print(f"Usage: python {Path(sys.argv[0]).name} <prime_file>")
        sys.exit(1)

    original_file = sys.argv[1]

    try:
        new_filename = generate_prime_filename(original_file)
        print(new_filename)

    except Exception as e:
        print(f"Error: {e}")
