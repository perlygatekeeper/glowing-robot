#!/usr/bin/perl
use warnings;
use strict;
use Tk;

# simplest hex example where the cell height = sqrt(3) cell width  
# and all cells vertically oriented like a honeycomb

# W = 2 * r
# s = 1.5 * r
# H = 2 * r * sin(60 degrees) = sqrt(3) * r

# therefore
# r = W/2 and we can compute our polygon's points

# set number of cells in x and y direction
my ( $num_cells_x , $num_cells_y) = (50,50);

# set rectangular cell and width and compute height
my $cwidth = 40; 
my $cheight = sqrt(3) * $cwidth;

# compute canvas size required
my ($canvasWidth, $canvasHeight) = ($num_cells_x *  $cwidth,
                        $num_cells_y *  $cheight);

my $mw = MainWindow->new();
$mw->geometry('500x500+300+300');

my $sc = $mw->Scrolled('Canvas', -bg => 'black',
                       -width => $canvasWidth,
                       -height => $canvasHeight,
                       -scrollbars => 'osoe',
                       -scrollregion => [ 0, 0, $canvasWidth, $canvasHeight ],
              )->pack;

my $canvas =$sc->Subwidget("canvas");

my ($x, $y, $r , $s , $h, $w, $diff, $row, $col );
$r = $cwidth/2;
$w = $cwidth;
$h = sqrt(3) * $r;
$s = 1.5 * $r;
$diff = $w - $s;
$row = 0;
$col = 0;

# $x and $y are center of mass locations 
for ($y = 0; $y < $canvasHeight; $y+= $h/2){
    
   for ($x = 0; $x < $canvasWidth; $x+= (2*$r + $s - $diff) ){
    
    my $shift = 0;
    my $color; # toggles row colors and spacings
    if ($row % 2){ $color = '#FFAAAA';
       $shift = $s ;
     }
    
    else{ $color = '#AAAAFF'}
    
    #print "$color\n";
    
    my $x0 = $x - $r - $shift;    
    my $y0 = $y;
    my $x1 = $x0 + $diff;
    my $y1 = $y0 - $h/2;
    my $x2 = $x0 + $s; 
    my $y2 = $y0 - $h/2;
    my $x3 = $x0 + 2*$r;
    my $y3 = $y;
    my $x4 = $x0 + $s;
    my $y4 = $y0 + $h/2;
    my $x5 = $x1;
    my $y5 = $y0 + $h/2;
    my $x6 = $x0; # close up to starting point
    my $y6 = $y0;

   # small offset bug fix    
   # account for $shift affecting x position
   # xpos != x
   my $xpos = $x0 + $r;

      my $hexcell = $canvas->createPolygon ($x0, $y0, $x1, $y1, $x2, $y2, $x3, $y3, $x4, $y4, $x5, $y5, $x6, $y6,
                             -fill => $color,
                             -activefill => '#CCFFCC',
                             -tags =>['hexcell',"row.$row","col.$col", "posx.$xpos", "posy.$y" ],
                             -width => 1,
                             -outline => 'black',
                    );
      $col++;
    }
    $row++;
    $col = 0; # reset column
}

$sc->bind('hexcell', '<Enter>', \&enter );

$sc->bind("hexcell", "<Leave>", \&leave );

$sc->bind("hexcell", "<1>", \&left_click );

MainLoop;

sub left_click {
  my ($canv) = @_;
  my $id = $canv->find('withtag', 'current');
  my @tags = $canv->gettags($id);
  print "@tags\n";
  $canv->itemconfigure($id, -fill=>'#44FF44');
}


sub enter {
  my ($canv) = @_;
  my $id = $canv->find('withtag', 'current');
  my @tags = $canv->gettags($id);
  print "@tags\n";
}

sub leave{
  my ($canv) = @_;
  print "leave\n";
}

1;

__END__
