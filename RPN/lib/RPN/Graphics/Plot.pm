package RPN::Graphics::Plot;

use v5.34;
use strict;
use warnings;

use RPN::Graphics::Scene;
use RPN::Graphics::Shape;

sub scene {
    my ($class, %args) = @_;
    my ($xs, $ys) = @args{qw(x y)};
    die "plot requires equally sized x and y arrays\n"
        unless ref($xs) eq 'ARRAY' && ref($ys) eq 'ARRAY' && @$xs == @$ys && @$xs >= 2;
    my ($width, $height) = ($args{width} // 640, $args{height} // 480);
    my $padding = $args{padding} // 40;
    my ($xmin, $xmax) = _range($xs); my ($ymin, $ymax) = _range($ys);
    ($xmin, $xmax) = _expand($xmin, $xmax); ($ymin, $ymax) = _expand($ymin, $ymax);
    my @points;
    for my $i (0 .. $#$xs) {
        push @points, [
            $padding + ($xs->[$i] - $xmin) / ($xmax - $xmin) * ($width - 2 * $padding),
            $height - $padding - ($ys->[$i] - $ymin) / ($ymax - $ymin) * ($height - 2 * $padding),
        ];
    }
    my $scene = RPN::Graphics::Scene->new(width => $width, height => $height);
    if ($xmin <= 0 && $xmax >= 0) {
        my $x0 = $padding + (0 - $xmin) / ($xmax - $xmin) * ($width - 2 * $padding);
        $scene = $scene->add(RPN::Graphics::Shape->new(
            type => 'line', data => [$x0, $padding, $x0, $height - $padding],
            style => { stroke => '#999', 'stroke-width' => 1 },
        ));
    }
    if ($ymin <= 0 && $ymax >= 0) {
        my $y0 = $height - $padding - (0 - $ymin) / ($ymax - $ymin) * ($height - 2 * $padding);
        $scene = $scene->add(RPN::Graphics::Shape->new(
            type => 'line', data => [$padding, $y0, $width - $padding, $y0],
            style => { stroke => '#999', 'stroke-width' => 1 },
        ));
    }
    return $scene->add(RPN::Graphics::Shape->new(
        type => 'polyline', data => \@points,
        style => { fill => 'none', stroke => ($args{stroke} // '#06c'), 'stroke-width' => 2 },
    ));
}

sub _range {
    my ($values) = @_;
    my ($min, $max) = ($values->[0], $values->[0]);
    for (@$values) { $min = $_ if $_ < $min; $max = $_ if $_ > $max }
    return ($min, $max);
}

sub _expand {
    my ($min, $max) = @_;
    return ($min - 1, $max + 1) if $min == $max;
    return ($min, $max);
}

1;
