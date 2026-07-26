package RPN::Graphics::Shape;

use v5.34;
use strict;
use warnings;

use Scalar::Util qw(blessed);
use RPN::Transform;

my %VALID = map { $_ => 1 } qw(line rectangle circle polygon polyline qrcode);

sub new {
    my ($class, %args) = @_;
    my $type = $args{type} // '';
    die "unknown graphics shape '$type'\n" unless $VALID{$type};
    die "graphics shape data must be an array\n" unless ref($args{data}) eq 'ARRAY';
    _validate_data($type, $args{data});
    return bless {
        type      => $type,
        data      => _copy($args{data}),
        style     => { %{ $args{style} || {} } },
        transform => $args{transform},
    }, $class;
}

sub is_shape { blessed($_[0]) && $_[0]->isa(__PACKAGE__) }
sub type { $_[0]{type} }
sub data { _copy($_[0]{data}) }
sub style { +{ %{ $_[0]{style} } } }
sub transform { $_[0]{transform} }

sub with_style {
    my ($self, %style) = @_;
    return __PACKAGE__->new(
        type => $self->type, data => $self->data,
        style => { %{ $self->{style} }, %style }, transform => $self->transform,
    );
}

sub transformed {
    my ($self, $transform) = @_;
    die "transformshape requires a 2D transform\n"
        unless RPN::Transform::is_transform($transform) && $transform->dimension == 2;
    my $combined = $self->transform ? $self->transform->then($transform) : $transform;
    return __PACKAGE__->new(
        type => $self->type, data => $self->data,
        style => $self->style, transform => $combined,
    );
}

sub as_string { sprintf 'shape(%s)', $_[0]->type }

sub _copy {
    my ($value) = @_;
    return [ map { ref($_) eq 'ARRAY' ? [@$_] : $_ } @$value ];
}

sub _validate_data {
    my ($type, $data) = @_;
    if ($type eq 'line' || $type eq 'rectangle' || $type eq 'circle') {
        my %count = (line => 4, rectangle => 4, circle => 3);
        die "$type requires $count{$type} numeric values\n"
            unless @$data == $count{$type} && !grep { !_number($_) } @$data;
        die "rectangle dimensions must not be negative\n"
            if $type eq 'rectangle' && ($data->[2] < 0 || $data->[3] < 0);
        die "circle radius must be positive\n"
            if $type eq 'circle' && $data->[2] <= 0;
    }
    if ($type eq 'polygon' || $type eq 'polyline') {
        die "$type requires an array of 2D numeric points\n"
            unless @$data >= ($type eq 'polygon' ? 3 : 2)
                && !grep { ref($_) ne 'ARRAY' || @$_ != 2 || grep { !_number($_) } @$_ } @$data;
    }
    return;
}

sub _number {
    defined($_[0]) && !ref($_[0])
        && $_[0] =~ /^[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?$/;
}

1;
