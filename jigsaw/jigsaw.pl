#!/usr/bin/env perl
# A perl script to output a rectanglar jigsaw as an svg.

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [-opt1] [-opt2] [-opt3]";

use strict;
use warnings;
use SVG (-indent => "  ");
use Data::Dumper;
my $debug = 0;

my $stroke_width       = "0.268";
my $color              = "#000000";
my $puzzle_width       = "150";
my $puzzle_height      = "240";
my $puzzle_top_margin  = "20";
my $puzzle_left_margin = "20";
my $number_of_horizontal_lines =  7;
my $number_of_vertical_lines   =  4;
my $piece_height = ( $puzzle_height / ($number_of_horizontal_lines + 1 ) ) ;
my $piece_width  = ( $puzzle_width  / ($number_of_vertical_lines + 1 ) ) ;

my $style = { "fill"              => "none",
              "fill-rule"         => "evenodd",
              "stroke"            => $color,
              "stroke-width"      => $stroke_width,
              "stroke-linecap"    => "butt",
              "stroke-linejoin"   => "miter",
              "stroke-opacity"    => "1",
              "stroke-miterlimit" => "4",
              "stroke-dasharray"  => "none"
            };


my $svg = SVG->new(
  width       => $puzzle_width  + 2 * $puzzle_top_margin,
  height      => $puzzle_height + 2 * $puzzle_top_margin
) ;

my $puzzle = $svg->group(
  id    => 'Puzzle',
  style => $style
);

$puzzle->rect(
  id     => "outline",
  width  => $puzzle_width,
  height => $puzzle_height,
  x      => $puzzle_left_margin,
  y      => $puzzle_top_margin,
);

# horizontal lines
foreach my $line ( 1 .. $number_of_horizontal_lines ) {
  my $dx = 2.3;
  my $dy = 1.7;
  my $y = $puzzle_top_margin + $line * $piece_height;
  my $path = "";
  my ( $start_direction, $end_direction );
  my ( $start_key, $end_key );
  my ( $x_start, $x_end );
  #           __
  #          /  \
  # _________\  /_____
  # start    key      end
  $x_start = $puzzle_left_margin;
  $start_direction = (-1) ** (1+int(rand(2)));
  $path .= sprintf("M %5.1f %5.1f  ", $x_start, $y);
  foreach my $piece ( 1 .. ($number_of_vertical_lines+1) ) {
    # https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths#Bezier_Curves
    # svg::cubic_bezier   C  starting_control_point ( x1 x2 ) ending_control_point ( x2 y2 )  end point ( x, y )
    $start_key = $x_start + (0.25 + 0.025 * rand()) * $piece_width; # same as 1/4 + 1/4 * rand/10
    $end_key   = $start_key + 0.25 * $piece_width;
    my $x_end = $puzzle_left_margin + $piece * $piece_width;
    $end_direction = (-1) ** (1+int(rand(2)));
    $path .= sprintf("C %5.1f %5.1f  %5.1f %5.1f  %5.1f %5.1f  ",
    	              $x_start + $dx, $y + $start_direction * $dy, # start control point
    	              $x_end   - $dx, $y + $end_direction   * $dy, # end control point
    	              $x_end        , $y );                        # end point
    $x_start = $x_end;
    $start_direction = (-1) * $end_direction;
  }
  $puzzle->path(
    id => sprintf("horizontal-%02d", $line),
    d  => $path,
  );
}

#  vertical  lines
foreach my $line ( 1 .. $number_of_vertical_lines ) {
  my $dx = 1.1;
  my $dy = 2.5;
  my $x = $puzzle_left_margin + $line * $piece_width;
  my $path = "";
  my ( $start_direction, $end_direction );
  my ( $y_start, $y_end );
  $y_start = $puzzle_top_margin;
  $start_direction = (-1) ** (1+int(rand(2)));
  $path .= sprintf("M %5.1f %5.1f  ", $x, $y_start);
  foreach my $piece ( 1 .. ($number_of_horizontal_lines+1) ) {
    my $y_end = $puzzle_top_margin + $piece * $piece_height;
    $end_direction = (-1) ** (1+int(rand(2)));
    $path .= sprintf("C %5.1f %5.1f  %5.1f %5.1f  %5.1f %5.1f  ",
    	              $x + $start_direction * $dx, $y_start + $dy, # start control point
    	              $x + $end_direction   * $dx, $y_end   - $dy, # end control point
    	              $x      , $y_end );                          # end point
    $y_start = $y_end;
    $start_direction = (-1) * $end_direction;
  }
  $puzzle->path(
    id => sprintf("vertical-%02d", $line),
    d  => $path,
  );
}

if ($debug){
  # a 10-pointsaw-tooth pattern drawn with a path definition
  my $xv = [0,1,2,3,4,5,6,7,8,9];
  my $yv = [0,1,0,1,0,1,0,1,0,1];
  my $points = $svg->get_path(
    x => $xv,
    y => $yv,
    -type   => 'path',
    -closed => 'true'  #specify that the polyline is closed
  );
  print STDERR Dumper($points);

$puzzle->path(
            %$points,
            id    => 'pline_1',
            style => {
                'fill-opacity' => 0,
                'fill'   => 'none',
                'stroke' => 'rgb(250,123,23)'
            }
        );
}

print $svg->xmlify;
print "\n";

exit 0;

__END__
