#!/usr/bin/env perl
# A perl script to output svg for spectroscope equivalent to
# the one from: URL
use strict;
use warnings;
use Math::Trig qw(asin_real :pi);
use SVG;

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name";

my $params = set_parameters();  
# print ref($params) . "\n";

my $svg = SVG->new(
         width      => $params->{doc_width},
         height     => $params->{doc_height},
        -indent     => "\t",
        -elsep      => "\n",
        -nocredits  => 1,
          );
# path_doc_window(   $params, $svg );
  path_outside_cut(  $params, $svg );
  path_viewer_cut(   $params, $svg );
  path_slit_cut(     $params, $svg );
  paths_for_scoring( $params, $svg );

# or, explicitly use svg namespace and generate a document with its own DTD
print $svg->xmlify() . "\n";

exit 0;

# -------------------------------------------------------------------------

sub path_doc_window {
  my ( $params, $svg ) = @_;
  my $x = 10;
  my $y = 10;
  my $save_stroke = $params->{style}{stroke};
  $params->{style}{stroke} = 'rgb(100,0,100)';
  my $rect = $svg->rectangle(
            id     => 'doc_window',
            x      => $x,
            y      => $y,
            width  => $params->{doc_width}  - 2 * $x,
            height => $params->{doc_height} - 2 * $y,
            rx     => 0.5,
            ry     => 0.5,
            style  => $params->{style},
        );
  $params->{style}{stroke} = $save_stroke;
}

sub path_outside_cut {
  my ( $params, $svg ) = @_;
# my $path_string = "m 100 280  80 0  0 -200  -160 0  0 200 z";
# my $points = $svg->get_path(
# 	 x         => [100, 80,    0, -160,   0],
# 	 y         => [280,  5, -200,    0, 200],
# 	 -type     => 'path',
# 	 -relative => 1,
# 	 -closed   => 1,
# );
#           %$points, # from get_apath call
# print STDERR ref $points; 
# print STDERR join(", ", keys %$points)   . "\n"; 
# print STDERR join(", ", values %$points) . "\n"; 
# print STDERR "\n\n\n";
  my $path_string = construct_outside_path($params);
  my $path = $svg->path(
            d      => $path_string,
            style  => $params->{style},
  );
}

sub construct_outside_path {
  # constructing outside path for spectroscope
  # absolute points will be used
  my ( $params, ) = @_;
  my $up_path;  # array of points up right-hand side
  my $ret_path; # array of points down left-hand side
  # each point will be pushed onto end of points array
  # it's mirror will be unshifted onto return array
  # two arrays will be merged and a path string constructed
  # scoring/folding points will be stored in params in the array ref
  # keyed by string "folds"
  my $x = $params->{doc_width} / 2 + $params->{width} / 2 - $params->{epsilon};
  my $y = $params->{doc_height} - $params->{tab_width} / 2;
  $params->{first_cut_point} = [ $x, $y ];

# right slit of bottom, center tab
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );

  $x += $params->{epsilon};
  $y -= $params->{tab_width};
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );
  $params->{vertical_fold}[1] = [ $x, $y ];
  $params->{vertical_fold}[2] = [ ( $params->{doc_width} - $x ), $y ];

# bottom, right tab
  $x += $params->{epsilon};
  $y += $params->{tab_width};
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );

  $x += ( $params->{back_height} - $params->{epsilon} );
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );

  $y -= $params->{tab_width};
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );
  push( @{ $params->{folds} }, [ [ $x, $y ], [ ( $params->{doc_width} - $x ), $y ] ] ); # fold 1 is right to left

  # trace upper portion of right side of spectroscope

  $x += $params->{viewer_tube_height} * cos($params->{gamma});
  $y -= $params->{viewer_tube_height} * sin($params->{gamma});
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );

  $x -= $params->{viewer_tube_length} * sin($params->{gamma});
  $y -= $params->{viewer_tube_length} * cos($params->{gamma});
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );

  $y -= $params->{front_length};
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );

  $x -= $params->{front_height};
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );
  push( @{ $params->{folds} }, [ [ ( $params->{doc_width} - $x ), $y ], [ $x, $y ] ] ); # fold 2 is left  to right

  # position slit
  $params->{slit_x} = $x - ( $params->{slit_width} / 2 ) - ( $params->{width} / 2 );
  $params->{slit_y} = $y - $params->{viewer_tube_height} * 0.8;

  # first tab up right-hand side
  $x += $params->{tab_width};
  $y -= $params->{epsilon};
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );

  $y -= ( $params->{front_height} - $params->{epsilon} * 2 );
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );

  $x -= $params->{tab_width};
  $y -= $params->{epsilon};
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );
  push( @{ $params->{folds} }, [ [ $x, $y ], [ ( $params->{doc_width} - $x ), $y ] ] ); # fold 3 is right to left


  # second tab up right-hand side
  $x += $params->{tab_width};
  $y -= $params->{epsilon};
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );

  $y -= ( $params->{front_length} - $params->{epsilon} * 2 );
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );

  $x -= $params->{tab_width};
  $y -= $params->{epsilon};
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );
  push( @{ $params->{folds} }, [ [ ( $params->{doc_width} - $x ), $y ], [ $x, $y ] ] ); # fold 4 is left  to right


  # third tab up right-hand side
  $x += $params->{tab_width};
  $y -= $params->{epsilon};
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );

  $y -= ( $params->{viewer_tube_length} - $params->{epsilon} * 2 );
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );

  $x -= $params->{tab_width};
  $y -= $params->{epsilon};
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );
  push( @{ $params->{folds} }, [ [ $x, $y ], [ ( $params->{doc_width} - $x ), $y ] ] ); # fold 5 is right to left


  # forth and final tab up right-hand side
  $x += $params->{tab_width};
  $y -= $params->{epsilon};
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );

  $y -= ( $params->{viewer_tube_height} - $params->{epsilon} );
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );

  $x -= $params->{tab_width};
  $y -= $params->{epsilon};
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );
  push( @{ $params->{folds} }, [ [ ( $params->{doc_width} - $x ), $y ], [ $x, $y ] ] ); # fold 6 is left  to right
  $params->{vertical_fold}[0] = [ $x, $y ];
  $params->{vertical_fold}[3] = [ ( $params->{doc_width} - $x ), $y ];

  # position viewer
  $params->{viewer_x} = $x - ( $params->{viewer_width} / 2 ) - ( $params->{width} / 2 );
  $params->{viewer_y} = $y + ( $params->{viewer_tube_height} - $params->{viewer_height} ) / 2;

  # last segement of right-hand side
  $y -= $params->{back_height};
  push(    @$up_path,  [ $x, $y ] );
  unshift( @$ret_path, [ ( $params->{doc_width} - $x ), $y ] );
  
  # -------------------------------------------------------------------
  # now construct and return the path "d" string
  # -------------------------------------------------------------------
  my $d_string = 'M ';
  my $i = 0;
  foreach my $point ( @$up_path ) {
    $d_string .= sprintf( "  %f, %f ", @$point);
    $d_string .= "\n" if ( not ( ++$i % 4 ) );
  }
  $d_string .= "\n";
  foreach my $point ( @$ret_path ) {
    $d_string .= sprintf( "  %f, %f ", @$point);
    $d_string .= "\n" if ( not ( ++$i % 4 ) );
  }
  $d_string .= qq(Z\n);
}

sub path_viewer_cut {
  my ( $params, $svg ) = @_;
  my $rect = $svg->rectangle(
            id     => 'viewer',
            x      => $params->{viewer_x},
            y      => $params->{viewer_y},
            width  => $params->{viewer_width},
            height => $params->{viewer_height},
            rx     => 0.5,
            ry     => 0.5,
            style  => $params->{style},
        );
}

 sub path_slit_cut {
  my ( $params, $svg ) = @_;
  my $rect = $svg->rectangle(
            id     => 'slit',
            x      => $params->{slit_x},
            y      => $params->{slit_y},
            width  => $params->{slit_width},
            height => $params->{slit_height},
            rx     => 0.2,
            ry     => 0.2,
            style  => $params->{style},
        );
}

sub paths_for_scoring {
  my ( $params, $svg ) = @_;
  my $path;
  foreach my $line ( @{ $params->{folds} } ) {
    $path = $svg->path(
            d      => sprintf("M %f %f %f %f", @{ $line->[0] }, @{ $line->[1] } ),
            style  => $params->{style},
    );
  }
  foreach my $index ( 0 .. 2 ) {
#   print STDERR $index . "\n";
    $path = $svg->path(
            d      => sprintf("M %f %f %f %f", @{ $params->{vertical_fold}[$index] }, @{ $params->{vertical_fold}[$index+1] } ),
            style  => $params->{style},
    );
  }
}

sub set_parameters {
  my $params;

  $params->{doc_width}          =  950;
  $params->{doc_height}         = 1500;

  $params->{tab_width}          =   48.0; 
  $params->{epsilon}            =    2.0; # intertab distance

  $params->{width}              =  237.5; # overall width
  $params->{front_length}       =  200.0; # front   length
  $params->{length}             =  467.5; # overall length 

  $params->{front_height}       =  147.5; # height of slit end
  $params->{back_height}        =  237.5; # height of viewer end

  $params->{viewer_width}       =  127.0;
  $params->{viewer_height}      =   63.5;
  $params->{viewer_x}           =  350.0;
  $params->{viewer_y}           =  500.0;

  $params->{slit_width}         =  170.0;
  $params->{slit_height}        =    2.0;
  $params->{slit_x}             =  350.0;
  $params->{slit_y}             = 1000.0;

  $params->{viewer_tube_length} =  237.5; # view portal length
  $params->{viewer_tube_height} =  125.0; # view portal height

  $params->{alpha}  = asin_real( $params->{viewer_tube_height} / $params->{viewer_tube_length} );
  $params->{beta}   = asin_real( ( $params->{back_height} - $params->{front_height} ) / ( $params->{length} - $params->{front_length} ) );
  $params->{gamma}  = ( $params->{alpha} - $params->{beta} );
  $params->{gamma}  = pi/3.8;
  $params->{theta}  = pi - $params->{gamma} ; # viewer angle 
  $params->{style}  = { 'fill'            => 'none',
                        'fill-rule'       => 'evenodd',
                        'stroke'          => 'rgb(100,200,50)',
                        'stroke-width'    => '1px',
                        'stroke-linecap'  => 'butt',
                        'stroke-linejoin' => 'miter',
                        'stroke-opacity'  => '1'
                      };
  return $params;
}

__END__

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
   width="200mm"
   height="300mm"
   id="svg2"
   version="1.1"
   inkscape:version="0.91 r13725"
   sodipodi:docname="spectroscope_cut_n_fold.svg">
  <defs
     id="defs4" />
  <metadata
     id="metadata7">
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
     inkscape:groupmode="layer"
     id="layer2"
     inkscape:label="Cutting"
     style="display:inline">
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="m 299,205 0,45 90,0 0,-45 z"
       id="path4204"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="ccccc" />
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="m 283.84689,601.71275 0,1.44036 120.30622,0 0,-1.44036 z"
       id="path4205"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cccccccccccccccccccc" />
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="
          m
          260,12
          0,169
          -37,0
          0,85
          37,2.5
          -37,2.5
          0,160
          37,2.5
          -37,2.5
          0,135
          37,2.5
          -37,2.5
          0,100
          37,2.5
          -105.96184,0
          0,140
          
          L
          30,941.5
          
          l
          59.916738,69
          0,31
          168.083262,0
          1.62778,-31.1167
          
          L
          260,1041.5
          
          l
          166,0
          1.87593,-30.8685
          L
          428,1041.5
          l
          165,0
          0,-31
          57,-69
          -118,-123
          0,-140
          -104,0
          37,-2.5
          0,-100
          -37,-2.5
          37,-2.5
          0,-135
          -37,-2.5
          37,-2.5
          0,-160
          -37,-2.5
          37,-2.5
          0,-85
          -37,0
          0,-169
          z
          "

       id="path4206"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="ccccccccccccccccccccccccccccccccccccccccccccc" />
  </g>
  <g
     inkscape:groupmode="layer"
     id="layer1"
     inkscape:label="Text"
     style="display:none" />
  <g
     inkscape:groupmode="layer"
     id="layer3"
     inkscape:label="Folding">
    <rect
       style="fill:#ffffff;fill-opacity:0;fill-rule:evenodd;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       id="rect4895"
       width="168.22095"
       height="829.375"
       x="259.69037"
       y="180.91417" />
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="m 595.09455,1010.3633 -506.201348,0.062"
       id="path4897"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="m 259.64583,268.54577 168.28494,-0.0603"
       id="path4899"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="m 259.62368,433.50095 168.24218,-0.0206"
       id="path4901"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="m 259.62061,573.54143 168.272,-0.0618"
       id="path4903"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cc" />
    <path
       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
       d="m 259.62522,678.50687 168.20094,-0.0428"
       id="path4905"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cc" />
  </g>
</svg>



