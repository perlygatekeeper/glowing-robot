#!/opt/local/bin/python

def bytearray_to_8x8_bits(bytearray):
 """Converts a bytearray of length 8 into an 8x8 grid of bits."""

 if len(bytearray) != 8:
   raise ValueError("Input bytearray must have length 8")

 bits = []
 for byte in bytearray:
     print(f"{byte:08b}")
 # bits.extend(f"{byte:08b}" for byte in bytearray)

 # row_strings = ["".join(bits[i:i+8]) for i in range(0, 64, 8)]
 # return "\n".join(row_strings)


def rotate_bits_90_clockwise(input):
  """Rotates the bits in a bytearray of length 8 by 90 degrees clockwise."""

  rotated = bytearray(8)

  print("Input bytearray:")
  bytearray_to_8x8_bits(input)

  for row in range(8):    # loop over rows from top to bottom
    set_mask = 1 << row
    for col in range(8):  # loop over cols from right to left
      # bit at input[row,col] will be isolated as a single-one binary number,
      # ie 00010000 for col = 4
      bit = input[row] & (1 << col)
      if (bit):
        rotated[ 7 - col ] |= set_mask
  print("Rotated bytearray:")  # Print output array
  bytearray_to_8x8_bits(rotated)
  return rotated



bytearray_input = bytearray([ 0b10101010, 0b00101010, 0b01101010, 0b01011010, 0b00101000, 0b11111111, 0b00000000, 0b01010101 ])
rotate_bits_90_clockwise(bytearray_input)  # This will print both input and output arrays



