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

my $n_gon_names = [ '', '', 'equalateral triangle', 'square', 'pentagon', 'hexagon', 'septagon', 'octagon', 'nonagon', 'decagon', 'unidecagon', 'dodecagon',
'13-agon', '14-agon', '15-agon', '16-agon', '17-agon', '18-agon', '19-agon', '20-agon',
'21-agon', '22-agon', '23-agon', '24-agon', '25-agon', '26-agon', '27-agon', '28-agon', '29-agon', '30-agon',
'31-agon', '32-agon', '33-agon', '34-agon', '35-agon', '36-agon', '37-agon', '38-agon', '39-agon', '40-agon',
'41-agon', '42-agon', '43-agon', '44-agon', '45-agon', '46-agon', '47-agon', '48-agon', '49-agon', '50-agon',
];

my $i=0;
my @area_estimate;
my @perimeter_estimate;
foreach my $n_gon_name (@$n_gon_names) {
  $i++; next if (not $n_gon_name);
  my $n_gon = sized_regular_n_gon->new( sides => $i, sub_radius => 1.0 );
  print "A $n_gon_name has " . $n_gon->sides . " sides.\n";
  print "Each internal internal angle of a $n_gon_name is " . regular_n_gon->in_degrees($n_gon->internal_angle) . " degrees.\n\n";
  print "The sub_raidus    of our $n_gon_name is " . $n_gon->sub_radius   . " units.\n";
  print "The super_raidus  of our $n_gon_name is " . $n_gon->super_radius . " units.\n";
  print "The side_length   of our $n_gon_name is " . $n_gon->side_length  . " units.\n";
  print "The perimeter     of our $n_gon_name is " . $n_gon->perimeter    . " units.\n";
  print "The area          of our $n_gon_name is " . $n_gon->area  . " square units.\n";
  print '-' x 80 . "\n";
  $area_estimate[$i]+=$n_gon->area;
  $perimeter_estimate[$i]+=$n_gon->perimeter;
}

my $i=0;
foreach my $n_gon_name (@$n_gon_names) {
  $i++; next if (not $n_gon_name);
  my $n_gon = sized_regular_n_gon->new( sides => $i, super_radius => 1.0 );
  print "A $n_gon_name has " . $n_gon->sides . " sides.\n";
  print "Each internal internal angle of a $n_gon_name is " . regular_n_gon->in_degrees($n_gon->internal_angle) . " degrees.\n\n";
  print "The sub_raidus    of our $n_gon_name is " . $n_gon->sub_radius   . " units.\n";
  print "The super_raidus  of our $n_gon_name is " . $n_gon->super_radius . " units.\n";
  print "The side_length   of our $n_gon_name is " . $n_gon->side_length  . " units.\n";
  print "The perimeter     of our $n_gon_name is " . $n_gon->perimeter    . " units.\n";
  print "The area          of our $n_gon_name is " . $n_gon->area  . " square units.\n";
  $area_estimate[$i]+=$n_gon->area;
  $area_estimate[$i]/=2.0;
  print "area estimate for pi is $area_estimate[$i]\n";
  $perimeter_estimate[$i]+=$n_gon->perimeter;
  $perimeter_estimate[$i]/=4.0;
  print "perimeter estimate for pi is $area_estimate[$i]\n";
  print '-' x 80 . "\n";
}

my $centagon = sized_regular_n_gon->new( sides => 100, sub_radius => 1.0 );		 my $pi_ish  = $centagon->area;
my $centagon = sized_regular_n_gon->new( sides => 100, super_radius => 1.0 );	    $pi_ish += $centagon->area;	    $pi_ish /= 2.0;

print "a centagon estimates pi to be $pi_ish\n";
exit 0;

__END__
