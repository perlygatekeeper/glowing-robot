#!/opt/local/bin/python

import ByteTransformer
import sys
import argparse
import re

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

# Create a parser object
parser = argparse.ArgumentParser(description="Process input filename")

# Add a required argument for the input filename
# parser.add_argument("input_filename",  default="-", type=str, help="The path to the input file")
# parser.add_argument("output_filename", default="-", type=str, help="The path to the output file")
parser.add_argument('infile',  nargs='?', type=argparse.FileType('rb'), default=sys.stdin,  help="Path to the input file")
parser.add_argument('outfile', nargs='?', type=argparse.FileType('wb'), default=sys.stdout, help="Path to the output file")
parser.add_argument("-d", "--debug", help="set the debug flag", action="store_true")
group = parser.add_mutually_exclusive_group()
group.add_argument("-s", "--scramble",   dest='action', action="store_const", const="scramble")
group.add_argument("-u", "--unscramble", dest='action', action="store_const", const="unscramble")

# Parse the arguments
args = parser.parse_args()

# Determine whether we are scrambling or unscrabling
if (not args.action):
    if (re.search(r"^(?:[^/]*/)?un(?:scramble)?",sys.argv[0])):
      args.action = 'unscramble'
    elif (re.search(r"^(?:[^/]*/)s(?:cramble)?",sys.argv[0])):
      args.action = 'scramble'
    else:
      raise ValueError(f"script name must begin with either 'scramble' or 'unscramble' and we're named '{sys.argv[0]}'")

# Print the parsed input filename
if (args.debug):
  print("Input filename: ",  args.infile)
  print("Output filename: ", args.outfile)
  if (args.action == 'scramble'):
    print("I will be scrambling the input.")
  elif (args.action == 'unscramble'):
    print("I will be unscrambling the input.")
  else:
    print("I have no idea what I'm supposed to be doing with the input.")


if (args.action == 'scramble'):
    # make a block of random bytes, output it and determine the block's parameters
    transformer = ByteTransformer.ByteTransformer(b'\x00\x00\x00\x00\x00\x00\x00\x00')
    transformer.random()
    # transformer.print_as_bit_array("Random block:")
    params = transformer.parameters(0)
    output_file = transformer.output_file(args.outfile)
    transformer.write_to(output_file)
    for chunk in transformer.read_from(args.infile):
        if ( len(chunk) < 8 ):
            chunk.extend(b'\x00' * ( 8 - len(chunk) ) )  # Append null bytes (b'\x00')
        if (args.debug):
            print(f"read from yeilded {chunk}")
        transformer=ByteTransformer.ByteTransformer(chunk)
        pre_scrambled_params = transformer.parameters(0)
        # NOW WE DECIDE HOW TO SCRAMBLE
        # Order of transforms:
        #    1) if present chunk has less than 4 unique bits - invert it
        #    2) rotations based on last bit of params['00']
        #   3a) flips     based on the       last   bit  of params['00']
        #   3b) direction based on second to last   bit  of params['00']
        #   4a) sheer     based on forth  to last   bit  of params['h_parity']
        #   4b) amount    based on second to last 3 bits of params['h_parity']
        #   5a) shift     based on forth  to last   bit  of params['v_parity']
        #   5b) amount    based on second to last 3 bits of params['v_parity']
        # ---- ---- ---- ---- ---- ---- ---- ---- ----
        #  Transforms
        #   rotate_90_CCW, rotate_90_CW, rotate_180
        #    flip_horizontally,  flip_vertically
        #   sheer_horizontally, shift_vertically
        #   shift_horizontally, shift_vertically
        #   invert
        # ---- ---- ---- ---- ---- ---- ---- ---- ----
        if ( pre_scrambled_params['ones'] < 4 ):
            transformer.invert()

        rotate = ( params['00'] & 0x03 )
        if ( rotate == 1 ):
            transformer.rotate_90_CW()
        elif ( rotate == 2 ):
            transformer.rotate_180()
        elif ( rotate == 3 ):
            transformer.rotate_90_CCW()

        flip     = ( params['01'] & 0x01 )
        vertical = ( params['01'] & 0x10 )
        if (flip == 1):
            if (vertical == 0):
                transformer.flip_vertically()
            elif (vertical == 2):
                transformer.flip_horizontally()

        sheer = ( params['h_parity'] & 0x0F )
        if (sheer & 8):
            transformer.sheer_horizontally( sheer & 0x07 )
        else:
            transformer.sheer_vertically( sheer & 0x07 )

        shift = ( params['v_parity'] & 0x0F )
        if (sheer & 8):
            transformer.shift_horizontally( shift & 0x07 )
        else:
            transformer.shift_vertically( shift & 0x07 )

        # ---- ---- ---- ---- ---- ---- ---- ---- ----
        transformer.write_to(output_file)
        params = pre_scrambled_params    # prepare for next chunk

elif (args.action == 'unscramble'):
    # read the block of random bytes and determine the block's parameters
    transformer = ByteTransformer.ByteTransformer(b'\x00\x00\x00\x00\x00\x00\x00\x00')
    transformer.random()
    # transformer.print_as_bit_array("Random block:")
    params = transformer.parameters(0)
    output_file = transformer.output_file(args.outfile)
    transformer.write_to(output_file)
    for chunk in transformer.read_from(args.infile):
        if (args.debug):
            print(f"read from yeilded {chunk}")
        transformer=ByteTransformer.ByteTransformer(chunk)
        pre_scrambled_params = transformer.parameters(0)

        # NOW WE DECIDE HOW TO UNSCRAMBLE
        # Order of transforms:
        #    1) if present chunk has less than 4 unique bits - invert it
        #   2a) shift     based on forth  to last   bit  of params['v_parity']
        #   2b) amount    based on second to last 3 bits of params['v_parity']
        #   3a) sheer     based on forth  to last   bit  of params['h_parity']
        #   3b) amount    based on second to last 3 bits of params['h_parity']
        #   4a) flips     based on the       last   bit  of params['00']
        #   4b) direction based on second to last   bit  of params['00']
        #    5) rotations based on last bit of params['00']
        # ---- ---- ---- ---- ---- ---- ---- ---- ----

        if ( pre_scrambled_params['ones'] < 4 ):
            transformer.invert()
        # reverse order of operations
        shift = ( params['v_parity'] & 0x0F )
        if (sheer & 8):
            transformer.shift_horizontally( shift & 0x07 )
        else:
            transformer.shift_vertically( shift & 0x07 )

        sheer = ( params['h_parity'] & 0x0F )
        if (sheer & 8):
            transformer.sheer_horizontally( sheer & 0x07 )
        else:
            transformer.sheer_vertically( sheer & 0x07 )

        flip     = ( params['01'] & 0x01 )
        vertical = ( params['01'] & 0x10 )
        if (flip == 1):
            if (vertical == 0):
                transformer.flip_vertically()
            elif (vertical == 2):
                transformer.flip_horizontally()

        rotate = ( params['00'] & 0x03 )
        if ( rotate == 1 ):
            transformer.rotate_90_CW()
        elif ( rotate == 2 ):
            transformer.rotate_180()
        elif ( rotate == 3 ):
            transformer.rotate_90_CCW()

        # ---- ---- ---- ---- ---- ---- ---- ---- ----
        transformer.write_to(output_file)
        params = pre_scrambled_params    # prepare for next chunk


exit()
