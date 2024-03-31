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
import re

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
group.add_argument("--salt", nargs='?',       help="Salt, 20-byte base64-encoded string")
group.add_argument("--parameters", nargs='?', help="24 numbers, limits: 27,19,11,3,27,19,11,3 + 16 23's")
group.add_argument('-r', "--random",          help="Generate 24 random parameters, which may be encoded into a salt/anti-salt pair", action="store_true")
args = parser.parse_args()
# 28 bit locations   20 bit locations   12 bit locations     4 bit locations
# pre-checkterboard Whirlpool     27 19 11 3
# checkterboard                   23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23
# post-checkterboard Whirlpool    27 19 11 3

def is_valid_len20_base64_string(input_string):
  try:
    # Check if the string is of length 20
    if len(input_string) > 20:
      print(f"input string is not a string of length 20, it was too long ... {len(input_string)}")
      return False
    if len(input_string) < 20:
      print(f"input string is not a string of length 20, it was too short ... {len(input_string)}")
      return False
    # Try decoding the base64 string with strict validation
    base64.b64decode(input_string, validate=True)
    return True
  except (TypeError, base64.binascii.Error) as err:
    # Return False if there's an error during decoding
    print(f"input string is not valid base64-encoded string >>>{err}<<<")
    #           Only base64 data is allowed
    if (err.__str__() == "Only base64 data is allowed"):
      offending_characters = re.sub('[A-Za-z0-9/+]',' ',input_string)
      print(f"offending chacters are shown here >>{offending_characters}<<<")
    elif (err.__str__() == "Excess data after padding"):
      print(f"padding character for base64 encoding is the equals sign (=) which must appear at the end of the encoded string and must not exceed 4")
      # elif (err.__str__() == "Excess data after padding"):
      # print(f"padding character for base64 encoding is the equals sign (=) which must appear at the end of the encoded string and must not exceed 4")
    else:
      print(f"no additional information")
    return False

if (args.salt and is_valid_len20_base64_string(args.salt)):
    print(f"Processing   Salt:      {args.salt}")
    params = ByteTransformer.parameters_from_salt( base64.b64decode(args.salt), args.debug )
    anti_salt = ByteTransformer.anti_salt_from_parameters( params, 0 ).decode("utf-8")
    print(f"Corresponding Anti-Salt: {anti_salt}")
elif (args.random):
    params = ByteTransformer.random_parameters(args.debug)
    print("Salt from parameters:      ", end="")
    print(ByteTransformer.salt_from_parameters( params, args.debug ).decode("utf-8"))
    print("Anti-Salt from parameters: ", end="")
    print(ByteTransformer.anti_salt_from_parameters( params, args.debug ).decode("utf-8"))


