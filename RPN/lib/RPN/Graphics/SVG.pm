package RPN::Graphics::SVG;

use v5.34;
use strict;
use warnings;

use RPN::Graphics::Scene;

sub render {
    my ($class, $scene) = @_;
    die "SVG rendering requires a graphics scene\n"
        unless RPN::Graphics::Scene::is_scene($scene);
    my ($w, $h) = ($scene->width, $scene->height);
    my @out = (
        qq{<?xml version="1.0" encoding="UTF-8"?>},
        qq{<svg xmlns="http://www.w3.org/2000/svg" width="$w" height="$h" viewBox="0 0 $w $h">},
        qq{  <rect width="100%" height="100%" fill="} . _escape($scene->background) . qq{"/>},
    );
    push @out, _shape($_) for $scene->shapes;
    push @out, '</svg>';
    return join("\n", @out) . "\n";
}

sub save {
    my ($class, $scene, $file) = @_;
    die "SVG output requires a filename\n" if !defined($file) || ref($file) || $file eq '';
    open my $fh, '>', $file or die "cannot write SVG file '$file': $!\n";
    print {$fh} $class->render($scene);
    close $fh or die "cannot close SVG file '$file': $!\n";
    return 1;
}

sub _shape {
    my ($shape) = @_;
    my $type = $shape->type; my $d = $shape->data; my $s = $shape->style;
    my %defaults = (fill => 'none', stroke => 'black', 'stroke-width' => 1);
    %defaults = (%defaults, %$s);
    my $attrs = join ' ', map { sprintf '%s="%s"', $_, _escape($defaults{$_}) }
        sort keys %defaults;
    my $transform = _transform($shape->transform);

    return qq{  <line x1="$d->[0]" y1="$d->[1]" x2="$d->[2]" y2="$d->[3]" $attrs$transform/>}
        if $type eq 'line';
    return qq{  <rect x="$d->[0]" y="$d->[1]" width="$d->[2]" height="$d->[3]" $attrs$transform/>}
        if $type eq 'rectangle';
    return qq{  <circle cx="$d->[0]" cy="$d->[1]" r="$d->[2]" $attrs$transform/>}
        if $type eq 'circle';
    if ($type eq 'polygon' || $type eq 'polyline') {
        my $points = join ' ', map { join ',', @$_ } @$d;
        return qq{  <$type points="$points" $attrs$transform/>};
    }
    if ($type eq 'qrcode') {
        my ($matrix, $x, $y, $size) = @$d;
        my $n = @$matrix; my $cell = $size / $n;
        my @rects;
        for my $row (0 .. $n - 1) {
            for my $col (0 .. $n - 1) {
                next unless $matrix->[$row][$col];
                push @rects, sprintf '<rect x="%s" y="%s" width="%s" height="%s"/>',
                    $x + $col * $cell, $y + $row * $cell, $cell, $cell;
            }
        }
        return qq{  <g fill="black" stroke="none" shape-rendering="crispEdges"$transform>}
            . join('', @rects) . '</g>';
    }
    die "cannot render graphics shape '$type'\n";
}

sub _transform {
    my ($transform) = @_;
    return '' unless $transform;
    my $m = [ $transform->matrix->data ];
    return sprintf ' transform="matrix(%s %s %s %s %s %s)"',
        $m->[0][0], $m->[1][0], $m->[0][1], $m->[1][1], $m->[0][2], $m->[1][2];
}

sub _escape {
    my ($text) = @_;
    $text =~ s/&/&amp;/g; $text =~ s/</&lt;/g; $text =~ s/>/&gt;/g;
    $text =~ s/"/&quot;/g; $text =~ s/'/&apos;/g;
    return $text;
}

1;
