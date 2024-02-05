#!/opt/local/bin/python

import Scramble
import sys
import argparse

''' Preloop
       Parse Arguments (if any)
       Determine if Scrambling or Unscrambling 
       Generate and output random block - OR - read random block if Unscrambling
       Determine Parameters from random block
     Loop
       Read input block
       Determine and save Parameters for next block if Scrambling
       Scramble block - OR - UNscramble block ( this should use parameters from previous clear block )
                                                but may also use parameters from the present block for the purposes of inversion
       Determine and save Parameters for next block if Unscrambling
       Output Scrambled or Unscrambled block
'''

# Create a parser object
parser = argparse.ArgumentParser(description="Process input filename")

# Add a required argument for the input filename
parser.add_argument("input_filename",  default="-", type=str, help="The path to the input file")
parser.add_argument("output_filename", default="-", type=str, help="The path to the input file")

# Parse the arguments
args = parser.parse_args()

data = bytearray(b'\x01\x02\x03\x04\x05\x06\x07\x08')

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
#  Transforms
#   rotate_90_CCW, rotate_90_CW, rotate_180
#   flip_horizontal, flip_vertical
#   horizontal_sheer, vertical_sheer
#   invert
# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

transformer = ByteTransformer(data)

transformer.reverse_bytes()
print(transformer.to_hex_string())  # Output: 0807060504030201

transformer.increment_bytes()
print(transformer.to_hex_string())  # Output: 0908070605040302

# Access the input filename from the parsed arguments
input_filename  = args.input_filename
output_filename = args.output_filename

# Print the parsed input filename
print("Input filename:",  input_filename)
print("Output filename:", output_filename)

# Now you can use the input_filename variable in your code to access the file's contents

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

# --------------------------------------------------------------------------------

# Example usage with a file:
if (0):
  for chunk in read_8_bytes_at_a_time("input.py"):
    # Process the chunk of 8 bytes
    bytearray_to_8x8_bits(chunk)  # Example usage of previous function
# Example usage with standard input:
if (1):
  for chunk in read_8_bytes_at_a_time("-"):
    # Process the chunk of 8 bytes
    bytearray_to_8x8_bits(chunk)  # Example usage of previous function


if (0):
  print("Clockwise Rotation:")
  bytearray_input = bytearray([ 0b10101010, 0b00101010, 0b01101010, 0b01011010, 0b00101000, 0b11111111, 0b00000000, 0b01010101 ])
  rotate_bits_90_clockwise(bytearray_input)  # This will print both input and output arrays
  print("Counter-Clockwise Rotation:")
  bytearray_input = bytearray([ 0b10101010, 0b00101010, 0b01101010, 0b01011010, 0b00101000, 0b11111111, 0b00000000, 0b01010101 ])
  rotate_bits_90_counter_clockwise(bytearray_input)
  print("180 Rotation:")
  bytearray_input = bytearray([ 0b10101010, 0b00101010, 0b01101010, 0b01011010, 0b00101000, 0b11111111, 0b00000000, 0b01010101 ])
  rotate_bits_180(bytearray_input)
  print("Inversion:")
  bytearray_input = bytearray([ 0b10101010, 0b00101010, 0b01101010, 0b01011010, 0b00101000, 0b11111111, 0b00000000, 0b01010101 ])
  invert_bits(bytearray_input)
  print("Horizontal shift 1:")
  bytearray_input = bytearray([ 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001 ])
  horizontal_sheer(bytearray_input, 1)
  print("Horizontal shift 2:")
  bytearray_input = bytearray([ 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001 ])
  horizontal_sheer(bytearray_input, 2)
  print("Horizontal shift 7:")
  bytearray_input = bytearray([ 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001 ])
  horizontal_sheer(bytearray_input, 7)
  print("Vertically shift 1:")
  bytearray_input = bytearray([ 0b11111111, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000 ])
  vertical_sheer(bytearray_input, 1)
  print("Vertically shift 3:")
  bytearray_input = bytearray([ 0b11111111, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000 ])
  vertical_sheer(bytearray_input, 3)
  print("Vertically shift 7:")
  bytearray_input = bytearray([ 0b11111111, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000 ])
  vertical_sheer(bytearray_input, 7)
  print("Paramters Checks:\n")
  bytearray_input = bytearray([ 0b11111110, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000001 ])
  parameters(bytearray_input)
  bytearray_input = bytearray([ 0b10101010, 0b00101010, 0b01101010, 0b01011010, 0b00101000, 0b11111111, 0b00000000, 0b01010101 ])
  parameters(bytearray_input)

# --------------------------------------------------------------------------------
