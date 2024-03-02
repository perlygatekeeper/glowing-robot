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
parser.add_argument("--salt", nargs='?', help="Salt, 20-byte base64-encoded string")
parser.add_argument('-r', "--random",    help="Generate 24 random parameters, which may be encoded into a salt/anti-salt pair", action="store_true")

# Parse the arguments
args = parser.parse_args()


