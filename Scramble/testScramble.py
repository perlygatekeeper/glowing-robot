#!/opt/local/bin/python

import ByteTransformer

data = bytearray(b'\x01\x02\x03\x04\x05\x06\x07\x08')
print("Object initialized:")
transformer = ByteTransformer.ByteTransformer(data)

transformer.print_as_bytes("Object printed as bytes:")

transformer.print_as_bit_array("Object printed as bit array:")

print("Parameters:")
transformer.parameters()

print("non-implemented method:")
transformer.not_a_method()

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
# import sys
#  Transforms
#   rotate_90_CCW, rotate_90_CW, rotate_180
#   flip_horizontal, flip_vertical
#   horizontal_sheer, vertical_sheer
#   invert
#  Utilities
#   - compare
#   print_as_bytes, print_as_bit_array, print_comparison
#   duplicate
#   parameters
#   random
#   read_from
# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

