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
  my $dx = 3;
  my $dy = 2.5;
  my $y = $puzzle_top_margin + $line * $piece_height;
  my $path = "";
  #           __
  #          /  \
  # _________\  /_____
  # start    key      end
  my $x_start = $puzzle_left_margin;
  $path .= sprintf("M %f %f  ", $x_start, $y);
  foreach my $piece ( 1 .. ($number_of_vertical_lines+1) ) {
    # https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths#Bezier_Curves
    # svg::cubic_bezier   C  starting_control_point ( x1 x2 ) ending_control_point ( x2 y2 )  end point ( x, y )
    my $x_end = $puzzle_left_margin + $piece * $piece_width;
    $path .= sprintf("C %f %f  %f %f  %f %f  ",
    	              $x_start + $dx, $y - $dy,  # start control point
    	              $x_end   - $dx, $y + $dy,  # end control point
    	              $x_end        , $y );      # end point
    $x_start = $x_end;
  }
  $puzzle->path(
    id => sprintf("horizontal-%02d", $line),
    d  => $path,
  );
}

#  vertical  lines
foreach my $line ( 1 .. $number_of_vertical_lines ) {
  my $dx = 3;
  my $dy = 2.5;
  my $x = $puzzle_left_margin + $line * $piece_width;
  my $path = "";
  my $y_start = $puzzle_top_margin;
  $path .= sprintf("M %f %f  ", $x, $y_start);
  foreach my $piece ( 1 .. ($number_of_horzontal_lines+1) ) {
    my $y_end = $puzzle_top_margin + $piece * $piece_height;
    $path .= sprintf("C %f %f  %f %f  %f %f  ",
    	              $x_start + $dx, $y - $dy,  # start control point
    	              $x_end   - $dx, $y + $dy,  # end control point
    	              $x_end        , $y );      # end point
    $y_start = $y_end;
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

    <rect
   style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.268;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none"
       id="rect4512"
       width="158.75"
       height="222.25"
       x="31.75"
       y="43" />

<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="8.5in"
   height="11in"
   viewBox="0 0 215.9 279.4"
   version="1.1"
   id="svg8"
   sodipodi:docname="jigsaw-labelled.svg"
   inkscape:version="0.92.2 5c3e80d, 2017-08-06">
  <defs
     id="defs2">
    <marker
       inkscape:isstock="true"
       style="overflow:visible"
       id="marker1859"
       refX="0.0"
       refY="0.0"
       orient="auto"
       inkscape:stockid="Arrow1Lstart">
      <path
         transform="scale(0.8) translate(12.5,0)"
         style="fill-rule:evenodd;stroke:#000000;stroke-width:1pt;stroke-opacity:1;fill:#000000;fill-opacity:1"
         d="M 0.0,0.0 L 5.0,-5.0 L -12.5,0.0 L 5.0,5.0 L 0.0,0.0 z "
         id="path1857" />
    </marker>
    <marker
       inkscape:stockid="DotM"
       orient="auto"
       refY="0.0"
       refX="0.0"
       id="DotM"
       style="overflow:visible"
       inkscape:isstock="true">
      <path
         id="path923"
         d="M -2.5,-1.0 C -2.5,1.7600000 -4.7400000,4.0 -7.5,4.0 C -10.260000,4.0 -12.5,1.7600000 -12.5,-1.0 C -12.5,-3.7600000 -10.260000,-6.0 -7.5,-6.0 C -4.7400000,-6.0 -2.5,-3.7600000 -2.5,-1.0 z "
         style="fill-rule:evenodd;stroke:#000000;stroke-width:1pt;stroke-opacity:1;fill:#000000;fill-opacity:1"
         transform="scale(0.4) translate(7.4, 1)" />
    </marker>
    <marker
       inkscape:stockid="Arrow1Lstart"
       orient="auto"
       refY="0.0"
       refX="0.0"
       id="marker1503"
       style="overflow:visible"
       inkscape:isstock="true">
      <path
         id="path1501"
         d="M 0.0,0.0 L 5.0,-5.0 L -12.5,0.0 L 5.0,5.0 L 0.0,0.0 z "
         style="fill-rule:evenodd;stroke:#000000;stroke-width:1pt;stroke-opacity:1;fill:#000000;fill-opacity:1"
         transform="scale(0.8) translate(12.5,0)" />
    </marker>
    <marker
       inkscape:stockid="DotL"
       orient="auto"
       refY="0.0"
       refX="0.0"
       id="DotL"
       style="overflow:visible"
       inkscape:isstock="true">
      <path
         id="path920"
         d="M -2.5,-1.0 C -2.5,1.7600000 -4.7400000,4.0 -7.5,4.0 C -10.260000,4.0 -12.5,1.7600000 -12.5,-1.0 C -12.5,-3.7600000 -10.260000,-6.0 -7.5,-6.0 C -4.7400000,-6.0 -2.5,-3.7600000 -2.5,-1.0 z "
         style="fill-rule:evenodd;stroke:#000000;stroke-width:1pt;stroke-opacity:1;fill:#000000;fill-opacity:1"
         transform="scale(0.8) translate(7.4, 1)" />
    </marker>
    <marker
       inkscape:isstock="true"
       style="overflow:visible"
       id="marker1313"
       refX="0.0"
       refY="0.0"
       orient="auto"
       inkscape:stockid="Arrow1Lstart">
      <path
         transform="scale(0.8) translate(12.5,0)"
         style="fill-rule:evenodd;stroke:#000000;stroke-width:1pt;stroke-opacity:1;fill:#000000;fill-opacity:1"
         d="M 0.0,0.0 L 5.0,-5.0 L -12.5,0.0 L 5.0,5.0 L 0.0,0.0 z "
         id="path1311" />
    </marker>
    <marker
       inkscape:stockid="Arrow1Lstart"
       orient="auto"
       refY="0.0"
       refX="0.0"
       id="marker1137"
       style="overflow:visible"
       inkscape:isstock="true">
      <path
         id="path1135"
         d="M 0.0,0.0 L 5.0,-5.0 L -12.5,0.0 L 5.0,5.0 L 0.0,0.0 z "
         style="fill-rule:evenodd;stroke:#000000;stroke-width:1pt;stroke-opacity:1;fill:#000000;fill-opacity:1"
         transform="scale(0.8) translate(12.5,0)" />
    </marker>
    <marker
       inkscape:stockid="Arrow1Lstart"
       orient="auto"
       refY="0.0"
       refX="0.0"
       id="Arrow1Lstart"
       style="overflow:visible"
       inkscape:isstock="true"
       inkscape:collect="always">
      <path
         id="path859"
         d="M 0.0,0.0 L 5.0,-5.0 L -12.5,0.0 L 5.0,5.0 L 0.0,0.0 z "
         style="fill-rule:evenodd;stroke:#000000;stroke-width:1pt;stroke-opacity:1;fill:#000000;fill-opacity:1"
         transform="scale(0.8) translate(12.5,0)" />
    </marker>
    <inkscape:path-effect
       effect="ruler"
       id="path-effect859"
       is_visible="true"
       unit="px"
       mark_distance="20"
       mark_length="14"
       minor_mark_length="7"
       major_mark_steps="5"
       shift="0"
       offset="0"
       mark_dir="left"
       border_marks="both" />
    <inkscape:path-effect
       effect="powerstroke"
       id="path-effect857"
       is_visible="true"
       offset_points="0.2,0.13229166 | 8,0.13229166 | 15.8,0.13229166"
       sort_points="true"
       interpolator_type="CubicBezierFit"
       interpolator_beta="0.2"
       start_linecap_type="butt"
       linejoin_type="extrp_arc"
       miter_limit="4"
       end_linecap_type="butt" />
  </defs>
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="1"
     inkscape:cx="171.78051"
     inkscape:cy="674.97562"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     showgrid="true"
     showguides="false"
     inkscape:guide-bbox="true"
     units="in"
     inkscape:window-width="1385"
     inkscape:window-height="784"
     inkscape:window-x="0"
     inkscape:window-y="1"
     inkscape:window-maximized="0"
     gridtolerance="5"
     guidetolerance="5">
    <sodipodi:guide
       position="50.567504,49.771165"
       orientation="0,1"
       id="guide815"
       inkscape:locked="false" />
    <sodipodi:guide
       position="50.169335,211.02974"
       orientation="1,0"
       id="guide817"
       inkscape:locked="false" />
    <sodipodi:guide
       position="99.940497,193.90846"
       orientation="1,0"
       id="guide819"
       inkscape:locked="false" />
    <inkscape:grid
       type="xygrid"
       id="grid821"
       units="in"
       spacingx="6.35"
       spacingy="6.35"
       snapvisiblegridlinesonly="false"
       dotted="false" />
  </sodipodi:namedview>
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(0,-17.6)">

    <rect
   style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.268;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none"
       id="rect4512"
       width="158.75"
       height="222.25"
       x="31.75"
       y="43" />




    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="m 31.750001,138.25 h 6.35 H 44.45 c 0,0 4.233333,0 6.35,0 -6.264618,-6.46407 12.700001,-6.35 6.35,0 2.116667,0 6.35,0 6.35,0 h 6.35 6.35 c -6.349999,-12.7 12.700001,-12.7 6.35,0 h 6.35 6.35 l 6.35,0 c 0,6.35 12.7,12.7 6.35,0 h 6.35 6.35 l 6.35,0 h 6.35 6.35 c -6.35,-6.35 12.7,-6.35 6.35,0 h 6.35 6.35 l 6.35,0 h 6.35 6.35 c 0,12.7 12.7,7.78574 6.35,0 h 6.35"
       id="horizontal03"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cccccccccccccccccccccccccc" />
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="m 63.499999,43 v 6.35 c -12.699999,0 -6.349999,6.35 0,6.35 v 6.349999 6.35 6.35 6.35 6.35 C 69.85,81.1 69.85,93.8 63.499999,93.799999 v 6.350001 6.35 6.35 6.35 6.35 c 6.350001,-6.35 12.700001,6.35 0,6.35 v 6.35 6.35 6.35 c -7.595846,0 -12.699999,12.7 0,6.35 v 6.35 6.35 6.35 6.35 c -12.699999,0 -12.699999,12.7 0,6.35 v 6.35 6.35 6.35 6.35 c 0,0 0,4.23333 0,6.35 6.350001,-6.35 6.350001,6.35 0,6.35 0,2.11667 0,6.35 0,6.35 v 6.35 6.35 c 0,0 0,4.23333 0,6.35 -12.699999,-6.35 -12.699999,6.35 0,6.35 0,2.11667 0,6.35 0,6.35"
       id="vertical01"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cccccccccccccccccccccccccccccccccccc" />
    <path
       sodipodi:nodetypes="cccccccccccccccc"
       inkscape:connector-curvature="0"
       id="horizontal02"
       d="m 190.5,106.5 c -6.35,0 -12.7,0 -19.05,0 6.26462,6.46407 -12.7,6.35 -6.35,0 h -6.35 c -4.23333,0 -8.46667,0 -12.7,0 6.35,12.7 -12.7,6.35 -6.35,0 -4.23333,0 -8.46667,0 -12.7,0 h -6.35 c 0,6.35 -12.7,12.7 -6.35,0 -6.35,0 -12.7,0 -19.05,0 -4.233333,0 -8.466667,0 -12.7,0 6.35,6.35 -12.7,6.35 -6.35,0 -4.233333,0 -8.466667,0 -12.7,0 H 44.45 c 0,-12.700001 -12.7,-7.785743 -6.35,0 h -6.35"
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1" />
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="m 31.750001,170 h 6.35 H 44.45 c 0,0 4.233333,0 6.35,0 -6.264618,6.46407 12.700001,6.35 6.35,0 2.116667,0 6.35,0 6.35,0 h 6.35 6.35 c -6.349999,12.7 12.700001,12.7 6.35,0 h 6.35 6.35 l 6.35,0 c 0,-6.35 12.7,-12.7 6.35,0 h 6.35 6.35 l 6.35,0 h 6.35 6.35 c -6.35,6.35 12.7,6.35 6.35,0 h 6.35 6.35 l 6.35,0 h 6.35 6.35 c 0,-12.7 12.7,-7.78574 6.35,0 h 6.35"
       id="horizontal04"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cccccccccccccccccccccccccc" />
    <path
       sodipodi:nodetypes="cccsccccccccccccc"
       inkscape:connector-curvature="0"
       id="horizontal01"
       d="M 0,297 31.75,74.749999 c 2.322224,1.644459 4.331582,0.785991 6.35,10e-7 -6.35,7.78574 11.924536,7.040564 6.35,0 -0.834217,-1.053604 12.7,-1.13938 19.05,0 4.423229,1.70907 8.466667,1.70907 12.7,0 -6.35,-6.35 12.7,-6.35 6.35,0 4.233333,-0.94948 8.656563,1.51917 12.7,0 h 19.05 c -6.35,12.700001 6.35,6.35 6.35,0 0,0 3.65487,-2.583047 6.35,0 4.35135,0 8.46667,-0.862772 12.7,0 -6.35,-12.7 12.7,-12.7 6.35,0 4.18321,0.862772 8.20768,0.862772 12.7,0 h 6.35 c -6.35,-6.35 12.7,-12.7 6.35,0 6.35,-1.329273 12.7,2.088858 19.05,0"
       style="fill:none;fill-rule:nonzero;stroke:#000000;stroke-width:0.07;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       inkscape:label="#horizontal01" />
    <path
       sodipodi:nodetypes="cccccccccccccccccccccccccc"
       inkscape:connector-curvature="0"
       id="horizontal05"
       d="m 31.750001,201.75 h 6.35 H 44.45 50.8 c 0,12.7 12.700001,6.35 6.35,0 h 6.35 6.35 6.35 c -6.349999,12.7 6.35,6.35 6.35,0 h 6.35 6.35 6.35 c 0,-6.35 12.7,-12.7 6.35,0 h 6.35 6.35 6.35 6.35 6.35 c 0,-6.35 6.35,-6.35 6.35,0 h 6.35 6.35 6.35 6.35 6.35 c -6.35,12.7 12.7,12.7 6.35,0 h 6.35"
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1" />
    <path
       sodipodi:nodetypes="cccccccccccccccccccccccccc"
       inkscape:connector-curvature="0"
       id="horizontal06"
       d="m 31.750001,233.5 h 6.35 H 44.45 50.8 c -6.35,-6.35 0,-6.35 6.35,0 h 6.35 6.35 6.35 c -6.35,6.35 12.700001,12.7 6.35,0 h 6.35 6.35 6.35 c -6.35,6.35 12.7,12.7 6.35,0 h 6.35 6.35 6.35 6.35 6.35 c -12.7,6.35 12.7,6.35 6.35,0 h 6.35 6.35 6.35 6.35 6.35 c -6.35,-6.35 12.7,-7.78574 6.35,0 h 6.35"
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1" />
    <path
       sodipodi:nodetypes="cccccccccccccccccccccccccccccccccccc"
       inkscape:connector-curvature="0"
       id="vertical03"
       d="m 127,265.25 v -6.35 c -12.7,0 -6.35,-6.35 0,-6.35 v -6.35 -6.35 -6.35 -6.35 -6.35 c 6.35,6.35 6.35,-6.35 0,-6.35 v -6.35 -6.35 -6.35 -6.35 -6.35 c 6.35,6.35 12.7,-6.35 0,-6.35 V 170 163.65 157.3 c -7.59585,0 -12.7,-12.7 0,-6.35 v -6.35 -6.35 -6.35 -6.35 c -12.7,0 -12.7,-12.7 0,-6.35 v -6.35 -6.35 -6.35 -6.35 c 0,0 0,-4.23333 0,-6.35 6.35,6.35 6.35,-6.35 0,-6.35 0,-2.11667 0,-6.35 0,-6.35 V 68.4 62.05 c 0,0 0,-4.23333 0,-6.35 -12.7,6.35 -12.7,-6.35 0,-6.35 0,-2.11667 0,-6.35 0,-6.35"
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1" />
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="m 158.75,265.25 v -6.35 c 12.7,0 12.7,-6.35 0,-6.35 v -6.35 -6.35 -6.35 -6.35 -6.35 c -12.7,6.35 -6.35,-6.35 0,-6.35 v -6.35 -6.35 -6.35 -6.35 -6.35 c -6.35,6.35 -12.7,-6.35 0,-6.35 V 170 c 2.27875,-6.35 2.08886,-6.35 0,-12.7 6.35,6.35 12.7,-12.7 0,-6.35 -4.17772,-6.35 -3.60803,-6.35 0,-12.7 v -6.35 -6.35 c 12.7,0 12.7,-12.7 0,-6.35 v -6.35 -6.35 -6.35 -6.35 -6.35 c -6.35,6.35 -6.35,-6.35 0,-6.35 V 74.75 68.4 62.05 55.7 c 12.7,6.35 12.7,-6.35 0,-6.35 V 43"
       id="vertical04"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cccccccccccccccccccccccccccccccccc" />
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="m 95.25,43 v 6.35 c 12.7,0 6.35,12.7 0,6.35 v 6.35 6.35 6.35 6.35 6.35 c 6.35,-6.35 12.7,6.35 0,6.35 v 6.35 6.35 6.35 6.35 6.35 c 6.35,-6.35 19.05,6.35 0,6.35 v 6.35 6.35 6.35 c 6.35,-6.35 10.23135,12.7 0,6.35 v 6.35 6.35 6.35 6.35 c 12.7,0 12.7,12.7 0,6.35 v 6.35 6.35 6.35 6.35 6.35 c -6.35,-6.35 -12.7,6.35 0,6.35 v 6.35 6.35 6.35 6.35 c 12.7,-6.35 12.7,12.7 0,6.35 v 6.35"
       id="vertical02"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cccccccccccccccccccccccccccccccccccc" />
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.5;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none"
       d="m 31.75,31.335303 6.243531,-5.676238 C 40.934742,22.985096 46.851209,21.143538 50.8,22.430831 c 2.298115,0.749178 3.932853,3.501558 6.35,3.501558 2.417147,0 6.35,-6.729792 6.35,-6.729792 0,0 3.90166,6.919688 6.35,6.919688 2.44834,0 4.016189,-2.95139 6.35,-3.691454 4.132582,-1.310465 8.507008,0.353799 12.426676,3.038338 C 92.378781,28.038946 95.25,30.3 95.25,30.3"
       id="brace_template"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cssscsssc" />
    <path
       sodipodi:nodetypes="cssscsssc"
       inkscape:connector-curvature="0"
       id="brace01"
       d="m 31.727172,42.944907 3.126255,-2.983039 c 1.472721,-1.405254 4.435209,-2.37305 6.412445,-1.696537 1.150709,0.393716 1.969254,1.840177 3.179566,1.840177 1.210311,0 3.179567,-3.536715 3.179567,-3.536715 0,0 1.953635,3.636511 3.179566,3.636511 1.22593,0 2.010983,-1.551047 3.179566,-1.939973 2.069263,-0.68869 4.259622,0.185932 6.222275,1.596741 1.878751,1.350498 3.316425,2.538751 3.316425,2.538751"
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.25648755;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    <text
       xml:space="preserve"
       style="font-style:normal;font-weight:normal;font-size:4.23333311px;line-height:125%;font-family:Sans;letter-spacing:0px;word-spacing:0px;fill:#000000;fill-opacity:1;stroke:none;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       x="72.920113"
       y="38.741253"
       id="text4632"><tspan
         sodipodi:role="line"
         id="tspan4630"
         x="72.920113"
         y="38.741253"
         style="stroke-width:0.26458332px">Piece</tspan></text>
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;marker-start:url(#marker1313)"
       d="m 95.249999,43 3.41813,-6.35"
       id="path4634"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cc" />
    <text
       xml:space="preserve"
       style="font-style:normal;font-weight:normal;font-size:4.23333311px;line-height:125%;font-family:Sans;letter-spacing:0px;word-spacing:0px;fill:#000000;fill-opacity:1;stroke:none;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       x="98.668129"
       y="36.650002"
       id="text4638"><tspan
         sodipodi:role="line"
         x="98.668129"
         y="36.650002"
         style="stroke-width:0.26458332px"
         id="tspan4640">Node</tspan></text>
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.23147784px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;marker-start:url(#marker1137)"
       d="M 123.0396,53.181003 C 137.4982,39.108059 137.30796,39.108059 137.30796,39.108059"
       id="path4644"
       inkscape:connector-curvature="0" />
    <text
       xml:space="preserve"
       style="font-style:normal;font-weight:normal;font-size:4.23333311px;line-height:125%;font-family:Sans;letter-spacing:0px;word-spacing:0px;fill:#000000;fill-opacity:1;stroke:none;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       x="137.29491"
       y="37.981667"
       id="text4648"><tspan
         sodipodi:role="line"
         id="tspan4646"
         x="137.29491"
         y="37.981667"
         style="stroke-width:0.26458332px">Key</tspan></text>
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.265;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none;marker-start:url(#Arrow1Lstart)"
       d="M 165.1,50.704709 C 168.43787,36.65 168.43787,36.65 168.43787,36.65"
       id="path4650"
       inkscape:connector-curvature="0" />
    <text
       xml:space="preserve"
       style="font-style:normal;font-weight:normal;font-size:4.23333311px;line-height:125%;font-family:Sans;letter-spacing:0px;word-spacing:0px;fill:#000000;fill-opacity:1;stroke:none;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       x="168.43787"
       y="36.650002"
       id="text4654"><tspan
         sodipodi:role="line"
         id="tspan4652"
         x="168.43787"
         y="36.650002"
         style="stroke-width:0.26458332px">Hole</tspan><tspan
         sodipodi:role="line"
         x="168.43787"
         y="41.941669"
         style="stroke-width:0.26458332px"
         id="tspan4656" /></text>
    <flowRoot
       xml:space="preserve"
       id="flowRoot4658"
       style="fill:black;stroke:none;stroke-opacity:1;stroke-width:1px;stroke-linejoin:miter;stroke-linecap:butt;fill-opacity:1;font-family:Sans;font-style:normal;font-weight:normal;font-size:16px;line-height:125%;letter-spacing:0px;word-spacing:0px"><flowRegion
         id="flowRegion4660"><rect
           id="rect4662"
           width="37.462467"
           height="32.297295"
           x="82.537537"
           y="123.68472" /></flowRegion><flowPara
         id="flowPara4664" /></flowRoot>    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;marker-start:url(#marker1859)"
       d="M 31.75,62.049999 C 25.4,58.300555 25.4,58.300555 25.4,58.300555"
       id="path4666"
       inkscape:connector-curvature="0" />
    <text
       xml:space="preserve"
       style="font-style:normal;font-weight:normal;font-size:4.23333311px;line-height:125%;font-family:Sans;letter-spacing:0px;word-spacing:0px;fill:#000000;fill-opacity:1;stroke:none;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       x="19.323322"
       y="56.781387"
       id="text4670"><tspan
         sodipodi:role="line"
         x="19.323322"
         y="56.781387"
         style="stroke-width:0.26458332px"
         id="tspan4672">Edge</tspan></text>
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:0.22429207px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;marker-end:url(#DotM)"
       d="m 78.616182,39.692056 0.191532,16.006621"
       id="path4676"
       inkscape:connector-curvature="0" />
  </g>
</svg>



NAME
    SVG - Perl extension for generating Scalable Vector Graphics (SVG) documents.

SYNOPSIS
        #!/usr/bin/perl
        use strict;
        use warnings;
        use SVG;

        # create an SVG object
        my $svg= SVG->new( width => 200, height => 200);

        # use explicit element constructor to generate a group element
        my $y = $svg->group(
            id => 'group_y',
            style => {
                stroke => 'red',
                fill   => 'green'
            },
        );

        # add a circle to the group
        $y->circle( cx => 100, cy => 100, r => 50, id => 'circle_in_group_y' );

        # or, use the generic 'tag' method to generate a group element by name
        my $z = $svg->tag('g',
                        id    => 'group_z',
                        style => {
                            stroke => 'rgb(100,200,50)',
                            fill   => 'rgb(10,100,150)'
                        }
                    );

        # create and add a circle using the generic 'tag' method
        $z->tag('circle', cx => 50, cy => 50, r => 100, id => 'circle_in_group_z');

        # create an anchor on a rectangle within a group within the group z
        my $k = $z->anchor(
            id      => 'anchor_k',
            -href   => 'http://test.hackmare.com/',
            target => 'new_window_0'
        )->rectangle(
            x     => 20, y      => 50,
            width => 20, height => 30,
            rx    => 10, ry     => 5,
            id    => 'rect_k_in_anchor_k_in_group_z'
        );

        # now render the SVG object, implicitly use svg namespace
        print $svg->xmlify;

        # or render a child node of the SVG object without rendering the entire object
        print $k->xmlify; #renders the anchor $k above containing a rectangle, but does not
                          #render any of the ancestor nodes of $k

        # or, explicitly use svg namespace and generate a document with its own DTD
        print $svg->xmlify(-namespace=>'svg');

        # or, explicitly use svg namespace and generate an inline docunent
        print $svg->xmlify(
            -namespace => "svg",
            -pubid => "-//W3C//DTD SVG 1.0//EN",
            -inline   => 1
        );

    See the other modules in this distribution: SVG::DOM, SVG::XML, SVG::Element, SVG::Parser, SVG::Extension

  Converting SVG to PNG and other raster image formats
    The convert command of <http://www.imagemagick.org/> (also via Image::Magick ) can convert SVG files to PNG and other formats.

    Image::LibRSVG can convert SVG to other format.

EXAMPLES
    examples/circle.pl generates the following image:

      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
      <svg height="200" width="200" xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      <title >I am a title</title>
      <g id="group_y" style="fill: green; stroke: red">
      <circle cx="100" cy="100" id="circle_in_group_y" r="50" />
      <!-- This is a comment -->
      </g>
      </svg>

    That you can either embed directly into HTML or can include it using:

       <object data="file.svg" type="image/svg+xml"></object>

    (The image was converted to png using Image::LibRSVG. See the svg2png.pl script in the examples directory.)

    See also the examples directory in this distribution which contain several fully documented examples.

DESCRIPTION
    SVG is a 100% Perl module which generates a nested data structure containing the DOM representation of an SVG (Scalable Vector Graphics) image. Using SVG, you can
    generate SVG objects, embed other SVG instances into it, access the DOM object, create and access javascript, and generate SMIL animation content.

  General Steps to generating an SVG document
    Generating SVG is a simple three step process:

    1 Construct a new SVG object with "new".
    2 Call element constructors such as "circle" and "path" to create SVG elements.
    3 Render the SVG object into XML using the "xmlify" method.

    The "xmlify" method takes a number of optional arguments that control how SVG renders the object into XML, and in particular determine whether a standalone SVG document
    or an inline SVG document fragment is generated:

  -standalone
    A complete SVG document with its own associated DTD. A namespace for the SVG elements may be optionally specified.

  -inline
    An inline SVG document fragment with no DTD that be embedded within other XML content. As with standalone documents, an alternate namespace may be specified.

    No XML content is generated until the third step is reached. Up until this point, all constructed element definitions reside in a DOM-like data structure from which they
    can be accessed and modified.

  EXPORTS
    None. However, SVG permits both options and additional element methods to be specified in the import list. These options and elements are then available for all SVG
    instances that are created with the "new" constructor. For example, to change the indent string to two spaces per level:

        use SVG (-indent => "  ");

    With the exception of -auto, all options may also be specified to the "new" constructor. The currently supported options and their default value are:

        # processing options
        -auto       => 0,       # permit arbitrary autoloading of all unrecognised elements
        -printerror => 1,       # print error messages to STDERR
        -raiseerror => 1,       # die on errors (implies -printerror)

        # rendering options
        -indent     => "\t",    # what to indent with
        -elsep      => "\n",    # element line (vertical) separator
                                #     (note that not all agents ignor trailing blanks)
        -nocredits  => 0,       # enable/disable credit note comment
        -namespace  => '',      # The root element's (and it's children's) namespace prefix

        # XML and Doctype declarations
        -inline     => 0,       # inline or stand alone
        -docroot    => 'svg',   # The document's root element
        -version    => '1.0',
        -extension  => '',
        -encoding   => 'UTF-8',
        -xml_svg    => 'http://www.w3.org/2000/svg',   # the svg xmlns attribute
        -xml_xlink  => 'http://www.w3.org/1999/xlink', # the svg tag xmlns:xlink attribute
        -standalone => 'yes',
        -pubid      => "-//W3C//DTD SVG 1.0//EN",      # formerly -identifier
        -sysid      => 'http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd', # the system id

    SVG also allows additional element generation methods to be specified in the import list. For example to generate 'star' and 'planet' element methods:

        use SVG qw(star planet);

    or:

        use SVG ("star","planet");

    This will add 'star' to the list of elements supported by SVG.pm (but not of course other SVG parsers...). Alternatively the '-auto' option will allow any unknown method
    call to generate an element of the same name:

        use SVG (-auto => 1, "star", "planet");

    Any elements specified explicitly (as 'star' and 'planet' are here) are predeclared; other elements are defined as and when they are seen by Perl. Note that enabling
    '-auto' effectively disables compile-time syntax checking for valid method names.

        use SVG (
            -auto       => 0,
            -indent     => "  ",
            -raiseerror  => 0,
            -printerror => 1,
            "star", "planet", "moon"
        );

  Default SVG tag
    The Default SVG tag will generate the following XML:

      $svg = SVG->new;
      print $svg->xmlify;

    Resulting XML snippet:

      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
      <svg height="100%" width="100%" xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
          <!--
            Generated using the Perl SVG Module V2.50
              by Ronan Oger
            Info: http://www.roitsystems.com/
          -->

METHODS
    SVG provides both explicit and generic element constructor methods. Explicit generators are generally (with a few exceptions) named for the element they generate. If a
    tag method is required for a tag containing hyphens, the method name replaces the hyphen with an underscore. ie: to generate tag <column-heading id="new"> you would use
    method $svg->column_heading(id=>'new').

    All element constructors take a hash of element attributes and options; element attributes such as 'id' or 'border' are passed by name, while options for the method (such
    as the type of an element that supports multiple alternate forms) are passed preceded by a hyphen, e.g '-type'. Both types may be freely intermixed; see the "fe" method
    and code examples throughout the documentation for more examples.

  new (constructor)
    $svg = SVG->new(%attributes)

    Creates a new SVG object. Attributes of the document SVG element be passed as an optional list of key value pairs. Additionally, SVG options (prefixed with a hyphen) may
    be set on a per object basis:

        my $svg1 = SVG->new;

        my $svg2 = SVG->new(id => 'document_element');

        my $svg3 = SVG->new(
            -printerror => 1,
            -raiseerror => 0,
            -indent     => '  ',
            -docroot => 'svg', #default document root element (SVG specification assumes svg). Defaults to 'svg' if undefined
            -sysid      => 'abc', #optional system identifyer
            -pubid      => "-//W3C//DTD SVG 1.0//EN", #public identifyer default value is "-//W3C//DTD SVG 1.0//EN" if undefined
            -namespace => 'mysvg',
            -inline   => 1
            id          => 'document_element',
            width       => 300,
            height      => 200,
        );

    SVG instance represents the document and not the "<svg>" root element.

    Default SVG options may also be set in the import list. See "EXPORTS" above for more on the available options.

    Furthermore, the following options:

        -version
        -encoding
        -standalone
        -namespace Defines the document or element level namespace. The order of assignment priority is element,document .
        -inline
        -identifier
        -nostub
        -dtd (standalone)

    may also be set in xmlify, overriding any corresponding values set in the SVG->new declaration

  xmlify (alias: to_xml render serialise serialize)
    $string = $svg->xmlify(%attributes);

    Returns xml representation of svg document.

    XML Declaration

        Name               Default Value
        -version           '1.0'
        -encoding          'UTF-8'
        -standalone        'yes'
        -namespace         'svg'                - namespace for elements
        -inline            '0' - If '1', then this is an inline document.
        -pubid             '-//W3C//DTD SVG 1.0//EN';
        -dtd (standalone)  'http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd'

  tag (alias: element)
    $tag = $svg->tag($name, %attributes)

    Generic element generator. Creates the element named $name with the attributes specified in %attributes. This method is the basis of most of the explicit element
    generators.

        my $tag = $svg->tag('g', transform=>'rotate(-45)');

  anchor
    $tag = $svg->anchor(%attributes)

    Generate an anchor element. Anchors are put around objects to make them 'live' (i.e. clickable). It therefore requires a drawn object or group element as a child.

   optional anchor attributes
    the following attributes are expected for anchor tags (any any tags which use -href links):

  -href    required
  -type    optional
  -role    optional
  -title   optional
  -show    optional
  -arcrole optional
  -actuate optional
  target   optional
    For more information on the options, refer to the w3c XLink specification at <http://www.w3.org/TR/xlink/>

    Example:

        # generate an anchor
        $tag = $SVG->anchor(
             -href=>'http://here.com/some/simpler/SVG.SVG'
             -title => 'new window 2 example title',
             -actuate => 'onLoad',
             -show=> 'embed',

        );

    for more information about the options above, refer to Link section in the SVG recommendation: <http://www.w3.org/TR/SVG11/linking.html#Links>

        # add a circle to the anchor. The circle can be clicked on.
        $tag->circle(cx => 10, cy => 10, r => 1);

        # more complex anchor with both URL and target
        $tag = $SVG->anchor(
              -href   => 'http://somewhere.org/some/other/page.html',
              target => 'new_window'
        );

        # generate an anchor
        $tag = $svg->anchor(
            -href=>'http://here.com/some/simpler/svg.svg'
        );
        # add a circle to the anchor. The circle can be clicked on.
        $tag->circle(cx => 10, cy => 10, r => 1);

        # more complex anchor with both URL and target
        $tag = $svg->anchor(
              -href   => 'http://somewhere.org/some/other/page.html',
              target => 'new_window'
        );

  circle
    $tag = $svg->circle(%attributes)

    Draw a circle at (cx,cy) with radius r.

        my $tag = $svg->circle(cx => 4, cy => 2, r => 1);

  ellipse
    $tag = $svg->ellipse(%attributes)

    Draw an ellipse at (cx,cy) with radii rx,ry.

        use SVG;

        # create an SVG object
        my $svg= SVG->new( width => 200, height => 200);

        my $tag = $svg->ellipse(
            cx => 10,
            cy => 10,
            rx => 5,
            ry => 7,
            id => 'ellipse',
            style => {
                'stroke'         => 'red',
                'fill'           => 'green',
                'stroke-width'   => '4',
                'stroke-opacity' => '0.5',
                'fill-opacity'   => '0.2',
            }
        );

    See The example/ellipse.pl

  rectangle (alias: rect)
    $tag = $svg->rectangle(%attributes)

    Draw a rectangle at (x,y) with width 'width' and height 'height' and side radii 'rx' and 'ry'.

        $tag = $svg->rectangle(
            x      => 10,
            y      => 20,
            width  => 4,
            height => 5,
            rx     => 5.2,
            ry     => 2.4,
            id     => 'rect_1'
        );

  image
     $tag = $svg->image(%attributes)

    Draw an image at (x,y) with width 'width' and height 'height' linked to image resource '-href'. See also "use".

        $tag = $svg->image(
            x       => 100,
            y       => 100,
            width   => 300,
            height  => 200,
            '-href' => "image.png", #may also embed SVG, e.g. "image.svg"
            id      => 'image_1'
        );

    Output:

        <image xlink:href="image.png" x="100" y="100" width="300" height="200"/>

  use
    $tag = $svg->use(%attributes)

    Retrieve the content from an entity within an SVG document and apply it at (x,y) with width 'width' and height 'height' linked to image resource '-href'.

        $tag = $svg->use(
            x       => 100,
            y       => 100,
            width   => 300,
            height  => 200,
            '-href' => "pic.svg#image_1",
            id      => 'image_1'
        );

    Output:

        <use xlink:href="pic.svg#image_1" x="100" y="100" width="300" height="200"/>

    According to the SVG specification, the 'use' element in SVG can point to a single element within an external SVG file.

  polygon
    $tag = $svg->polygon(%attributes)

    Draw an n-sided polygon with vertices at points defined by a string of the form 'x1,y1,x2,y2,x3,y3,... xy,yn'. The "get_path" method is provided as a convenience to
    generate a suitable string from coordinate data.

        # a five-sided polygon
        my $xv = [0, 2, 4, 5, 1];
        my $yv = [0, 0, 2, 7, 5];

        my $points = $svg->get_path(
            x     =>  $xv,
            y     =>  $yv,
            -type =>'polygon'
        );

        my $poly = $svg->polygon(
            %$points,
            id    => 'pgon1',
            style => \%polygon_style
        );

    SEE ALSO:

    "polyline", "path", "get_path".

  polyline
    $tag = $svg->polyline(%attributes)

    Draw an n-point polyline with points defined by a string of the form 'x1,y1,x2,y2,x3,y3,... xy,yn'. The "get_path" method is provided as a convenience to generate a
    suitable string from coordinate data.

        # a 10-pointsaw-tooth pattern
        my $xv = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
        my $yv = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1];

        my $points = $svg->get_path(
            x       => $xv,
            y       => $yv,
            -type   => 'polyline',
            -closed => 'true' #specify that the polyline is closed.
        );

        my $tag = $svg->polyline (
            %$points,
            id    =>'pline_1',
            style => {
                'fill-opacity' => 0,
                'stroke'       => 'rgb(250,123,23)'
            }
        );

  line
    $tag = $svg->line(%attributes)

    Draw a straight line between two points (x1,y1) and (x2,y2).

        my $tag = $svg->line(
            id => 'l1',
            x1 =>  0,
            y1 => 10,
            x2 => 10,
            y2 =>  0,
        );

    To draw multiple connected lines, use "polyline".

  text
    $text = $svg->text(%attributes)->cdata();

    $text_path = $svg->text(-type=>'path'); $text_span = $text_path->text(-type=>'span')->cdata('A'); $text_span = $text_path->text(-type=>'span')->cdata('B'); $text_span =
    $text_path->text(-type=>'span')->cdata('C');

    Define the container for a text string to be drawn in the image.

    Input:

        -type     = path type (path | polyline | polygon)
        -type     = text element type  (path | span | normal [default])

        my $text1 = $svg->text(
            id => 'l1',
            x  => 10,
            y  => 10
        )->cdata('hello, world');

        my $text2 = $svg->text(
            id     => 'l1',
            x      => 10,
            y      => 10,
            -cdata => 'hello, world',
        );

        my $text = $svg->text(
            id    => 'tp',
            x     => 10,
            y     => 10,
            -type => path,
        )
          ->text(id=>'ts' -type=>'span')
          ->cdata('hello, world');

    SEE ALSO:

    "desc", "cdata".

  title
    $tag = $svg->title(%attributes)

    Generate the title of the image.

        my $tag = $svg->title(id=>'document-title')->cdata('This is the title');

  desc
    $tag = $svg->desc(%attributes)

    Generate the description of the image.

        my $tag = $svg->desc(id=>'document-desc')->cdata('This is a description');

  comment
    $tag = $svg->comment(@comments)

    Generate the description of the image.

        my $tag = $svg->comment('comment 1','comment 2','comment 3');

  pi (Processing Instruction)
    $tag = $svg->pi(@pi)

    Generate a set of processing instructions

        my $tag = $svg->pi('instruction one','instruction two','instruction three');

        returns:
          <lt>?instruction one?<gt>
          <lt>?instruction two?<gt>
          <lt>?instruction three?<gt>

  script
    $tag = $svg->script(%attributes)

    Generate a script container for dynamic (client-side) scripting using ECMAscript, Javascript or other compatible scripting language.

        my $tag = $svg->script(-type=>"text/ecmascript");
        #or my $tag = $svg->script();
        #note that type ecmascript is not Mozilla compliant

        # populate the script tag with cdata
        # be careful to manage the javascript line ends.
        # Use qq{text} or q{text} as appropriate.
        # make sure to use the CAPITAL CDATA to poulate the script.
        $tag->CDATA(qq{
            function d() {
            //simple display function
              for(cnt = 0; cnt < d.length; cnt++)
                document.write(d[cnt]);//end for loop
            document.write("<BR>");//write a line break
            }
        });

  path
    $tag = $svg->path(%attributes)

    Draw a path element. The path vertices may be provided as a parameter or calculated using the "get_path" method.

        # a 10-pointsaw-tooth pattern drawn with a path definition
        my $xv = [0,1,2,3,4,5,6,7,8,9];
        my $yv = [0,1,0,1,0,1,0,1,0,1];

        $points = $svg->get_path(
            x => $xv,
            y => $yv,
            -type   => 'path',
            -closed => 'true'  #specify that the polyline is closed
        );

        $tag = $svg->path(
            %$points,
            id    => 'pline_1',
            style => {
                'fill-opacity' => 0,
                'fill'   => 'green',
                'stroke' => 'rgb(250,123,23)'
            }
        );

    SEE ALSO: "get_path".

  get_path
    $path = $svg->get_path(%attributes)

    Returns the text string of points correctly formatted to be incorporated into the multi-point SVG drawing object definitions (path, polyline, polygon)

    Input: attributes including:

        -type     = path type (path | polyline | polygon)
        x         = reference to array of x coordinates
        y         = reference to array of y coordinates

    Output: a hash reference consisting of the following key-value pair:

        points    = the appropriate points-definition string
        -type     = path|polygon|polyline
        -relative = 1 (define relative position rather than absolute position)
        -closed   = 1 (close the curve - path and polygon only)

        #generate an open path definition for a path.
        my ($points,$p);
        $points = $svg->get_path(x=&gt\@x,y=&gt\@y,-relative=&gt1,-type=&gt'path');

        #add the path to the SVG document
        my $p = $svg->path(%$path, style=>\%style_definition);

        #generate an closed path definition for a a polyline.
        $points = $svg->get_path(
            x=>\@x,
            y=>\@y,
            -relative=>1,
            -type=>'polyline',
            -closed=>1
        ); # generate a closed path definition for a polyline

        # add the polyline to the SVG document
        $p = $svg->polyline(%$points, id=>'pline1');

    Aliases: get_path set_path

  animate
    $tag = $svg->animate(%attributes)

    Generate an SMIL animation tag. This is allowed within any nonempty tag. Refer to the W3C for detailed information on the subtleties of the animate SMIL commands.

    Inputs: -method = Transform | Motion | Color

      my $an_ellipse = $svg->ellipse(
          cx     => 30,
          cy     => 150,
          rx     => 10,
          ry     => 10,
          id     => 'an_ellipse',
          stroke => 'rgb(130,220,70)',
          fill   =>'rgb(30,20,50)'
      );

      $an_ellipse-> animate(
          attributeName => "cx",
          values        => "20; 200; 20",
          dur           => "10s",
          repeatDur     => 'indefinite'
      );

      $an_ellipse-> animate(
          attributeName => "rx",
          values        => "10;30;20;100;50",
          dur           => "10s",
          repeatDur     => 'indefinite',
      );

      $an_ellipse-> animate(
          attributeName => "ry",
          values        => "30;50;10;20;70;150",
          dur           => "15s",
          repeatDur     => 'indefinite',
      );

      $an_ellipse-> animate(
          attributeName=>"rx",values=>"30;75;10;100;20;20;150",
          dur=>"20s", repeatDur=>'indefinite');

      $an_ellipse-> animate(
          attributeName=>"fill",values=>"red;green;blue;cyan;yellow",
          dur=>"5s", repeatDur=>'indefinite');

      $an_ellipse-> animate(
          attributeName=>"fill-opacity",values=>"0;1;0.5;0.75;1",
          dur=>"20s",repeatDur=>'indefinite');

      $an_ellipse-> animate(
          attributeName=>"stroke-width",values=>"1;3;2;10;5",
          dur=>"20s",repeatDur=>'indefinite');

  group
    $tag = $svg->group(%attributes)

    Define a group of objects with common properties. Groups can have style, animation, filters, transformations, and mouse actions assigned to them.

        $tag = $svg->group(
            id        => 'xvs000248',
            style     => {
                'font'      => [ qw( Arial Helvetica sans ) ],
                'font-size' => 10,
                'fill'      => 'red',
            },
            transform => 'rotate(-45)'
        );

  defs
    $tag = $svg->defs(%attributes)

    define a definition segment. A Defs requires children when defined using SVG.pm

        $tag = $svg->defs(id  =>  'def_con_one',);

  style
    $svg->tag('style', %styledef);

    Sets/Adds style-definition for the following objects being created.

    Style definitions apply to an object and all its children for all properties for which the value of the property is not redefined by the child.

      $tag = $SVG->style(%attributes)

    Generate a style container for inline or xlink:href based styling instructions

        my $tag = $SVG->style(type=>"text/css");

        # Populate the style tag with cdata.
        # Be careful to manage the line ends.
        # Use qq{text}, where text is the script

        $tag1->CDATA(qq{
            rect     fill:red;stroke:green;
            circle   fill:red;stroke:orange;
            ellipse  fill:none;stroke:yellow;
            text     fill:black;stroke:none;
        });

        # Create a external CSS stylesheet reference
        my $tag2 = $SVG->style(type=>"text/css", -href="/resources/example.css");

  mouseaction
    $svg->mouseaction(%attributes)

    Sets/Adds mouse action definitions for tag

  attrib
      $svg->attrib($name, $value)

    Sets/Adds attributes of an element.

    Retrieve an attribute:

        $svg->attrib($name);

    Set a scalar attribute:

        $SVG->attrib $name, $value

    Set a list attribute:

        $SVG->attrib $name, \@value

    Set a hash attribute (i.e. style definitions):

        $SVG->attrib $name, \%value

    Remove an attribute:

        $svg->attrib($name,undef);

    Aliases: attr attribute

    Sets/Replaces attributes for a tag.

  cdata
    $svg->cdata($text)

    Sets cdata to $text. SVG.pm allows you to set cdata for any tag. If the tag is meant to be an empty tag, SVG.pm will not complain, but the rendering agent will fail. In
    the SVG DTD, cdata is generally only meant for adding text or script content.

        $svg->text(
            style => {
                'font'      => 'Arial',
                'font-size' => 20
            })->cdata('SVG.pm is a perl module on CPAN!');

        my $text = $svg->text( style => { 'font' => 'Arial', 'font-size' => 20 } );
        $text->cdata('SVG.pm is a perl module on CPAN!');

    Result:

        <text style="font: Arial; font-size: 20">SVG.pm is a perl module on CPAN!</text>

    SEE ALSO:

    "CDATA", "desc", "title", "text", "script".

  cdata_noxmlesc
     $script = $svg->script();
     $script->cdata_noxmlesc($text);

    Generates cdata content for text and similar tags which do not get xml-escaped. In othe words, does not parse the content and inserts the exact string into the cdata
    location.

  CDATA
     $script = $svg->script();
     $script->CDATA($text);

    Generates a <![CDATA[ ... ]]> tag with the contents of $text rendered exactly as supplied. SVG.pm allows you to set cdata for any tag. If the tag is meant to be an empty
    tag, SVG.pm will not complain, but the rendering agent will fail. In the SVG DTD, cdata is generally only meant for adding text or script content.

          my $text = qq{
            var SVGDoc;
            var groups = new Array();
            var last_group;

            /*****
            *
            *   init
            *
            *   Find this SVG's document element
            *   Define members of each group by id
            *
            *****/
            function init(e) {
                SVGDoc = e.getTarget().getOwnerDocument();
                append_group(1, 4, 6); // group 0
                append_group(5, 4, 3); // group 1
                append_group(2, 3);    // group 2
            }};
            $svg->script()->CDATA($text);

    Result:

        E<lt>script E<gt>
          <gt>![CDATA[
            var SVGDoc;
            var groups = new Array();
            var last_group;

            /*****
            *
            *   init
            *
            *   Find this SVG's document element
            *   Define members of each group by id
            *
            *****/
            function init(e) {
                SVGDoc = e.getTarget().getOwnerDocument();
                append_group(1, 4, 6); // group 0
                append_group(5, 4, 3); // group 1
                append_group(2, 3);    // group 2
            }
            ]]E<gt>

    SEE ALSO: "cdata", "script".

  xmlescp and xmlescape
    $string = $svg->xmlescp($string) $string = $svg->xmlesc($string) $string = $svg->xmlescape($string)

    SVG module does not xml-escape characters that are incompatible with the XML specification. xmlescp and xmlescape provides this functionality. It is a helper function
    which generates an XML-escaped string for reserved characters such as ampersand, open and close brackets, etcetera.

    The behaviour of xmlesc is to apply the following transformation to the input string $s:

        $s=~s/&(?!#(x\w\w|\d+?);)/&amp;/g;
        $s=~s/>/&gt;/g;
        $s=~s/</&lt;/g;
        $s=~s/\"/&quot;/g;
        $s=~s/\'/&apos;/g;
        $s=~s/([\x00-\x08\x0b\x1f])/''/eg;
        $s=~s/([\200-\377])/'&#'.ord($1).';'/ge;

  filter
    $tag = $svg->filter(%attributes)

    Generate a filter. Filter elements contain "fe" filter sub-elements.

        my $filter = $svg->filter(
            filterUnits=>"objectBoundingBox",
            x=>"-10%",
            y=>"-10%",
            width=>"150%",
            height=>"150%",
            filterUnits=>'objectBoundingBox'
        );

        $filter->fe();

    SEE ALSO: "fe".

  fe
    $tag = $svg->fe(-type=>'type', %attributes)

    Generate a filter sub-element. Must be a child of a "filter" element.

        my $fe = $svg->fe(
            -type     => 'DiffuseLighting'  # required - element name omitting 'fe'
            id        => 'filter_1',
            style     => {
                'font'      => [ qw(Arial Helvetica sans) ],
                'font-size' => 10,
                'fill'      => 'red',
            },
            transform => 'rotate(-45)'
        );

    Note that the following filter elements are currently supported: Also note that the elelemts are defined in lower case in the module, but as of version 2.441, any case
    combination is allowed.

  * feBlend
  * feColorMatrix
  * feComponentTransfer
  * feComposite
  * feConvolveMatrix
  * feDiffuseLighting
  * feDisplacementMap
  * feDistantLight
  * feFlood
  * feFuncA
  * feFuncB
  * feFuncG
  * feFuncR
  * feGaussianBlur
  * feImage
  * feMerge
  * feMergeNode
  * feMorphology
  * feOffset
  * fePointLight
  * feSpecularLighting
  * feSpotLight
  * feTile
  * feTurbulence
    SEE ALSO: "filter".

  pattern
    $tag = $svg->pattern(%attributes)

    Define a pattern for later reference by url.

        my $pattern = $svg->pattern(
            id     => "Argyle_1",
            width  => "50",
            height => "50",
            patternUnits        => "userSpaceOnUse",
            patternContentUnits => "userSpaceOnUse"
        );

  set
    $tag = $svg->set(%attributes)

    Set a definition for an SVG object in one section, to be referenced in other sections as needed.

        my $set = $svg->set(
            id     => "Argyle_1",
            width  => "50",
            height => "50",
            patternUnits        => "userSpaceOnUse",
            patternContentUnits => "userSpaceOnUse"
        );

  stop
    $tag = $svg->stop(%attributes)

    Define a stop boundary for "gradient"

       my $pattern = $svg->stop(
           id     => "Argyle_1",
           width  => "50",
           height => "50",
           patternUnits        => "userSpaceOnUse",
           patternContentUnits => "userSpaceOnUse"
       );

  gradient
    $tag = $svg->gradient(%attributes)

    Define a color gradient. Can be of type linear or radial

        my $gradient = $svg->gradient(
            -type => "linear",
            id    => "gradient_1"
        );

GENERIC ELEMENT METHODS
    The following elements are generically supported by SVG:

  * altGlyph
  * altGlyphDef
  * altGlyphItem
  * clipPath
  * color-profile
  * cursor
  * definition-src
  * font-face-format
  * font-face-name
  * font-face-src
  * font-face-url
  * foreignObject
  * glyph
  * glyphRef
  * hkern
  * marker
  * mask
  * metadata
  * missing-glyph
  * mpath
  * switch
  * symbol
  * tref
  * view
  * vkern
    See e.g. "pattern" for an example of the use of these methods.

METHODS IMPORTED BY SVG::DOM
    The following SVG::DOM elements are accessible through SVG:

  * getChildren
  * getFirstChild
  * getNextChild
  * getLastChild
  * getParent
  * getParentElement
  * getSiblings
  * getElementByID
  * getElementID
  * getElements
  * getElementName
  * getType
  * getAttributes
  * getAttribute
  * setAttributes
  * setAttribute
  * insertBefore
  * insertAfter
  * insertSiblingBefore
  * insertSiblingAfter
  * replaceChild
  * removeChild
  * cloneNode
Methods
    SVG provides both explicit and generic element constructor methods. Explicit generators are generally (with a few exceptions) named for the element they generate. If a
    tag method is required for a tag containing hyphens, the method name replaces the hyphen with an underscore. ie: to generate tag <column-heading id="new"> you would use
    method $svg->column_heading(id=>'new').

    All element constructors take a hash of element attributes and options; element attributes such as 'id' or 'border' are passed by name, while options for the method (such
    as the type of an element that supports multiple alternate forms) are passed preceded by a hyphen, e.g '-type'. Both types may be freely intermixed; see the "fe" method
    and code examples throughout the documentation for more examples.

  new (constructor)
    $svg = SVG->new(%attributes)

    Creates a new SVG object. Attributes of the document SVG element be passed as an optional list of key value pairs. Additionally, SVG options (prefixed with a hyphen) may
    be set on a per object basis:

        my $svg1 = SVG->new;

        my $svg2 = SVG->new(id => 'document_element');

        my $svg3 = SVG->new(
            -printerror => 1,
            -raiseerror => 0,
            -indent     => '  ',
            -elsep      => "\n",  # element line (vertical) separator
            -docroot    => 'svg', # default document root element (SVG specification assumes svg). Defaults to 'svg' if undefined
            -xml_xlink  => 'http://www.w3.org/1999/xlink', # required by Mozilla's embedded SVG engine
            -sysid      => 'abc', # optional system identifier
            -pubid      => "-//W3C//DTD SVG 1.0//EN", # public identifier default value is "-//W3C//DTD SVG 1.0//EN" if undefined
            -namespace  => 'mysvg',
            -inline     => 1
            id          => 'document_element',
            width       => 300,
            height      => 200,
        );

    Default SVG options may also be set in the import list. See "EXPORTS" above for more on the available options.

    Furthermore, the following options:

        -version
        -encoding
        -standalone
        -namespace
        -inline
        -pubid (formerly -identifier)
        -sysid (standalone)

    may also be set in xmlify, overriding any corresponding values set in the SVG->new declaration

  xmlify  (alias: to_xml render serialize serialise )
    $string = $svg->xmlify(%attributes);

    Returns xml representation of svg document.

    XML Declaration

        Name               Default Value
        -version           '1.0'
        -encoding          'UTF-8'
        -standalone        'yes'
        -namespace         'svg' - namespace prefix for elements.
                                   Can also be used in any element method to over-ride
                                   the current namespace prefix. Make sure to have
                                   declared the prefix before using it.
        -inline            '0' - If '1', then this is an inline document.
        -pubid             '-//W3C//DTD SVG 1.0//EN';
        -sysid             'http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd'

  perlify ()
    return the perl code which generates the SVG document as it currently exists.

  toperl ()
    Alias for method perlify()

AUTHOR
    Ronan Oger, RO IT Systemms GmbH, cpan@roitsystems.com

MAINTAINER
    Gabor Szabo <http://szabgab.com/>

CREDITS
    I would like to thank the following people for contributing to this module with patches, testing, suggestions, and other nice tidbits:

    Peter Wainwright, Excellent ideas, beta-testing, writing SVG::Parser and much of SVG::DOM. Fredo, http://www.penguin.at0.net/~fredo/ - provided example code and initial
    feedback for early SVG.pm versions and the idea of a simplified svg generator. Adam Schneider, Brial Pilpré, Ian Hickson Steve Lihn, Allen Day Martin Owens - SVG::DOM
    improvements in version 3.34

COPYRIGHT & LICENSE
    Copyright 2001- Ronan Oger

    The modules in the SVG distribution are distributed under the same license as Perl itself. It is provided free of warranty and may be re-used freely.

ARTICLES
    SVG using Perl <http://szabgab.com/svg-using-perl.html>

    SVG - Scalable Vector Graphics with Perl <http://perlmaven.com/scalable-vector-graphics-with-perl>

    Combining SVG and PSGI <http://perlmaven.com/combining-svg-and-psgi>

SEE ALSO
    SVG::DOM, SVG::XML, SVG::Element, SVG::Parser, SVG::Extension

    For Commercial Perl/SVG development, refer to the following sites: ROASP.com: Serverside SVG server <http://www.roitsystems.com/>, ROIT Systems: Commercial SVG perl
    solutions <http://www.roitsystems.com/>, SVG at the W3C <http://www.w3c.org/Graphics/SVG/>

