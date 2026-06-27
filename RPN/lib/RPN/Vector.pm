package RPN::Vector;

use v5.34;
use strict;
use warnings;

use Scalar::Util qw(blessed);

sub new {
    my ($class, @values) = @_;

    my $self = bless {
        values => [ @values ],
    }, $class;

    return $self;
}

sub is_vector {
    my ($thing) = @_;

    return blessed($thing) && $thing->isa(__PACKAGE__);
}

sub values {
    my ($self) = @_;

    return @{ $self->{values} };
}

sub dim {
    my ($self) = @_;

    return scalar @{ $self->{values} };
}

sub get {
    my ($self, $index) = @_;

    return $self->{values}[$index];
}

sub as_string {
    my ($self) = @_;

    return '[' . join(',', @{ $self->{values} }) . ']';
}

sub clone {
    my ($self) = @_;

    return RPN::Vector->new($self->values);
}

sub same_dim {
    my ($self, $other) = @_;

    return 0 unless is_vector($other);

    return $self->dim == $other->dim;
}

sub add {
    my ($self, $other) = @_;

    die "vector add requires vectors of the same dimension\n"
        unless $self->same_dim($other);

    my @a = $self->values;
    my @b = $other->values;

    my @result;

    for my $i (0 .. $#a) {
        push @result, $a[$i] + $b[$i];
    }

    return RPN::Vector->new(@result);
}

sub subtract {
    my ($self, $other) = @_;

    die "vector subtract requires vectors of the same dimension\n"
        unless $self->same_dim($other);

    my @a = $self->values;
    my @b = $other->values;

    my @result;

    for my $i (0 .. $#a) {
        push @result, $a[$i] - $b[$i];
    }

    return RPN::Vector->new(@result);
}

sub scale {
    my ($self, $scalar) = @_;

    my @result = map { $_ * $scalar } $self->values;

    return RPN::Vector->new(@result);
}

sub dot {
    my ($self, $other) = @_;

    die "dot product requires vectors of the same dimension\n"
        unless $self->same_dim($other);

    my @a = $self->values;
    my @b = $other->values;

    my $sum = 0;

    for my $i (0 .. $#a) {
        $sum += $a[$i] * $b[$i];
    }

    return $sum;
}

sub cross {
    my ($self, $other) = @_;

    die "cross product requires two 3D vectors\n"
        unless is_vector($other) && $self->dim == 3 && $other->dim == 3;

    my ($a1, $a2, $a3) = $self->values;
    my ($b1, $b2, $b3) = $other->values;

    return RPN::Vector->new(
        $a2 * $b3 - $a3 * $b2,
        $a3 * $b1 - $a1 * $b3,
        $a1 * $b2 - $a2 * $b1,
    );
}

sub magnitude {
    my ($self) = @_;

    my $sum = 0;

    foreach my $value ($self->values) {
        $sum += $value * $value;
    }

    return sqrt($sum);
}

sub normalize {
    my ($self) = @_;

    my $mag = $self->magnitude;

    die "cannot normalize zero vector\n"
        if $mag == 0;

    return $self->scale(1 / $mag);
}

1;
