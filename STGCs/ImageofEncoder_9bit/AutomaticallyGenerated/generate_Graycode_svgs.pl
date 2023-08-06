#!/usr/bin/env perl
# A perl script to generate graycode SVG's from an SVG
# template file.  The template file was made in Inkscape.
# These output SVG files will be modified, by moving the
# outer track of arcs by an amount of degrees.
#
# This particular version has been modified to work on 
# a 9-bit/9-sensor Single Track Gray Code, which will encode angles
# at a 1 degree resolution.  So this script will generate 360 seperate
# SVG files from the Template.

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name";
my $debug = 1;

use strict;
use warnings;

# 1) read in template SVG file
# 2) loop over degrees ( 0, 359, by 1)
#   a) change degrees text
#   b) change slots rotation
#   c) change bits text and colors
#   d) change sensor colors
#   e) write out SVG file for this iteration's degrees
# 3) loop SVG files and export them to png's (done by make file)

use Text::Template;
use Math::Trig;
use Data::Dumper;

my $template = Text::Template->new(SOURCE => "Template.svg")
  or die "Couldn't construct template: $Text::Template::ERROR";

my $pwd = `pwd`; chomp $pwd;
my $parameters = { pwd => $pwd };

for ( my $degrees = 0; $degrees <= 359; $degrees+=1 ) {
  set_parameters($parameters, $degrees);
  if ( $debug ) {
    my $sensors = [
      'lime'      ,
      'orange'    ,
      'red'       ,
      'magenta'   ,
      'purple'    ,
      'blue'      ,
      'light_blue',
      'cyan'      ,
      'green'     ,
    ];
    printf "For degrees: %03d ", $degrees;
    foreach my $sensor ( @$sensors ) { 
      print $parameters->{'bit_' . $sensor . '_value'}
    }
    print "\n";
    print Dumper($parameters);
    print "\n";
    next;
  }

# substitue new values into the template and write out to appropriate file
  my $result = $template->fill_in(HASH => $parameters);
  my $basename = sprintf("Graycode-%03d",$degrees);
  if (defined $result) {
    open( SVG, ">", $basename . ".svg" )
      || die("$name: Cannot write to '$basename.svg': $!\n");
    print SVG $result;
    close(SVG);
  } else {
    die "Couldn't fill in template: $Text::Template::ERROR";
  }
}

exit 0;

sub set_parameters {
  my $parameters = shift;
  my $degrees = shift;
  my $sensors = sensors($degrees);
  my $dim = 'c0';
  my $bright = 'ff';
  my $secondary = 'aa';
  my $colors = {
    'green'      => "#00c000", 'bright_green'      => "#00ff00",   
    'cyan'       => "#00c0aa", 'bright_cyan'       => "#00ffaa",   
    'light_blue' => "#00aac0", 'bright_light_blue' => "#00aaff",   
    'blue'       => "#0000c0", 'bright_blue'       => "#0000ff",   
    'purple'     => "#aa00c0", 'bright_purple'     => "#aa00ff",   
    'magenta'    => "#c000aa", 'bright_magenta'    => "#ff00aa",   
    'red'        => "#c00000", 'bright_red'        => "#ff0000",   
    'orange'     => "#c0aa00", 'bright_orange'     => "#ffaa00",   
    'lime'       => "#aac000", 'bright_lime'       => "#aaff00",   
  };
  $parameters->{"degrees_string"} = sprintf('%3s', $degrees);
  $parameters->{"degrees"       } = sprintf('%03d', $degrees);
  $parameters->{"rotate_matrix" } = sprintf("%7.5f,%7.5f,%7.5f,%7.5f,0.0,0.0",
  	                                    cos(deg2rad($degrees)),
  	                                    sin(deg2rad($degrees)),
  	                               -1 * sin(deg2rad($degrees)),
  	                                    cos(deg2rad($degrees))
  	                            );
  foreach my $sensor ( keys %$sensors ) {
    $parameters->{'bit_' . $sensor . '_value'} = $sensors->{$sensor};
    if ( $sensors->{$sensor} ) {
      $parameters->{'sensor_' . $sensor}         = $colors->{ 'bright_' . $sensor };
      $parameters->{'bit_' . $sensor . '_color'} = $colors->{ 'bright_' . $sensor };
    } else {
      $parameters->{'sensor_' . $sensor}         = $colors->{ $sensor };
      $parameters->{'bit_' . $sensor . '_color'} = $colors->{ $sensor };
    }
  }
}

sub sensors {
  my $degrees = shift;
  my $sensors = {
    'green'      => 0,
    'cyan'       => 0,
    'light_blue' => 0,
    'blue'       => 0,
    'purple'     => 0,
    'magenta'    => 0,
    'red'        => 0,
    'orange'     => 0,
    'lime'       => 0,
  };
  my $slots = [
    { 'lower_limit' =>   3, 'upper_limit' =>   4, },
    { 'lower_limit' =>  23, 'upper_limit' =>  28, },
    { 'lower_limit' =>  31, 'upper_limit' =>  37, },
    { 'lower_limit' =>  44, 'upper_limit' =>  48, },
    { 'lower_limit' =>  56, 'upper_limit' =>  60, },
    { 'lower_limit' =>  64, 'upper_limit' =>  71, },
    { 'lower_limit' =>  74, 'upper_limit' =>  76, },
    { 'lower_limit' =>  88, 'upper_limit' =>  91, },
    { 'lower_limit' =>  94, 'upper_limit' =>  96, },
    { 'lower_limit' =>  99, 'upper_limit' => 104, },
    { 'lower_limit' => 110, 'upper_limit' => 115, },
    { 'lower_limit' => 131, 'upper_limit' => 134, },
    { 'lower_limit' => 138, 'upper_limit' => 154, },
    { 'lower_limit' => 173, 'upper_limit' => 181, },
    { 'lower_limit' => 186, 'upper_limit' => 187, },
    { 'lower_limit' => 220, 'upper_limit' => 238, },
    { 'lower_limit' => 242, 'upper_limit' => 246, },
    { 'lower_limit' => 273, 'upper_limit' => 279, },
    { 'lower_limit' => 286, 'upper_limit' => 289, },
    { 'lower_limit' => 307, 'upper_limit' => 360, },
  ];
# Sensors are at 40 degree increments starting at 0
  my $locations = {
    'green'      =>   0,
    'cyan'       =>  40,
    'light_blue' =>  80,
    'blue'       => 120,
    'purple'     => 160,
    'magenta'    => 200,
    'red'        => 240,
    'orange'     => 280,
    'lime'       => 320,
  };
  foreach my $sensor ( keys %$sensors ) {
    foreach my $slot ( @$slots ) {
      if ( ( ( $locations->{$sensor} + $degrees ) % 360 ) >= $slot->{'lower_limit'}
       and ( ( $locations->{$sensor} + $degrees ) % 360 ) <= $slot->{'upper_limit'} )  {
        $sensors->{$sensor} = 1;
        last; # if a sensor's in this slot we can stop looking
      }
    }
  }
  return $sensors;
}

__END__


sodipodi:docname="Graycode-{$degrees}.svg"
inkscape:export-filename="{$pwd}/Graycode-{$degrees}.png"

style="fill:{$sensor_green};fill-opacity:1;stroke:none;stroke-opacity:1" />
style="fill:{$sensor_blue};fill-opacity:1;stroke:none;stroke-opacity:1" />
style="fill:{$sensor_yellow};fill-opacity:1;stroke:none;stroke-opacity:1" />
style="fill:{$sensor_purple};fill-opacity:1;stroke:none;stroke-opacity:1" />
style="fill:{$sensor_red};fill-opacity:1;stroke:none;stroke-opacity:1" />

style="font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-family:monospace;-inkscape-font-specification:monospace">{$degrees_string}°</tspan></text>

style="fill:{$bit_green_color};fill-opacity:1">{$bit_green_value}</tspan>
style="fill:{$bit_blue_color};fill-opacity:1">{$bit_blue_value}</tspan>
style="fill:{$bit_yellow_color};fill-opacity:1">{$bit_yellow_value}</tspan>
style="fill:{$bit_purple_color};fill-opacity:1">{$bit_purple_value}</tspan>
style="fill:{$bit_red_color};fill-opacity:1">{$bit_red_value}</tspan>

transform="matrix({$transform_matrix})">

1st 2D translation
 +-             -+
 |  1    0   -Tx |
 |               |
 |  0    1   -Ty |
 |               |
 |  0    0    1  |
 +-             -+

2D rotation
 +-             -+      +-             -+
 | cos -sin   0  |      | cos -sin  -Tx |
 |               |      |               |
 | sin  cos   0  | =>   | sin  cos  -Ty |
 |               |      |               |
 |  0    0    1  |      |  0    0    1  |
 +-             -+      +-             -+

2nd 2D translation
 +-             -+      +-                                  -+
 |  1    0    Tx |      | cos -sin  ( cos*Tx - sin*Ty - Tx ) |
 |               |      |                                    |
 |  0    1    Ty | =>   | sin  cos  ( sin*Tx + cos*Ty - Ty ) |
 |               |      |                                    |
 |  0    0    1  |      |  0    0    1                       |
 +-             -+      +-                                  -+

// Slots go from, to (in degrees)
//   0, 120
// 168, 204
// 228, 252


