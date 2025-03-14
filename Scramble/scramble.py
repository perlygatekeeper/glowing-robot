#!/opt/local/bin/python
#
# Scramble the bits of text and other files
#
# Version:           1.4.0
# Last_modification: 2024/02/17
# Author:            Dr. Steven Parker
# Copyright:         All rights reserved

import ByteTransformer
import sys
import argparse
import re
import os
import base64

''' Preloop
       Parse Arguments (if any)
       Determine if Scrambling or Unscrambling 
       Generate and output random block - OR - read random block if Unscrambling
       Determine Parameters from random block
     Loop
       Read input block
       Determine and save Parameters for next block if Scrambling
       Scramble block - OR - UNscramble block ( this should use parameters from previous clear block )
                                                but may also use parameters from the present block for the purposes of inversion
       Determine and save Parameters for next block if Unscrambling
       Output Scrambled or Unscrambled block
'''

def get_file_size(filename):
    try:
        file_size = os.path.getsize(filename)
        return file_size
    except OSError as e:
        print(f"Error getting file size: {e}")
        return None

# Create a parser object
parser = argparse.ArgumentParser(description="Process input, either scrambling or unscrambling it")

# Add a required argument for the input filename
# parser.add_argument("input_filename",  default="-", type=str, help="The path to the input file")
# parser.add_argument("output_filename", default="-", type=str, help="The path to the output file")
parser.add_argument('infile',  nargs='?', type=argparse.FileType('rb'), default=sys.stdin,  help="Path to the input file")
parser.add_argument('outfile', nargs='?', type=argparse.FileType('wb'), default=sys.stdout, help="Path to the output file")
parser.add_argument("--salt",  nargs='?', help="Salt, a 20-byte base64-encoded string")
parser.add_argument("-d", "--debug", help="set the debug flag", action="store_true")
parser.add_argument("-64", "--base64", help="expect input or produce output that is base64 encoded", action="store_true")
group = parser.add_mutually_exclusive_group()
group.add_argument("-s", "--scramble",   dest='action', action="store_const", const="scramble")
group.add_argument("-u", "--unscramble", dest='action', action="store_const", const="unscramble")

# Parse the arguments
args = parser.parse_args()

# Determine whether we are scrambling or unscrabling
if (not args.action):
    if (re.search(r"^(?:.*/)?un(?:scramble)?",sys.argv[0])):
      args.action = 'unscramble'
    elif (re.search(r"^(?:.*/)?s(?:cramble)?",sys.argv[0])):
      args.action = 'scramble'
    else:
      script_name = sys.argv[0]
      raise ValueError(f"script name must begin with either 'scramble' or 'unscramble' and we're named '{script_name}'")

if args.infile == sys.stdin:
        args.infile = args.infile.buffer  # Access the underlying binary buffer

if args.outfile == sys.stdout:
        args.outfile = args.outfile.buffer  # Access the underlying binary buffer

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
    parameters = ByteTransformer.parameters_from_salt( base64.b64decode(args.salt) )

# Print the parsed input filename
if (args.debug):
  print("Input source: ",  args.infile)
  print("Input filename: ",  args.infile.name)
  print("Output source: ", args.outfile)
  if (args.action == 'scramble'):
    print("I will be scrambling the input.")
  elif (args.action == 'unscramble'):
    print("I will be unscrambling the input.")
  else:
    print("I have no idea what I'm supposed to be doing with the input.")

# if ( ( not args.infile ) or ( not args.outfile ) ):
#     print(f"You must supply both an input and output source, which both may be '-' or a filename.\n")
#     ArgumentParser.print_help()
#     exit(1)
# else:
#     print(f"We have both input and output source {args.infile} and {args.outfile}.\n")

blocks = 0

if (args.action == 'scramble'):

    # make a block of random bytes, output it and determine the block's parameters
    transformer = ByteTransformer.ByteTransformer(b'\x00\x00\x00\x00\x00\x00\x00\x00')
    params = { 'ones': 0 }
    while ( ( params['ones'] < 8 ) or  ( params['ones'] > 56 ) ):
      transformer.random()
      params = transformer.parameters(0)

    # here we are scrambling and if the input source is a file, find out how many bytes
    # we will be padding the last block.   After this we will encode this in the last
    # four bits of the last byte of the random Key Block.
    #
    # ____XPPP  <- X=1 input source is a file and PPP is number of padding bytes
    #           \- X=0 input source is a STDIN and PPP is left as random
    if ( args.infile.name == '<stdin>' ):
        transformer.data[7] &= 0xF7  # mask with 11110111 (turning off 4th bit from right
        if (args.debug):
            print(f"scramble reading from STDIN")
    else:
        transformer.data[7] &= 0xF0  # mask with 11110000
        last_block_size = get_file_size(args.infile.name) % 8
        if (last_block_size):
            transformer.data[7] |= ( 0x08 | ( get_file_size(args.infile.name) % 8 ) )
            if (args.debug):
                print(f"scramble reading from {args.infile.name} with last block {last_block_size}")
        else:
            if (args.debug):
                print(f"scramble reading from {args.infile.name} with last block 8")
    params = transformer.parameters(0)

    if (args.debug):
        transformer.print_as_bit_array("Random block:")

    output_file = transformer.output_file(args.outfile)
    buffer = []
    transformer.write_to(output_file, args.base64, buffer, args.debug)
    for chunk in transformer.read_from(args.infile, 0, 0):
        blocks += 1
        if ( len(chunk) < 8 ):
            if (args.debug):
                print(f"chunk was {len(chunk)} long so padding with 8 - {len(chunk)}")
            chunk.extend(b'\x00' * ( 8 - len(chunk) ) )  # Append null bytes (b'\x00')
        if (args.debug):
            print(f"read from yeilded {chunk}")
        transformer=ByteTransformer.ByteTransformer(chunk)
        pre_scrambled_params = transformer.parameters(0)
        # NOW WE DECIDE HOW TO SCRAMBLE
        # Order of transforms:
        #    1) if present chunk has less than 4 unique bits - invert it
        #    2) barber_pole always done
        #    3) rotations based on last bit of params['00']
        #   4a) flips     based on the       last   bit  of params['00']
        #   4b) direction based on second to last   bit  of params['00']
        #   5a) sheer     based on forth  to last   bit  of params['h_parity']
        #   5b) amount    based on second to last 3 bits of params['h_parity']
        #   6a) shift     based on forth  to last   bit  of params['v_parity']
        #   6b) amount    based on second to last 3 bits of params['v_parity']
        #    7) gear_rotation always done with ???
        #    8) if Salt, use its parameters to preform whirlpool, checkerboard, whirlpool

        # ---- ---- ---- ---- ---- ---- ---- ---- ----
        #  Transforms
        #   rotate_90_CCW, rotate_90_CW, rotate_180
        #    flip_horizontally,  flip_vertically
        #   sheer_horizontally, sheer_vertically
        #   shift_horizontally, shift_vertically
        #   invert
        #   barber_pole, gear_rotate
        # ---- ---- ---- ---- ---- ---- ---- ---- ----

        if (1):
          if ( ( pre_scrambled_params['ones'] < 4 ) or ( pre_scrambled_params['ones'] > 60 ) ):
              if (args.debug):
                  print(f"This chunk had only {pre_scrambled_params['ones']} so it will be inverted.")
              transformer.invert()

        if (1): # mandatory transform of barber_poling (swapping adjacent odd and even columns)
              transformer.barber_pole()

        if (1):
          rotate = ( params['00'] & 0x03 )
          if ( rotate == 1 ):
              transformer.rotate_90_CW(),
          elif ( rotate == 2 ):
              transformer.rotate_180()
          elif ( rotate == 3 ):
              transformer.rotate_90_CCW()

        if (1):
          flip     = ( params['01'] & 0x01 )
          vertical = ( params['01'] & 0x10 )
          if (flip == 1):
              if (vertical == 0):
                  transformer.flip_vertically()
              elif (vertical == 2):
                  transformer.flip_horizontally()

        if (1):
          sheer = ( params['h_parity'] & 0x0F )
          if (sheer & 8):
              transformer.sheer_horizontally( (sheer & 0x07), 0)
          else:
              transformer.sheer_vertically( (sheer & 0x07), 0)

        if (1):
          shift = ( params['v_parity'] & 0x0F )
          if ( (shift & 0x07) != 0 ): # only shift if our shift amount is non-zero
            if (shift & 8):
                transformer.shift_horizontally( (shift & 0x07), 0)
            else:
                transformer.shift_vertically( (shift & 0x07), 0)

        if (1):
          gears = ( params['v_parity'] ^ ( ~ params['h_parity'] ) )
          if ( gears != 0 ): # only gear rotate if our shift amount is non-zero
              transformer.gear_rotate(gears, 0)

        if ( args.salt):
            parameters = ByteTransformer.parameters_from_salt( base64.b64decode(args.salt), args.debug)
            transformer.whirlpool(parameters[0:4], args.debug)
            # transformer.checkerboard(parameters[-16:], args.debug)
            transformer.whirlpool(parameters[4:8], args.debug)

        # ---- ---- ---- ---- ---- ---- ---- ---- ----
        
        transformer.write_to(output_file, args.base64, buffer, args.debug )
        params = pre_scrambled_params    # prepare for next chunk
    if (args.base64):
        # if args.base64 is passed as 2, then write_to will flush the buffer, even if it's now full
        transformer.write_to(output_file, args.base64 + 1, buffer, args.debug )

elif (args.action == 'unscramble'):
    # read the block of random bytes and determine the block's parameters
    transformer = ByteTransformer.ByteTransformer(b'\x00\x00\x00\x00\x00\x00\x00\x00')
    # transformer.print_as_bit_array("Random block:")
    output_file = transformer.output_file(args.outfile,0)
    first_chunk = True
    padding = 0
    last_block_size = 0
    for chunk in transformer.read_from(args.infile, args.base64, args.debug):
        if ( padding and blocks > 0):
            # write out the padding-sized last bit from old block
            # this will not be done for the LAST block in the stream,
            # thus dropping the padding
            transformer.partial_write_to(output_file,last_block_size,8)
        transformer=ByteTransformer.ByteTransformer(chunk)
        if (first_chunk):
            if (args.debug):
                transformer.print_as_bit_array("Random block:")
            first_chunk = False
            params = transformer.parameters(0)
            padding = (transformer.data[7] & 0x08) >> 3
            last_block_size = transformer.data[7] & 0x07
            if (args.debug):
                if (padding):
                    print(f"Padding WAS added to the last chunk of the scrambled file, last block size SHOULD be {last_block_size}.")
                else:
                    print(f"No padding was added to the last chunk of the scrambled file.")
            continue
        if (args.debug):
            print(f"read from {blocks:4d} yeilded: {chunk}")
        blocks += 1
        pre_unscrambled_params = transformer.parameters(0) # used for inversion, doesn't matter that it's still unscrambled

        # NOW WE DECIDE HOW TO UNSCRAMBLE
        # Order of transforms:
        #    1) if present chunk has less than 4 unique bits - invert it
        #    2) if Salt, use its parameters to preform whirlpool, checkerboard, whirlpool
        #    3) gear_rotation always done with ???
        #   4a) shift     based on forth  to last   bit  of params['v_parity']
        #   4b) amount    based on second to last 3 bits of params['v_parity']
        #   5a) sheer     based on forth  to last   bit  of params['h_parity']
        #   5b) amount    based on second to last 3 bits of params['h_parity']
        #   6a) flips     based on the       last   bit  of params['00']
        #   6b) direction based on second to last   bit  of params['00']
        #    7) rotations based on last bit of params['00']
        #    8) barber_pole always done
        # ---- ---- ---- ---- ---- ---- ---- ---- ----

        if (1):
          if ( ( pre_unscrambled_params['ones'] < 4 ) or ( pre_unscrambled_params['ones'] > 60 ) ):
              if (args.debug):
                  print(f"This chunk had only {pre_unscrambled_params['ones']} so it will be inverted.")
              transformer.invert()

        if ( args.salt):
            parameters = ByteTransformer.parameters_from_salt( base64.b64decode(args.salt), args.debug )
            transformer.whirlpool(parameters[0:4], args.debug)
            # transformer.checkerboard(parameters[-16:], args.debug)
            transformer.whirlpool(parameters[4:8], args.debug)

        if (1):
          gears = ( params['v_parity'] ^ ( ~ params['h_parity'] ) )
          if ( gears &  64 ):  # Top Left quadrant
              gears ^= 128
          if ( gears &  16 ):  # Top Right quadrant
              gears ^=  32
          if ( gears &   4 ):  # Bottom Right quadrant
              gears ^=   8
          if ( gears &   1 ):  # Bottom Left quadrant
              gears ^=   2
          #  00 - 00 no ratation
          #  01 - 11 <- changes  90 CW -> 90 CCW  01000000 00010000 00000100 00000001 ->  64, 16, 4, 1
          #  10 - 10 180 ratation
          #  11 - 01 <- changes  90 CCW -> 90 CW  10000000 00100000 00001000 00000010 -> 128, 32, 8, 2
          if ( gears != 0 ): # only gear rotate if our shift amount is non-zero
              transformer.gear_rotate(gears, 0)

        if (1):
          # reverse order of operations
          shift = ( params['v_parity'] & 0x0F )
          if ( (shift & 0x07) != 0 ): # only shift if our shift amount is non-zero
            if (shift & 8):
                transformer.shift_horizontally( 8 - ( shift & 0x07 ), 0 )
            else:
                transformer.shift_vertically( 8 - ( shift & 0x07 ), 0 )
  
        if (1):
          sheer = ( params['h_parity'] & 0x0F )
          if (sheer & 8):
              transformer.sheer_horizontally( 8 - ( sheer & 0x07 ), 0 )
          else:
              transformer.sheer_vertically( 8 - ( sheer & 0x07 ), 0 )
  
        if (1):
          flip     = ( params['01'] & 0x01 )
          vertical = ( params['01'] & 0x10 )
          if (flip == 1):
              if (vertical == 0):
                  transformer.flip_vertically()
              elif (vertical == 2):
                  transformer.flip_horizontally()

        if (1):
          rotate = ( params['00'] & 0x03 )
          if ( rotate == 1 ):
              transformer.rotate_90_CCW()
          elif ( rotate == 2 ):
              transformer.rotate_180()
          elif ( rotate == 3 ):
              transformer.rotate_90_CW()

        if (1): # mandatory transform of barber_poling (swapping adjacent odd and even columns)
              transformer.barber_pole()

        # ---- ---- ---- ---- ---- ---- ---- ---- ----
        # this chunk should now be unscrambled
        # write it out, and get it's parameters to use with next chunk
        if (padding):
            transformer.partial_write_to(output_file, 0, last_block_size, args.debug )
        else:
            # transformer.write_to(output_file, args.debug)
            buffer = []
            transformer.write_to(output_file, 0, buffer, args.debug )
        params = transformer.parameters(0)

if (args.debug):
    print(f"Processed {blocks} blocks.")


exit()
