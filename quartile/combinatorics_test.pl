#!/usr/bin/env perl
# A perl script to tewt the Math::Combinatorics module.

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [-opt1] [-opt2] [-opt3]";

use strict;
use warnings;

use Math::Combinatorics;

my @n = qw( a b c d e f g h i j k l m n o p q r s t );
my $count = 0;

print "our array starts with " . ($#n + 1) . " elements.\n";

for ( my($i) = 1; $i <= 4; $i++ ) {
  my $comb = Math::Combinatorics->new(count => $i, data => [@n],);
  # print "permutations of $i from: ".join(" ",@n)."\n";
  # print "------------------------".("--" x scalar(@n))."\n";
  # while(my @combo = $comb->next_permutation){
  print "combinations of $i from: ".join(" ",@n)."\n";
  print "------------------------".("--" x scalar(@n))."\n";
  $count = 0;
  while(my @combo = $comb->next_combination){
    print join(' ', @combo)."\n";
    $count++
  }
  print "$count combinations with $i characters.\n";
  print "\n";
}


exit 0;

__END__
