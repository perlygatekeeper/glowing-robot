#!/usr/bin/perl
use strict;
use warnings;
use Gtk2 '-init';
use Goo::Canvas;
use Glib qw(TRUE FALSE);

my $mw = Gtk2::Window->new('toplevel');
$mw->set_default_size( 400, 300 );
$mw->signal_connect (destroy => sub { Gtk2->main_quit });

my $vbox = Gtk2::VBox->new(0,0);
$mw->add ($vbox);

my $swin = Gtk2::ScrolledWindow->new;
$swin->set_shadow_type('in');
my $ha1  = $swin->get_hadjustment;
my $va1  = $swin->get_vadjustment;

my $canvas = Goo::Canvas->new();
my ($cw,$ch) = (600, 450);
$canvas->set_size_request($cw, $ch);
my($xbound,$ybound) = (1000,1000);
$canvas->set_bounds(0, 0, $xbound, $ybound);

my ($cx,$cy) = ($xbound/2,$ybound/2);
my $root = $canvas->get_root_item(); #root group

# make a group for the hexagon tiles
my $group = Goo::Canvas::Group->new($root);
my $g_cx = $cw/2;
my $g_cy = $ch/2;

my $white = Gtk2::Gdk::Color->new (0xFFFF,0xFFFF,0xFFFF);
my $green = Gtk2::Gdk::Color->new (0x0000,0xFFFF,0x0000);
my $black = Gtk2::Gdk::Color->new (0x0000,0x0000,0x0000);

$canvas->modify_base('normal',$white);

$vbox->pack_start ($swin, 1,1,1);
$swin->add($canvas);

# Zoom
my $hbox = Gtk2::HBox->new(0, 4);
$vbox->pack_start($hbox, 0, 0, 0);
$hbox->show;

my $z = Gtk2::Label->new("Zoom:");
$hbox->pack_start($z, 0, 0, 0);
$z->show;

my $zadj = Gtk2::Adjustment->new(1, 0.05, 100, 0.05, 0.5, 0.0);
my $zsb = Gtk2::SpinButton->new($zadj, 0.1, 2);

$zadj->signal_connect("value-changed", \&zoom_changed, $canvas);

$zsb->set_editable(0);
$hbox->pack_start($zsb, 1, 1, 10);
$zsb->show;

# Rotate
my $r = Gtk2::Label->new("Rotate:");
$hbox->pack_start($r, 0, 0, 0);
$r->show;

my $vboxb = Gtk2::VBox->new(0,0);
$hbox->pack_start($vboxb, 0, 0, 0);
$vboxb->show;

my $btn_rota = Gtk2::Button->new_from_stock('+');
my $btn_rotb = Gtk2::Button->new_from_stock('-');
$btn_rota->signal_connect("clicked", \&rotate, 1 );
$btn_rotb->signal_connect("clicked", \&rotate, -1 );


$vboxb->pack_start($btn_rota, 0, 0, 0);
$vboxb->pack_start($btn_rotb, 0, 0, 0);
$btn_rota->show;
$btn_rotb->show;

# Create PDF                                                          
+                
my $bpdf = Gtk2::Button->new_with_label('Write PDF');                 
+                      
$hbox->pack_start($bpdf, FALSE, FALSE, 0);                            
+                   
$bpdf->show;                                                          
+                   
$bpdf->signal_connect("clicked", \&write_pdf_clicked, $canvas);       
+  

# fixes runaway zoom and gives smoother zoom control
$canvas->signal_connect (event => \&event_handler);

$canvas->can_focus(1);
$canvas->grab_focus($root);

&fill_canvas();

$group->raise(); # raise the hexgrid group above $root group
                 # ie to put sample text below hexgrid

$mw->show_all;

Gtk2->main;
exit 0;


sub zoom_changed {
    my ($adj, $canvas) = @_;

    $canvas->set_scale($adj->get_value);
#    $canvas->scroll_to (0,0); # adjust scroll here after zoom if desi
+red   

return 0;
}


sub rotate {
    my ($button, $rotate) = @_;
   # print "rotate $rotate\n";
    $group->rotate ($rotate, $g_cx, $g_cy); 

return 0;
}



sub fill_canvas{


my $text = Goo::Canvas::Text->new(
    $root, "Perl", 340, 170, -1, 'center',
    'font' => 'Sans 64',
    "fill-color" => "black",
);

# set number of cells in x and y direction
my ( $num_cells_x , $num_cells_y) = (50,50);

# set rectangular cell and width and compute height
my $cwidth = 40; 
my $cheight = sqrt(3) * $cwidth;

# compute canvas size required
my ($canvasWidth, $canvasHeight) = ($num_cells_x *  $cwidth,
                        $num_cells_y *  $cheight);

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
    if ($row % 2){ $color = 0xffb37180;
       $shift = $s ;
     }
    
    else{ $color = 0x3cb37180}
    
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
    
     # account for $shift affecting x position
     # xpos != x
     my $xpos = $x0 + $r;
     

my $pts_ref = [$x0,$y0,$x1,$y1,$x2,$y2,$x3,$y3,$x4,$y4,$x5,$y5,$x6,$y6
+]; 

my $line = Goo::Canvas::Polyline->new(
         $group, TRUE,
         $pts_ref, 
         'stroke-color' => 'black',
        'line-width' => 1,
         'fill-color-rgba' => $color,
    );

          $col++;
    }
$row++;
$col = 0; # reset column
}


}

sub write_pdf_clicked {
    my ($but, $canvas) = @_;
    print "Write PDF...\n";

    my $scale = $zadj->get_value;
    print "scale->$scale\n"; 
    
    my $surface = Cairo::PdfSurface->create("$0-$scale.pdf", 
                    $scale*$cw, $scale*$ch);
    
    my $cr = Cairo::Context->create($surface);

    # needed to save scaled version
    $cr->scale($scale, $scale);

    $canvas->render($cr, undef, 1);
    $cr->show_page;
    print "done\n";
    return TRUE;
}


sub event_handler{
     my ( $widget, $event ) = @_;
#     print $widget ,' ',$event->type,"\n";

     my $scale = $zadj->get_value;
     # print "scale->$scale\n"; 

    if ( $event->type eq "button-press" ) {
    
        my ($x,$y) = ($event->x,$event->y);
        print "$x  $y\n";
        
     }

    if ( $event->type eq "button-release" ) {
    
    }


    if ( $event->type eq "focus-change" ) {
        return 0;
    }
    
    if ( $event->type eq "expose" ) {
        return 0;
    }

Gtk2->main_iteration while Gtk2->events_pending;      
return 1;

}

__END__
