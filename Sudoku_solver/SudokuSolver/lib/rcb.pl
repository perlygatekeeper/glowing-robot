#!/usr/bin/env perl
# A perl script to test method to determine row column and box given a cell number from 0 .. 80

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [-opt1] [-opt2] [-opt3]";

use strict;
use warnings;

# ROW    = 1 + int(CELL/9) -> 1..9
# COLUMN = 1 + CELL % 9 -> 1..9
# BOX    = 1 + ( ( CELL % 9 ) / 3 ) + int(CELL/9) / 3 -> 1..9
my(@CELLS, @ROWS, @COLUMNS, @BOXES);

for ( my($cell)=0; $cell < 81; $cell++ ) {
  print "$cell\n";
    push(@CELLS,   1 + $cell );
    push(@COLUMNS, 1 + ( $cell % 9 ) );
    push(@ROWS,    1 + int( $cell / 9 ) );
    push(@BOXES,   1 + int( ( $cell % 9 ) / 3 ) + 3 * int ( int( $cell / 9 ) / 3 ) );
}

printf("%7s:", "CELLS");   printf "%3d", $_ for @CELLS;   print "\n";
printf("%7s:", "ROWS");    printf "%3d", $_ for @ROWS;    print "\n";
printf("%7s:", "COLUMNS"); printf "%3d", $_ for @COLUMNS; print "\n";
printf("%7s:", "BOXES");   printf "%3d", $_ for @BOXES;   print "\n";

exit 0;

__END__

./rcb.pl | cut -c1-89   | tail -4
./rcb.pl | cut -c90-170 | tail -4
./rcb.pl | cut -c171-   | tail -4

