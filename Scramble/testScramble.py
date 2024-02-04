#!/opt/local/bin/python

import ByteTransformer

print("Object initialized to all ones:")
original = ByteTransformer.ByteTransformer(b'\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF')
original.print_as_bit_array("Object printed as bit array:")


print("Parameters:")
original = ByteTransformer.ByteTransformer(b'\xa1\x02\x03\x04\x05\x06\x07\x08')
original.parameters()

original    = ByteTransformer.ByteTransformer(b'\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF')
transformer = ByteTransformer.ByteTransformer(b'\x00\x00\x00\x00\x00\x00\x00\x00')
print("Ones    \tZeroes:")
original.print_comparison(transformer)

original    = ByteTransformer.ByteTransformer(b'\xa1\x02\x03\x04\x05\x06\x07\x08')

# increments/decrements

transformer = ByteTransformer.ByteTransformer(b'\xa1\x02\x03\x04\x05\x06\x07\x08')
transformer.increment_bytes()
print("Original\tBytes Incremented:")
original.print_comparison(transformer)

transformer = ByteTransformer.ByteTransformer(b'\xa1\x02\x03\x04\x05\x06\x07\x08')
transformer.decrement_bytes()
print("Original\tBytes Decremented:")
original.print_comparison(transformer)

# inversion
print("\n-------------------------------\ninvert\n")

transformer = ByteTransformer.ByteTransformer(b'\x55\xAA\x55\xAA\x55\xAA\x55\xAA')
transformer.invert()
print("Original\tInverted:")
original.print_comparison(transformer)

print("\n-------------------------------\nRotations\n")

original    = ByteTransformer.ByteTransformer(b'\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')

transformer = ByteTransformer.ByteTransformer(b'\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')
transformer.rotate_180()
print("Original\tRotated 180:")
original.print_comparison(transformer)

transformer = ByteTransformer.ByteTransformer(b'\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')
transformer.rotate_90_CW()
print("Original\tRotated 90 CW:")
original.print_comparison(transformer)

transformer = ByteTransformer.ByteTransformer(b'\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')
transformer.rotate_90_CCW()
print("Original\tRotated 90 CCW:")
original.print_comparison(transformer)

print("\n-------------------------------\nFlips\n")
original    = ByteTransformer.ByteTransformer(b'\xF0\xE0\xC0\x80\x00\x00\x00\x00')

transformer = ByteTransformer.ByteTransformer(b'\xF0\xE0\xC0\x80\x00\x00\x00\x00')
transformer.flip_vertically()
print("Original\tFlipped Vertically:")
original.print_comparison(transformer)

transformer = ByteTransformer.ByteTransformer(b'\xF0\xE0\xC0\x80\x00\x00\x00\x00')
transformer.flip_horizontally()
print("Original\tFlipped Horizontal:")
original.print_comparison(transformer)

print("\n-------------------------------\nSheers\n")
original    = ByteTransformer.ByteTransformer(b'\xFF\x00\x00\x00\x00\x00\x00\x00')
transformer = ByteTransformer.ByteTransformer(b'\xFF\x00\x00\x00\x00\x00\x00\x00')
original.print_as_bit_array("Test array for Vertical Sheers")

original    = ByteTransformer.ByteTransformer(b'\x01\x01\x01\x01\x01\x01\x01\x01')
transformer = ByteTransformer.ByteTransformer(b'\x01\x01\x01\x01\x01\x01\x01\x01')
original.print_as_bit_array("Test array for Horizontal Sheers")


print("non-implemented method:")
transformer.not_a_method()

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
#
# import sys
#
#  Transforms
#   * increment/decrement
#     invert
#     rotate_90_CCW, rotate_90_CW, rotate_180
#     flip_horizontal, flip_vertical
#     horizontal_sheer, vertical_sheer
#  Utilities
#   * print_as_bytes, print_as_bit_array, print_comparison
#   * random
#   * parameters
#     duplicate
#     read_from
# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

