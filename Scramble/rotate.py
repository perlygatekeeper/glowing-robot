#!/opt/local/bin/python

def rotate_bits_90_clockwise(bytearray_input):
  """Rotates the bits in a bytearray of length 8 by 90 degrees clockwise."""

  rotated_bytearray = bytearray(8)

  print("Input bytearray:", bytearray_input)  # Print input array

  for i in range(8):
    bit = 4;
    # Isolate the bit in each row, starting from the top row
    bit = (bytearray_input[i] >> 7) & 1

    # Place the bit in the corresponding column of the rotated array
    for j in range(8):
      rotated_bytearray[j] |= bit << (7 - j)

    # Shift the bytearray to the left for the next iteration
    # print(bytearray_input[i])
    bytearray_input[i] = ( bytearray_input[i] << 1 ) & 255

  print("Rotated bytearray:", rotated_bytearray)  # Print output array

  return rotated_bytearray

bytearray_input = bytearray([ 0b10101010, 0b00101010, 0b01101010, 0b01011010, 0b00101000, 0b11111111, 0b00000000, 0b01010101 ])
rotate_bits_90_clockwise(bytearray_input)  # This will print both input and output arrays

