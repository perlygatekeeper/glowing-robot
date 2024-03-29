#!/usr/bin/env perl
# A perl script to solve the drive ya nuts puzzle

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name";

use strict;
use warnings;
use Algorithm::Combinatorics qw(permutations);
use Data::Dumper;

my $pieces = [
    [ 1, 2, 3, 4, 5, 6 ],    # 0
    [ 1, 6, 5, 4, 3, 2 ],    # 1
    [ 1, 6, 4, 2, 5, 3 ],    # 2
    [ 1, 4, 6, 2, 3, 5 ],    # 3
    [ 1, 4, 3, 6, 5, 2 ],    # 4
    [ 1, 6, 5, 3, 2, 4 ],    # 5
    [ 1, 6, 2, 4, 5, 3 ] ];  # 6
my @location_names  = (  'top', 'upper left',  'lower left',   'bottom', 'lower right',    'upper right',  'center', );
my @direction_names = (  'up',  'up and left', 'down and left', 'down',  'down and right', 'up and right', );

my $debug  = 1;
my $boards = 0;
my $board;        # $board->{locations}[location] contains a hash containing piece id and rotation for piece at location
                  # $board->{score}               contains the score for the board 0 to 12
my $pieces_left;  # $pieces_left->[location]      contains an array ref to pieces left after choosing a piece for [location]

# choose a piece for the center
foreach my $center ( 0 .. 6 ) {
    my $location1 = 6;
    $board->{locations}[$location1] = { piece => $center, rotation => 0 };
# print $board->{locations} . "\n" if ($debug);;
    $pieces_left->[$location1] = [ ];
    foreach my $piece ( 0 .. 6 ) {
        push( @{$pieces_left->[$location1]}, $piece) unless ( $piece == $center);
    }
    print "$center: ( " . join(", ", @{$pieces_left->[$location1]}) . " )\n" if ($debug);

    foreach my $top ( @{$pieces_left->[$location1]} ) { # pieces left after choosing last location
        my $location2 = 0;                          # new location
        $board->{locations}[$location2] = { piece => $top, rotation => 3 };
# print $board->{locations} . "\n" if ($debug);;
        $pieces_left->[$location2] = [ ];
        foreach my $piece ( @{$pieces_left->[$location1]} ) {
            push( @{$pieces_left->[$location2]}, $piece) unless ( $piece == $top);
        }
        print "  $top ( " . join(", ", @{$pieces_left->[$location2]}) . " )\n" if ($debug);
        my $perms = permutations( $pieces_left->[$location2] );
        while (my $rest =$perms->next ) {
            foreach my $location ( 1 .. 5 ) {
# print $board->{locations} . "\n" if ($debug);;
# print $rest . "\n" if ($debug);;
                $board->{locations}[$location] = {
                    piece => $rest->[$location-1],  # arrays are indexed starting from 0, so rest will have 0 .. 4
                    rotation => &point_my_what_where(
                                    $rest->[$location-1],  
                                    $pieces->[$board->{locations}[6]{piece}][$location], # the center pieces value pointing in direction  equal to the piece's location
                                    ( $location + 3 ) % 6
                                ),
                };
            }
print Dumper($board) if ($debug);
            &score_me($board);
            printf "%7d: %s\n", ++$boards,  &to_string($board);
            &pretty($board);
        }
    }
}

sub from_string {
    my ( $string ) = shift;
    my $board ;
    ( $board->{locations}[6]{piece}, $board->{locations}[6]{rotation},
      $board->{locations}[0]{piece}, $board->{locations}[0]{rotation},
      $board->{locations}[1]{piece}, $board->{locations}[1]{rotation},
      $board->{locations}[2]{piece}, $board->{locations}[2]{rotation},
      $board->{locations}[3]{piece}, $board->{locations}[3]{rotation},
      $board->{locations}[4]{piece}, $board->{locations}[4]{rotation},
      $board->{locations}[5]{piece}, $board->{locations}[5]{rotation},
      $board->{score} ) =
    split( //, $string);
    return $board;
}

sub to_string {
    my ( $board ) = shift;
    my $string = '';
    foreach my $location ( 6, 0 .. 5 ) {
        $string .= $board->{locations}[$location]{piece};
        $string .= $board->{locations}[$location]{rotation};
    }
    $string .= sprintf ( "-%01X", ($board->{score} || '0') );
    return $string;
}

sub score_me {
    my( $board ) = shift;
    my $score = 0;
    # score connections to center
    foreach my $location ( 0 .. 5 ) {
        my $direction1 =   $location; # direction of number on center piece
                                      # direction of number on touching piece (opposite of center direction)
        my $direction2 = ( $location + 3 + $board->{locations}[$location]{rotation} ) % 6;
        my $number_on_center_piece   = $pieces->[$board->{locations}[6]{piece}][$direction1];
        my $number_on_touching_piece = $pieces->[$board->{locations}[$location]{piece}][$direction2];
        if ( $number_on_center_piece == $number_on_touching_piece) {
            $score++;
        }
        print "$number_on_center_piece == $number_on_touching_piece  -> $score\n" if ($debug);
    }
    # score connections amoung outer ring
    foreach my $first_location ( 0 .. 5 ) {
        my $touching_location = ( $first_location + 1 ) % 6; # touching piece is piece located one space clock-wise
        my $direction1 = ( $first_location
                         + 2
                         + $board->{locations}[$first_location]{rotation} ) % 6; # direction of number on first piece
        my $direction2 = ( $touching_location
                         - 2 
                         + $board->{locations}[$touching_location]{rotation} ) % 6; # direction of number on touching piece
        my $number_on_first_piece    = $pieces->[$board->{locations}[$first_location]{piece}][$direction1];
        my $number_on_touching_piece = $pieces->[$board->{locations}[$touching_location]{piece}][$direction2];
        if ( $number_on_first_piece == $number_on_touching_piece) {
            $score++;
        }
#       print "$first_location == $touching_location\n" if ($debug);
        print "$number_on_first_piece == $number_on_touching_piece  => $score\n" if ($debug);
    }
    return $board->{score} = $score;
}

sub point_my_what_where {
    my ( $piece, $value, $direction ) = @_;
    foreach my $rotation ( 0 .. 5 ) {
        if ( $pieces->[$piece][ ( $direction + $rotation ) % 6 ] == $value ) {
            return $rotation;
        } 
    }
    return undef;
}


sub pretty {
    my $board = shift;
    my $b = $board->{locations};
    my $numbers;
    # flatten the board, applying the pieces and rotations and just recording the numbers
    foreach my $location ( 0 .. 6 ) {
        foreach my $direction ( 0 .. 5 ) {
            $numbers->[$location][$direction] =
              $pieces->[ $b->[$location]{piece} ][ ( $direction + $b->[$location]{rotation}) % 6 ];
        }
    }
    printf("\n          ___\n");
    printf("         / %1d \\\n",                   $numbers->[0][0]);
    printf("     ___/ %1d %1d \\___\n",             $numbers->[0][5], $numbers->[0][1]);
    printf("    / %1d \\ %1d %1d / %1d \\\n",       $numbers->[5][0], $numbers->[0][4], $numbers->[0][2], $numbers->[1][0]);
    printf("   / %1d %1d \\_%1d_/ %1d %1d \\\n",    $numbers->[5][5], $numbers->[5][1], $numbers->[0][3], $numbers->[1][5], $numbers->[1][1]);
    printf("   \\ %1d %1d / %1d \\ %1d %1d /\n",    $numbers->[5][4], $numbers->[5][2], $numbers->[6][0], $numbers->[1][4], $numbers->[1][2]);
    printf("    \\_%1d_/ %1d %1d \\_%1d_/\n",       $numbers->[5][3], $numbers->[6][5], $numbers->[6][1], $numbers->[1][3]);
    printf("    / %1d \\ %1d %1d / %1d \\\n",       $numbers->[4][0], $numbers->[6][4], $numbers->[6][2], $numbers->[2][0]);
    printf("   / %1d %1d \\_%1d_/ %1d %1d \\\n",    $numbers->[4][5], $numbers->[4][1], $numbers->[6][3], $numbers->[2][5], $numbers->[2][1]);
    printf("   \\ %1d %1d / %1d \\ %1d %1d /\n",    $numbers->[4][4], $numbers->[4][2], $numbers->[3][0], $numbers->[2][4], $numbers->[2][2]);
    printf("    \\_%1d_/ %1d %1d \\_%1d_/\n",       $numbers->[4][3], $numbers->[3][5], $numbers->[3][1], $numbers->[2][3]);
    printf("        \\ %1d %1d /\n",                $numbers->[3][4], $numbers->[3][2]);
    printf("         \\_%1d_/\n\n",                 $numbers->[3][3]);

       # row                    pieces
    #  1         ___          0
    #  2        / 1 \         1
    #  3    ___/ 6 2 \___     2
    #  4   / 1 \ 5 3 / 1 \    4
    #  5  / 6 2 \_4_/ 6 2 \   5
    #  6  \ 5 3 / 1 \ 5 3 /   5
    #  7   \_4_/ 6 2 \_4_/    4
    #  8   / 1 \ 5 3 / 1 \    4
    #  9  / 6 2 \_4_/ 6 2 \   5
    # 10  \ 5 3 / 1 \ 5 3 /   5
    # 11   \_4_/ 6 2 \_4_/    4
    # 12       \ 5 3 /        2
    # 13        \_4_/         1
}                                       

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

                     C   0   1   2   3   4   5  
                     P R P R P R P R P R P R P R Score
   possible board:   4 5 0 5 3 5 1 5 5 5 6 5 2 5 12
                     123456789012345678901234567890
                              1         2         3

   original board:   4 5 0 5 3 5 1 5 5 5 6 5 2 5 12
   rotate clockwise: 4 0 2 0 0 0 3 0 1 0 5 0 6 0 12
   rotate cw x 2:    4 1 6 1 2 1 0 1 3 1 1 1 5 1 12
   rotate cw x 3:    4 2 5 2 6 2 2 2 0 2 3 2 1 2 12
   rotate cw x 4:    4 3 1 3 5 3 6 3 2 3 0 3 3 3 12
   rotate cw x 5:    4 4 1 4 5 4 6 4 2 4 0 4 3 4 12
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
 6 center

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
--------------------------------------------------------------------

Answer: We are free to choose any one of the group of six symmetrically
equivalent boards.  I will choose the one with the center hex in the orientation
with it's '1' side facing up.  Additionally that will set the rotation of the
hex in the top location to 3 (this causes it's '1' side to match the center's
'1' side).

This also substatially reduces our search set, as the other 5 hexes may NOT have
their '1' side facing center, equivalent to their rotation != ( location + 3 ) % 6.

With 7 choices for the center hex and 6 for the top hex, both with their rotations
fixed, we will produce 42 files.

Each file will have the following number of boards.   5 x 4 x 3 x 2 x 1 = 120.
5^5 = 3125

120 * 3125 = 375,000


Checking a Single Connection
--------------------------------------------------------------------
Example #1, connection involving the center (6 of these)
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


# splice @array, pos, [n], [list]
#   removes and returns n elements from @array
#   starting at pos, replacing them with list if given
#   if n is not given will remove to end of @array
#
#        push(@a,$x,$y)      splice(@a,$#a+1,0,$x,$y)
#        pop(@a)             splice(@a,-1)
#        shift(@a)           splice(@a,0,1)
#        unshift(@a,$x,$y)   splice(@a,0,0,$x,$y)
#        $a[$x] = $y         splice(@a,$x,1,$y);
