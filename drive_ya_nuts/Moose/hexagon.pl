#!/usr/bin/perl
# A perl script to try out regular_n_gon

use strict;
use warnings;

my $name = $0;
   $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [-opt1] [-opt2] [-opt3]";

use lib '.';

my $true=1; my $false=0;

use sized_regular_n_gon;

my $hexagon = regular_n_gon->new( sides => 6, sub_radius=>1.0 );

print "A hexagon has " . $hexagon->sides . " sides.\n";
print "Each internal internal angle of a hexagon is " . regular_n_gon->in_degrees($hexagon->internal_angle) . " degrees.\n";

exit 0;

__END__
