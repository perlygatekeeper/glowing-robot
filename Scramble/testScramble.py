#!/opt/local/bin/python

import ByteTransformer
import sys

data = bytearray(b'\x01\x02\x03\x04\x05\x06\x07\x08')

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
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

transformer = ByteTransformer(data)
transformer.not_a_method()
