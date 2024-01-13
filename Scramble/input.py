#!/opt/local/bin/python

import sys


def bytearray_to_8x8_bits(input_bytearray):
 """Converts a bytearray of length 8 into an 8x8 grid of bits."""
#if len(input_bytearray) != 8:
#  raise ValueError("Input bytearray must have length 8")
 for byte in input_bytearray:
     print(f"{byte:08b}")


def read_8_bytes_at_a_time(input_source):
  """Reads 8 bytes at a time from a file or standard input.
  Args:
    input_source: The input source, either a filename as a string or '-' for standard input.
  Yields:
    Chunks of 8 bytes as bytearrays.
  Raises:
    ValueError: If the input source is not a valid file or '-'.
  """

  if input_source == '-':
    input_file = sys.stdin.buffer  # Use binary mode for standard input
  elif isinstance(input_source, str):
    try:
      input_file = open(input_source, 'rb')  # Open file in binary mode
    except FileNotFoundError:
      raise ValueError(f"Invalid input source: File '{input_source}' not found")
  else:
    raise ValueError(f"Invalid input source: {input_source}")

  try:
    while True:
      chunk = input_file.read(8)
      if not chunk:
        break
      yield bytearray(chunk)
  finally:
    if input_source != '-':
      input_file.close()

# Example usage with a file:
for chunk in read_8_bytes_at_a_time("input.py"):
  # Process the chunk of 8 bytes
  bytearray_to_8x8_bits(chunk)  # Example usage of previous function

# Example usage with standard input:
for chunk in read_8_bytes_at_a_time("-"):
  # Process the chunk of 8 bytes
  bytearray_to_8x8_bits(chunk)  # Example usage of previous function
