#!/opt/local/bin/python

import ByteTransformer

original = ByteTransformer.ByteTransformer(b'\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF')
original.print_as_bit_array("Array initalized with all 1's then printed as bit array:")


print("\n===============================\nParameters Utility:\n")
original = ByteTransformer.ByteTransformer(b'\xa1\x02\x03\x04\x05\x06\x07\x08')
original.parameters(1)
print("")

print("\n===============================\nComparison Utility:\n")
original    = ByteTransformer.ByteTransformer(b'\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF')
transformer = ByteTransformer.ByteTransformer(b'\x00\x00\x00\x00\x00\x00\x00\x00')
print("\nOnes    \tZeroes:")
original.print_comparison(transformer)


print("\n===============================\nUp and Down:\n")
original    = ByteTransformer.ByteTransformer(b'\xa1\x02\x03\x04\x05\x06\x07\x08')

transformer = ByteTransformer.ByteTransformer(b'\xa1\x02\x03\x04\x05\x06\x07\x08')
transformer.increment_bytes()
print("Original\tBytes Incremented:")
original.print_comparison(transformer)
print("")

transformer = ByteTransformer.ByteTransformer(b'\xa1\x02\x03\x04\x05\x06\x07\x08')
transformer.decrement_bytes()
print("Original\tBytes Decremented:")
original.print_comparison(transformer)

# inversion
print("\n===============================\nInversions\n")

original    = ByteTransformer.ByteTransformer(b'\x55\xAA\x55\xAA\x55\xAA\x55\xAA')
transformer = ByteTransformer.ByteTransformer(b'\x55\xAA\x55\xAA\x55\xAA\x55\xAA')
transformer.invert()
print("Original\tInverted:")
original.print_comparison(transformer)
print("")

original    = ByteTransformer.ByteTransformer(b'\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')
transformer = ByteTransformer.ByteTransformer(b'\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')
transformer.invert()
print("Original\tInverted:")
original.print_comparison(transformer)
print("")

original    = ByteTransformer.ByteTransformer(b'\x01\x30\x07\xF0\x1F\xF3\x7F\xFF')
transformer = ByteTransformer.ByteTransformer(b'\x01\x30\x07\xF0\x1F\xF3\x7F\xFF')
transformer.invert()
print("Original\tInverted:")
original.print_comparison(transformer)

print("\n===============================\nRotations\n")

original    = ByteTransformer.ByteTransformer(b'\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')

transformer = ByteTransformer.ByteTransformer(b'\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')
transformer.rotate_180()
print("Original\tRotated 180:")
original.print_comparison(transformer)
print("\n-------------------------------\n")

transformer = ByteTransformer.ByteTransformer(b'\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')
transformer.rotate_90_CW()
print("Original\tRotated 90 CW:")
original.print_comparison(transformer)
print("\n-------------------------------\n")

transformer = ByteTransformer.ByteTransformer(b'\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')
transformer.rotate_90_CCW()
print("Original\tRotated 90 CCW:")
original.print_comparison(transformer)

print("\n===============================\nFlipping methods:\n")
original    = ByteTransformer.ByteTransformer(b'\xF0\xE0\xC0\x80\x00\x00\x00\x00')
transformer = ByteTransformer.ByteTransformer(b'\xF0\xE0\xC0\x80\x00\x00\x00\x00')
transformer.flip_vertically()
print("Original\tFlipped Vertically:")
original.print_comparison(transformer)
print("\n-------------------------------\n")

transformer = ByteTransformer.ByteTransformer(b'\xF0\xE0\xC0\x80\x00\x00\x00\x00')
transformer.flip_horizontally()
print("Original\tFlipped Horizontal:")
original.print_comparison(transformer)

print("\n===============================\nShifting methods:\n")
original = ByteTransformer.ByteTransformer(b'\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')

for shift in (range(1,8)):
    transformer = ByteTransformer.ByteTransformer(b'\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')
    transformer.shift_vertically(shift)
    print(f"Original\tShifted Vertically by {shift}:")
    original.print_comparison(transformer)
print("\n-------------------------------\n")

for shift in (range(1,8)):
    transformer = ByteTransformer.ByteTransformer(b'\x01\x03\x07\x0F\x1F\x3F\x7F\xFF')
    transformer.shift_horizontally(shift)
    print(f"Original\tShifted Horizontally by {shift}:")
    original.print_comparison(transformer)

print("\n===============================\nGear Rotation method:")

#  1 _ _ 1   _ _ _ 1    1001 0001  9 1
#  _ 1 1 _   _ _ 1 _    0110 0010  6 2
#  _ _ 1 _   _ 1 1 _    0010 0110  2 6
#  _ _ _ 1   1 _ _ 1    0001 1001  1 9
#
#  1 _ _ 1   1 _ _ _    1001 1000  9 8
#  _ 1 1 _   _ 1 _ _    0110 0100  6 4
#  _ 1 _ _   _ 1 1 _    0100 0110  4 6
#  1 _ _ _   1 _ _ 1    1000 1001  8 9

original = ByteTransformer.ByteTransformer(b'\x91\x62\x26\x19\x98\x64\x46\x89')
for rotation in (range(4)):
    param = 0
    r = rotation
    for quadrant in (range(4)):
        r = ( r + 1 ) % 4
        param |= r << ( quadrant * 2 )
    transformer = ByteTransformer.ByteTransformer(b'\x91\x62\x26\x19\x98\x64\x46\x89')
    transformer.gear_rotate(param,1)
    print(f"\nOriginal\tGear Rotated with {param:08b}:")
    original.print_comparison(transformer)

print("\n===============================\nSheering methods:\n")
original = ByteTransformer.ByteTransformer(b'\xFF\x00\x00\x00\x00\x00\x00\x00')

for sheer in (range(1,8)):
    transformer = ByteTransformer.ByteTransformer(b'\xFF\x00\x00\x00\x00\x00\x00\x00')
    transformer.sheer_vertically(sheer)
    print(f"Original\tSheered Vertically by {sheer}:")
    original.print_comparison(transformer)

    transformer.sheer_vertically(8 - sheer)
    print(f"Original\tSheered Vertically back from {sheer}:")
    original.print_comparison(transformer)
    print("")
print("\n-------------------------------\n")

# original = ByteTransformer.ByteTransformer(b'\x01\x01\x01\x01\x01\x01\x01\x01')
original    = ByteTransformer.ByteTransformer(b'\xF0\xE0\xC0\x80\x00\x00\x00\x00')

for sheer in (range(1,8)):
    # transformer = ByteTransformer.ByteTransformer(b'\x01\x01\x01\x01\x01\x01\x01\x01')
    transformer = ByteTransformer.ByteTransformer(b'\xF0\xE0\xC0\x80\x00\x00\x00\x00')
    transformer.sheer_horizontally(sheer,0)
    print(f"Original\tSheered Horizontally by {sheer}:")
    original.print_comparison(transformer)

    transformer.sheer_horizontally(8 - sheer,0)
    print(f"Original\tSheered horizontally back from {sheer}:")
    original.print_comparison(transformer)
    print("")

print("\n-------------------------------\nOther Utility methods:\n")
print("non-implemented method:")
transformer.not_a_method()

print("duplicate method:")
original = ByteTransformer.ByteTransformer(b'\x01\x01\x01\x01\x01\x01\x01\x01')
transformer = ByteTransformer.ByteTransformer(b'\xFF\x00\x00\x00\x00\x00\x00\x00')
print(f"Original\tOther  before duplication:")
original.print_comparison(transformer)
original.duplicate(transformer)
print(f"Original\tOther  after  duplication:")
original.print_comparison(transformer)

print("read_from method:")
transformer.read_from('-' ,1)

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

