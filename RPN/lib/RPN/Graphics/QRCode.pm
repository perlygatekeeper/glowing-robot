package RPN::Graphics::QRCode;

use v5.34;
use strict;
use warnings;

use RPN::Graphics::Shape;

sub available { eval { require Text::QRCode; 1 } ? 1 : 0 }

sub encode {
    my ($class, $text, %args) = @_;
    die "QR code text must be a string\n" if !defined($text) || ref($text);
    die "QR code generation requires the optional Text::QRCode module\n"
        unless $class->available;
    my $qr = Text::QRCode->new;
    my $raw = $qr->plot($text);
    my @matrix = map {
        [ map { defined($_) && ($_ eq '*' || $_ eq '1') ? 1 : 0 } @$_ ]
    } @$raw;
    my $quiet = 4;
    my $width = @matrix + 2 * $quiet;
    my @bordered = map { [(0) x $width] } 1 .. $quiet;
    push @bordered, map { [(0) x $quiet, @$_, (0) x $quiet] } @matrix;
    push @bordered, map { [(0) x $width] } 1 .. $quiet;
    return $class->from_matrix(\@bordered, %args);
}

sub from_matrix {
    my ($class, $matrix, %args) = @_;
    die "QR code matrix must be a nonempty square array\n"
        unless ref($matrix) eq 'ARRAY' && @$matrix
            && !grep { ref($_) ne 'ARRAY' || @$_ != @$matrix } @$matrix;
    my @copy = map { [ map { $_ ? 1 : 0 } @$_ ] } @$matrix;
    return RPN::Graphics::Shape->new(
        type => 'qrcode',
        data => [ \@copy, $args{x} // 0, $args{y} // 0, $args{size} // 256 ],
    );
}

1;
