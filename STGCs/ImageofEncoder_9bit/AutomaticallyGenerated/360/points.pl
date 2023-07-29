#!/usr/bin/env perl
# A perl script to give points on a circle of radius 85 
# given angles in degrees

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [-opt1] [-opt2] [-opt3]";

use strict;
use warnings;
use Math::Trig;

my $radius = 85;

foreach my $angle ( @ARGV ) {
	my $angle_rad = deg2rad($angle);
	printf "%6.3f, %6.3f\n", $radius * cos($angle_rad), $radius * sin($angle_rad);
}

exit 0;

__END__
