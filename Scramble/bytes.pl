#!/usr/bin/env perl
# A perl script to output some byte manipulations of all the bytes
# from 00000000 to 11111111

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [-opt1] [-opt2] [-opt3]";

use strict;
use warnings;

foreach my $byte ( 0x00 .. 0xFF) {
  # printf "%c\n", $byte;
  my $bits = sprintf("%08B",$byte);
  my $inverted = (~$byte) & 0xFF;
  my $inverted_bits = sprintf("%08B",$inverted);
  # my $reverse_bits = join(reverse('',split('',$byte)));
  my $reverse_bits = join('', reverse( split('', $bits)));
  # my $ones_count = unpack( "%08B*", ($byte & 0xFF) );
  my $ones_count = scalar($bits =~ tr/1// );
  my $parity = ($ones_count % 2) ? 1 : 0;
  printf "'%c' %s %s %s %d %d\n", $byte,$bits, $reverse_bits, $inverted_bits, $ones_count, $parity;
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
