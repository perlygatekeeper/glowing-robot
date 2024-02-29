#!/opt/local/bin/python
# test the whirlpool transform
#
# Version:           1.4.0
# Last_modification: 2024/02/28
# Author:            Dr. Steven Parker
# Copyright:         All rights reserved
#
# transformer.whirlpool(paramerters[0:4])
# transformer.checkerboard(paramerters[-16:])
# transformer.whirlpool(paramerters[4:8])

# 00 10 01 11 \x27
# 00 00 00 00 \x00
# 00 10 01 11 \x27
# 01 01 01 01 \x55
# 00 10 01 11 \x27
# 10 10 10 10 \xAA
# 00 10 01 11 \x27
# 11 11 11 11 \xFF

import ByteTransformer
import argparse
import os

parser = argparse.ArgumentParser(description="Process input, either scrambling or unscrambling it")

parser.add_argument('salt',    nargs='?', help="Salt, a 15-byte string")
args = parser.parse_args()

# if ( args.salt ):
#     parameters = transformer.unpack_salt(args.salt)

# parameters = bytearray(b'\x00\x00\x00\x00\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x00\x00\x00\x00')
parameters = bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00')

print("\n===============================\nWhirlpool transform:\n")
# original = ByteTransformer.ByteTransformer(b'\0b00001001\0b00000000\0b11001011\0b00010101\0b00100111\0b10101010\0b00100111\0b11111111')
original = ByteTransformer.ByteTransformer(b'\x27\x00\x27\x55\x27\xAA\x27\xFF')
original.print_as_bit_array("Array initalized with all 16 possible 2x2 squares:")
print("\n-------------------------------\n")

for permutation in range(4):
    for p in range(8,24):
        parameters[p] = permutation
    print(f"Original\tCheckerboarded with {permutation}:")
    transformer = ByteTransformer.ByteTransformer(b'\x27\x00\x27\x55\x27\xAA\x27\xFF')
    transformer.checkerboard(parameters[-16:], 1)
    original.print_comparison(transformer)
    print("\n-------------------------------\n")
