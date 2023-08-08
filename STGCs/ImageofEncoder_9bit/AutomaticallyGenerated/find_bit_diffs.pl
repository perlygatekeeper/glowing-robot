#!/usr/bin/env perl
# A perl script to read lines from standard input
# find single chunks of bits in a clump
# compare chunks bit by bit and report which bit(s) change

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [-opt1] [-opt2] [-opt3]";

use strict;
use warnings;

my $line;
my $bits;
my $nextbits;
my $nextline;
my $chunk_length;
my $comparison;
my @changes;

# go until we find the first line with a group of 4 or more bits
while ( $line = <> ) {
  print $line;
  if ( $line =~ /([01]{4,})/ ) {
     $bits = $1;
     last;
  }
}

chomp $line;

while ( $nextline = <> ) {
  chomp $nextline;
  # find the bits chunk
  $nextline =~ /([01]{4,})/;
  $nextbits = $1;
  # printf "bits: '%s' nextbits: '%s'\n", $bits, $nextbits;
  # do bit-by-bit comparison
  $chunk_length = length($nextbits);
  $comparison = ''; 
  my $same=1;
  for (my $loc = 0; $loc < $chunk_length; $loc++) {
    my $bit     = substr($bits,     $loc, 1);
    my $nextbit = substr($nextbits, $loc, 1);
    $same &= ($bit == $nextbit);
    if ($bit != $nextbit) {
      $changes[$loc+1]++;
    }
    $comparison .= sprintf(" %3d", $nextbit - $bit);
  }
  $comparison .= " <- OH NO! " if ($same);
  printf ("%s%s\n", $nextline, $comparison);
  # prep for next line
  $line = $nextline;
  $bits = $nextbits;
}

for (my $loc = 1; $loc <= $chunk_length; $loc++) {
  printf "%2d %d\n", $loc, $changes[$loc];
}

exit 0;

__END__
     substr EXPR,OFFSET,LENGTH,REPLACEMENT
     substr EXPR,OFFSET,LENGTH
     substr EXPR,OFFSET

First character is at offset 0

OFFSET is negative   == that far from the end of the string.
no LENGTH            == everything to the end of the string.
LENGTH is negative   == leaves that many characters off the end of the string.

To keep the string the same length you may need to pad
or chop your value using "sprintf".


OFFSET and LENGTH partly outside, only part returned.
OFFSET and LENGTH completely outside, UNDEF returned.

Here's an example showing the behavior for boundary cases:

  my $name = 'fred';
  substr($name, 4) = 'dy';       # $name is now 'freddy'
  my $null = substr $name, 6, 2; # returns '' (no warning)
  my $oops = substr $name, 7;    # returns undef, with warning
  substr($name, 7) = 'gap';      # fatal error

  my $str="abd123hij";		 # 2 ways to replace 123 with efg
  substr($str, 2, 3, 'efg');	 # assign 4th arg.
  substr($str, 2, 3)='efg';	 # substr as an lvalue

