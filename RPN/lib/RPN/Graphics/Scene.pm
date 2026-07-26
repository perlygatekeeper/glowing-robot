package RPN::Graphics::Scene;

use v5.34;
use strict;
use warnings;

use Scalar::Util qw(blessed);
use RPN::Graphics::Shape;

sub new {
    my ($class, %args) = @_;
    my $width = $args{width}; my $height = $args{height};
    for ($width, $height) {
        die "scene dimensions must be positive numbers\n"
            if !defined($_) || ref($_) || $_ !~ /^\d+(?:\.\d+)?$/ || $_ <= 0;
    }
    return bless {
        width => 0 + $width, height => 0 + $height,
        background => defined $args{background} ? "$args{background}" : 'white',
        shapes => [ @{ $args{shapes} || [] } ],
    }, $class;
}

sub is_scene { blessed($_[0]) && $_[0]->isa(__PACKAGE__) }
sub width { $_[0]{width} }
sub height { $_[0]{height} }
sub background { $_[0]{background} }
sub shapes { @{ $_[0]{shapes} } }
sub shape_count { scalar @{ $_[0]{shapes} } }

sub add {
    my ($self, $shape) = @_;
    die "draw requires a graphics shape\n" unless RPN::Graphics::Shape::is_shape($shape);
    return __PACKAGE__->new(
        width => $self->width, height => $self->height,
        background => $self->background, shapes => [ $self->shapes, $shape ],
    );
}

sub as_string {
    sprintf 'scene(%sx%s,%s shape%s)', $_[0]->width, $_[0]->height,
        $_[0]->shape_count, $_[0]->shape_count == 1 ? '' : 's';
}

1;
