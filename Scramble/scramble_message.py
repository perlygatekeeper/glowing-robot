#!/opt/local/bin/python

import ByteTransformer
import sys
import argparse

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

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
#  Transforms
#   rotate_90_CCW, rotate_90_CW, rotate_180
#   flip_horizontal, flip_vertical
#   horizontal_sheer, vertical_sheer
#   invert
# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
'''

# Create a parser object
parser = argparse.ArgumentParser(description="Process input filename")

# Add a required argument for the input filename
# parser.add_argument("input_filename",  default="-", type=str, help="The path to the input file")
# parser.add_argument("output_filename", default="-", type=str, help="The path to the output file")
parser.add_argument('infile',  nargs='?', type=argparse.FileType('rb'), default=sys.stdin,  help="Path to the input file")
parser.add_argument('outfile', nargs='?', type=argparse.FileType('wb'), default=sys.stdout, help="Path to the output file")
parser.add_argument("-d", "--debug", help="set the debug flag", action="store_true")

# Parse the arguments
args = parser.parse_args()

# Print the parsed input filename
if (args.debug):
  print("Input filename: ",  args.infile)
  print("Output filename: ", args.outfile)

transformer = ByteTransformer.ByteTransformer(b'\x00\x00\x00\x00\x00\x00\x00\x00')
transformer.print_as_bit_array("Zeroes")
for chunk in transformer.read_from(args.infile):
    if (args.debug):
        print(f"read from yeilded {chunk}")
