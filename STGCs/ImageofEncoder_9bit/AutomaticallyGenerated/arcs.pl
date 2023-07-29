#!/usr/bin/env perl
# A perl script to give points on a circle of radius 85 
# given angles in degrees

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [-opt1] [-opt2] [-opt3]";

use strict;
use warnings;
use Math::Trig;

my $radius = 225;
my $ring = 'outer';
my $offset = 1.0;
# my $radius = 200;
# my $ring = 'inner';
# my $offset = 1.0028;

my $angles = 1;

  for ( my $angle = 0; $angle < 360; $angle += $offset ) {
	my $angle_1_rad = deg2rad($angle);
	my $angle_2_rad = deg2rad($angle+0.5);
	printf '<path d="M %8.3f, %8.3f A %3d %3d 0 0 1 %8.3f %8.3f" id="slot_%s_%02d" />' . "\n",
	$radius * cos($angle_1_rad), $radius * sin($angle_1_rad),
	$radius,                     $radius,
	$radius * cos($angle_2_rad), $radius * sin($angle_2_rad),
	$ring,                       $angles++;
}

exit 0;

__END__
    <g
       transform="matrix(1,0,0,1,90,90)"
       id="slots">
      <g
         id="g4184">
        <ellipse
           ry="90"
           rx="90"
           cy="0"
           cx="0"
           id="circle"
           style="opacity:0.0;fill:#00ff00;fill-opacity:0;stroke:none;stroke-width:4;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1" />
        <g
           transform="matrix({$rotate_matrix})"
           style="fill:none;stroke:#000000;stroke-width:10"
           id="slots">
          <path d="M 85,0 A 85,85 0 0 1 -42.500, 73.612" id="slot1" />
          <path d="M -83.143, 17.672 A 85,85 0 0 1 -77.651, -34.573" id="slot2" />
          <path d="M -56.876, -63.167 A 85,85 0 0 1 -26.266, -80.840" id="slot3" />
        </g>
      </g>
    </g>
