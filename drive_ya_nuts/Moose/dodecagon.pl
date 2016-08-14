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

my $dodecagon = sized_regular_n_gon->new( sides => 12, sub_radius => 1.0 );

print "A dodecagon has " . $dodecagon->sides . " sides.\n";
print "Each internal internal angle of a dodecagon is " . regular_n_gon->in_degrees($dodecagon->internal_angle) . " degrees.\n\n";
print "The sub_raidus    of our dodecagon is " . $dodecagon->sub_radius   . " units.\n";
print "The super_raidus  of our dodecagon is " . $dodecagon->super_radius . " units.\n";
print "The side_length   of our dodecagon is " . $dodecagon->side_length  . " units.\n";
print "The perimeter     of our dodecagon is " . $dodecagon->perimeter    . " units.\n";
print "The area          of our dodecagon is " . $dodecagon->area  . " square units.\n";

exit 0;

__END__
