package RPN::Graphics::Point;

use v5.34;
use strict;
use warnings;

use Scalar::Util qw(blessed);
use RPN::Vector;

sub new {
    my ($class, $x, $y) = @_;
    _number($x); _number($y);
    return bless { x => 0 + $x, y => 0 + $y }, $class;
}

sub is_point { blessed($_[0]) && $_[0]->isa(__PACKAGE__) }
sub x { $_[0]{x} }
sub y { $_[0]{y} }
sub vector { RPN::Vector->new($_[0]->x, $_[0]->y) }
sub as_string { sprintf 'point(%s,%s)', $_[0]->x, $_[0]->y }

sub transform {
    my ($self, $transform) = @_;
    my $point = $transform->apply($self->vector);
    return __PACKAGE__->new($point->values);
}

sub _number {
    die "graphics coordinates must be numbers\n"
        if !defined($_[0]) || ref($_[0])
            || $_[0] !~ /^[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?$/;
}

1;
