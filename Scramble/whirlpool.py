#!/opt/local/bin/python
#
# test the whirlpool transform
#
# Version:           1.4.0
# Last_modification: 2024/02/17
# Author:            Dr. Steven Parker
# Copyright:         All rights reserved

import ByteTransformer
import argparse
import os

parser = argparse.ArgumentParser(description="Process input, either scrambling or unscrambling it")

parser.add_argument('salt',    nargs='?', help="Salt, a 15-byte string")
args = parser.parse_args()

# if ( args.salt ):
#     parameters = transformer.unpack_salt(args.salt)

parameters = bytearray(b'\x01\x01\x01\x01\x01\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00')

# transformer.whirlpool(paramerters[0:4])
# transformer.checkerboard(paramerters[-16:])
# transformer.whirlpool(paramerters[4:8])


print("\n===============================\nWhirlpool transform:\n")
original = ByteTransformer.ByteTransformer(b'\x01\x02\x04\x08\x00\x00\x00\x00')
original.print_as_bit_array("Array initalized with one 1 then printed as bit array:")
print("\n-------------------------------\n")

transformer = ByteTransformer.ByteTransformer(b'\x01\x02\x04\x08\x00\x00\x00\x00')
for i in range(27):
    transformer.whirlpool(parameters[0:4])
    print(f"Original\tWhirled:")
    original.print_comparison(transformer)
    print("\n-------------------------------\n")
