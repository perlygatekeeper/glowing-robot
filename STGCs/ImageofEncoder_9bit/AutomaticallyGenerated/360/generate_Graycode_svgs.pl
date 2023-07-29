#!/usr/bin/env perl
# A perl script to generate graycode SVG's from the template file.

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name";
my $debug = 0;

use strict;
use warnings;

use Text::Template;
use Math::Trig;
use Data::Dumper;

my $template = Text::Template->new(SOURCE => "Template_inkscape.svg")
  or die "Couldn't construct template: $Text::Template::ERROR";

my $pwd = `pwd`; chomp $pwd;
my $parameters = { pwd => $pwd };

for ( my $degrees = 0; $degrees <= 360; $degrees+=1 ) {
  set_parameters($parameters, $degrees);
  if ( $debug ) {
    print "For degrees: $degrees\n";
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
  my $colors = {
    'red'    => "#${dim}0000",     'bright_red'    => "#${bright}0000", 
    'green'  => "#00${dim}00",     'bright_green'  => "#00${bright}00", 
    'blue'   => "#0000${dim}",     'bright_blue'   => "#0000${bright}", 
    'yellow' => "#${dim}${dim}00", 'bright_yellow' => "#${bright}${bright}00", 
    'purple' => "#${dim}00${dim}", 'bright_purple' => "#${bright}00${bright}", 
    'black'  => "#00${dim}${dim}", 'bright_black'  => "#00${bright}${bright}", 
    'orange' => "#00${dim}${dim}", 'bright_orange' => "#00${bright}${bright}", 
    'cyan'   => "#00${dim}${dim}", 'bright_cyan'   => "#00${bright}${bright}", 
    'gray'   => "#00${dim}${dim}", 'bright_gray'   => "#00${bright}${bright}", 
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
    'green'  => 0, 
    'red'    => 0, 
    'purple' => 0, 
    'yellow' => 0, 
    'blue'   => 0, 
    'black'  => 0, 
    'orange' => 0, 
    'cyan'   => 0, 
    'gray'   => 0, 
  };

# Slots go from, to (in degrees)
  my $slots = [
    { 'lower_limit' =>   0, 
      'upper_limit' => 120, 
    }, 
    { 'lower_limit' => 168, 
      'upper_limit' => 204, 
    }, 
    { 'lower_limit' => 228, 
      'upper_limit' => 252, 
    }, 
  ];
# Sensors are at 72-degree increments starting at 0
# 0, 72, 144, 216, 288
  my $locations = {
    'green'  =>   0, 
    'red'    =>  40, 
    'purple' =>  80, 
    'yellow' => 120, 
    'blue'   => 160, 
    'black'  => 200, 
    'orange' => 240, 
    'cyan'   => 280, 
    'gray'   => 320, 
  };
  foreach my $sensor ( keys %$sensors ) {
    foreach my $slot ( @$slots ) {
      if ( ( ( $locations->{$sensor} - $degrees - 1 ) % 360 ) > $slot->{'lower_limit'}
       and ( ( $locations->{$sensor} - $degrees - 1 ) % 360 ) < $slot->{'upper_limit'} )  {
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


