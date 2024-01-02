#!/usr/bin/env perl
# A perl script to output some byte manipulations of all the bytes
# from 00000000 to 11111111

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [-opt1] [-opt2] [-opt3]";

use strict;
use warnings;

foreach my $byte ( 0x00 .. 0xFF ) {
  my %counts = ( '00' => 0, '01' => 0, '10' => 0, '11' => 0);
  my $bits = sprintf("%08B",$byte);
  my $inverted = (~$byte) & 0xFF;
  my $inverted_bits = sprintf("%08B",$inverted);
  my $reverse_bits = join('', reverse( split('', $bits)));
  my $reversed;
  eval "\$reversed = 0b$reverse_bits";
  $bits =~ m/(..)(..)(..)(..)/;
  foreach my $double_bit ( $1,  $2,  $3,  $4 ) {
    $counts{$double_bit}++;
  }
  $counts{'ones'}  = scalar( $bits =~ tr/1// );
  my $parity = $counts{'ones'} % 2;
# my $ones_count = unpack( "%08B*", ($byte & 0xFF) );
# printf "'%c' %s %s %s %d %d\n", $byte, $bits, $reverse_bits, $inverted_bits, $ones_count, $parity;
#                    'reversed':   '%c',
#                    'inverted':   '%c',
  printf(
  "    chr(0x%02X): { 'bit_string': '%s', 'hexdecimal': '0x%02X', 'reversed': chr(0x%02X), \\\n      'inverted': chr(0x%02X), 'parity': %d, 'ones': %d, '00': %d, '01': %d, '10': %d, '11': %d },\n",
            $byte, $bits, $byte, 
            $reversed, $inverted,
#           ord($reversed), ord($inverted),
            $parity, $counts{'ones'},
            $counts{'00'}, $counts{'01'}, $counts{'10'}, $counts{'11'}
            )
}

exit 0;

__END__
     Bytes
     Orginal     Reversed    Inverted    Parity    Ones
                             ________
     87654321    12345678    87654321         p    0-8
     00000000    00000000    11111111         p    0-8
     00000001    10000000    11111110         p    0-8
     00001111    11110000    11110000         p    0-8
     11110000    00001111    00001111         p    0-8
     01111111    11111110    10000000         p    0-8
     01010101    10101010    10101010         p    0-8
     10101010    01010101    01010101         p    0-8
     11111111    11111111    00000000         p    0-8
