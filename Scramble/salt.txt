#!/opt/local/bin/python
#
# Salt utility for scramble script
#
# Version:           1.0.0
# Last_modification: 2024/03/02
# Author:            Dr. Steven Parker
# Copyright:         All rights reserved

import ByteTransformer
import argparse
import base64

# parameters_from_salt(salt, debug=0):
# salt_from_parameters(parameters, debug=0):
# anti_salt_from_parameters(parameters, debug=0):
# random_parameters(debug=0):
# Actions: 
# 1 given a salt or anti-salt, return the parameters that would be derived from it
# 2 given set of 24 seperate parameters, return a salt and an anti-salt encoding them
# 3 generate a set of 24 random paramters and display both this set and the salt and anti-salt encoding them
# 4 given a salt or anti-salt return the coresponding partner string
# BASE64:
# ABCDEFGHIJKLMNOPQRSTUVWXYZ
# abcdefghijklmnopqrstuvwxyz
# 0123456789
# +/

parser = argparse.ArgumentParser(description="Manipulated parameters & salt/anti-salt's used with the scramble script")
parser.add_argument("-d", "--debug",     help="set the debug flag", action="store_true")
group = parser.add_mutually_exclusive_group()
parser.add_argument("--salt", nargs='?',       help="Salt, 20-byte base64-encoded string")
parser.add_argument("--parameters", nargs='?', help="24 numbers, limits: 27,19,11,3,27,19,11,3 + 16 23's")
parser.add_argument('-r', "--random",          help="Generate 24 random parameters, which may be encoded into a salt/anti-salt pair", action="store_true")
args = parser.parse_args()
# 28 bit locations   20 bit locations   12 bit locations     4 bit locations
# pre-checkterboard Whirlpool     27 19 11 3
# checkterboard                   23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23
# post-checkterboard Whirlpool    27 19 11 3

if (args.salt):
    print(f"Processing   Salt:      {args.salt}")
    params = ByteTransformer.parameters_from_salt( base64.b64decode(args.salt), args.debug )
    anti_salt = ByteTransformer.anti_salt_from_parameters( params, 0 ).decode("utf-8")
    print(f"Coresponding Anti-Salt: {anti_salt}")
elif (args.random):
    params = ByteTransformer.random_parameters(args.debug)
    print("Salt from parameters:      ", end="")
    print(ByteTransformer.salt_from_parameters( params, args.debug ).decode("utf-8"))
    print("Anti-Salt from parameters: ", end="")
    print(ByteTransformer.anti_salt_from_parameters( params, args.debug ).decode("utf-8"))




