#!/usr/bin/env perl
# A perl script to SCRIPT_DESCRIPTION

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name";

use strict;
use warnings;

my $pieces = [
  [ 1, 2, 3, 4, 5, 6 ],
  [ 1, 6, 5, 4, 3, 2 ],
  [ 1, 6, 4, 2, 5, 3 ],
  [ 1, 4, 6, 2, 3, 5 ],
  [ 1, 4, 3, 6, 5, 2 ],
  [ 1, 6, 5, 3, 2, 4 ],
  [ 1, 6, 2, 4, 5, 3 ] ];

my $board = [ ] ;




exit 0;

__END__

 BOARD = Array of 7 LOCATIONS,
 LOCATION a link to a PIECE and a ROTATION for that piece

 [ pieceTop, rotationTop,
   pieceUL,  rotationUL,
   pieceLL,  rotationLL,
   pieceBot, rotationBot,
   pieceLR,  rotationLR,
   pieceUR,  rotationUR,
   score ]

                     0   1   2   3   4   5   C 
                     P R P R P R P R P R P R P R Score
   possible board:   0 5 3 5 1 5 5 5 6 5 2 5 4 5 12
                     123456789012345678901234567890
                              1         2         3

   original board:   0 5 3 5 1 5 5 5 6 5 2 5 4 5 12
   rotate clockwise: 2 0 0 0 3 0 1 0 5 0 6 0 4 0 12
   rotate cw x 2:    6 1 2 1 0 1 3 1 1 1 5 1 4 1 12
   rotate cw x 3:    5 2 6 2 2 2 0 2 3 2 1 2 4 2 12
   rotate cw x 4:    1 3 5 3 6 3 2 3 0 3 3 3 4 3 12
stored as 30 characters (with 14 spaces)
stored as 16 characters compact

 0 - 5 outside 0 on top, counted clock-wise.
 6 center

 each location has 6 CONNECTIONS, outside will have 3 that are null
 0 - top 
 1 - upper left 
 2 - lower left 
 3 - bottom 
 4 - lower right 
 5 - upper right 

CONNECTIONS 
for center piece, 6 connections are all directions
for outside piece, 3 CONNECTIONS it's (location + 2, 3 and 4) % 6

                  
TRY will have a BOARD and a SCORE

SCORE will be 1 for every CONNECTION for which the pieces numbers match.


Number of Possible Boards
--------------------------------------------------------------------
first location choose from 6 pieces,
second location choose from remaining 5 pieces
seventh location no choice.

so 6! = 720

each piece may have 6 possible rotations, so 6^7 = 279,936

total boards possible = 201,553,920

symmetry (each outer piece advanced clockwise and all pieces rotated clockwise) 

33,592,320

How do I walk all 33.5 million possible boards without any of the other 5
symmetricly equivalent boards?


Checking a Single Connection
--------------------------------------------------------------------
Esxample #1, connection involving the center (6 of these)
Pc = piece on center
Rc = rotation of piece on center

Pt = piece on top
Rt = rotation of piece on top

number from center piece involved in connection
number on piece in direction 0

Nc = number from piece (direction 0 + Rc) % 6

location top
number on piece in direction 3 ( my location, top = 0, + 3 ) % 6

Nt = number from piece (direction 3 + Rt) % 6
--------------------------------------------------------------------

Esxample #2, connection between 2 outside pieces (six of these as well)
Plr = piece on lower right
Rlr = rotation of piece on lower right

Pur = piece on upper right
Rur = rotation of piece on upper right

number from lower right piece involved in connection ( location trailing in a clock-wise manner )
number on piece in direction lower right (4)

Nlr = number from piece (direction=(my location(4) + 2) + Rc) % 6

location top
number on piece in direction upper right (trailing piece's number (4) + 1 ) % 6) =  5

Nur = number from piece (direction=(my location(5) - 2) + Rc) % 6
--------------------------------------------------------------------

