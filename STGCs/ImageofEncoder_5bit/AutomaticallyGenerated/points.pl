#!/usr/bin/env perl
# A perl script to give points on a circle of radius 85 
# given each angle in degrees

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [angle_1] [angle2] [angle3] ...";
# ex.  ./points.pl 0 40 80 120 160 200 240 280 320

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
