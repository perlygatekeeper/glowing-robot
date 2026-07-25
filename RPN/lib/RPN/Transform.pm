package RPN::Transform;

use v5.34;
use strict;
use warnings;

use Scalar::Util qw(blessed);
use RPN::Matrix;
use RPN::Vector;

sub new {
    my ($class, %args) = @_;

    my $dimension = $args{dimension};
    my $matrix    = $args{matrix};

    die "transform dimension must be 2 or 3\n"
        unless defined $dimension && ($dimension == 2 || $dimension == 3);

    die "transform requires a matrix\n"
        unless RPN::Matrix::is_matrix($matrix);

    my $size = $dimension + 1;
    die "${dimension}D transform requires a ${size}x${size} matrix\n"
        unless $matrix->rows == $size && $matrix->cols == $size;

    return bless {
        dimension => $dimension,
        matrix    => RPN::Matrix->new($matrix->data),
    }, $class;
}

sub is_transform {
    my ($thing) = @_;
    return blessed($thing) && $thing->isa(__PACKAGE__);
}

sub dimension {
    my ($self) = @_;
    return $self->{dimension};
}

sub matrix {
    my ($self) = @_;
    return RPN::Matrix->new($self->{matrix}->data);
}

sub identity {
    my ($class, $dimension) = @_;
    _require_dimension($dimension);

    my $size = $dimension + 1;
    my @rows;
    for my $r (0 .. $size - 1) {
        push @rows, [ map { $_ == $r ? 1 : 0 } 0 .. $size - 1 ];
    }

    return $class->new(
        dimension => $dimension,
        matrix    => RPN::Matrix->new(@rows),
    );
}

sub translation2d {
    my ($class, $dx, $dy) = @_;
    _require_numbers($dx, $dy);

    return $class->new(
        dimension => 2,
        matrix => RPN::Matrix->new(
            [1, 0, $dx],
            [0, 1, $dy],
            [0, 0, 1],
        ),
    );
}

sub rotation2d {
    my ($class, $radians) = @_;
    _require_numbers($radians);

    my $cos = cos($radians);
    my $sin = sin($radians);

    return $class->new(
        dimension => 2,
        matrix => RPN::Matrix->new(
            [$cos, -$sin, 0],
            [$sin,  $cos, 0],
            [0,         0, 1],
        ),
    );
}

sub scaling2d {
    my ($class, $sx, $sy) = @_;
    _require_numbers($sx, $sy);

    return $class->new(
        dimension => 2,
        matrix => RPN::Matrix->new(
            [$sx, 0,   0],
            [0,   $sy, 0],
            [0,   0,   1],
        ),
    );
}

sub shearing2d {
    my ($class, $x_by_y, $y_by_x) = @_;
    _require_numbers($x_by_y, $y_by_x);

    return $class->new(
        dimension => 2,
        matrix => RPN::Matrix->new(
            [1,       $x_by_y, 0],
            [$y_by_x, 1,       0],
            [0,       0,       1],
        ),
    );
}

sub reflection_x2d {
    my ($class) = @_;
    return $class->scaling2d(1, -1);
}

sub reflection_y2d {
    my ($class) = @_;
    return $class->scaling2d(-1, 1);
}

sub translation3d {
    my ($class, $dx, $dy, $dz) = @_;
    _require_numbers($dx, $dy, $dz);

    return $class->new(
        dimension => 3,
        matrix => RPN::Matrix->new(
            [1, 0, 0, $dx],
            [0, 1, 0, $dy],
            [0, 0, 1, $dz],
            [0, 0, 0, 1],
        ),
    );
}

sub scaling3d {
    my ($class, $sx, $sy, $sz) = @_;
    _require_numbers($sx, $sy, $sz);

    return $class->new(
        dimension => 3,
        matrix => RPN::Matrix->new(
            [$sx, 0,   0,   0],
            [0,   $sy, 0,   0],
            [0,   0,   $sz, 0],
            [0,   0,   0,   1],
        ),
    );
}

sub rotation_x3d {
    my ($class, $radians) = @_;
    _require_numbers($radians);
    my $cos = cos($radians);
    my $sin = sin($radians);

    return $class->new(
        dimension => 3,
        matrix => RPN::Matrix->new(
            [1, 0,     0,    0],
            [0, $cos, -$sin, 0],
            [0, $sin,  $cos, 0],
            [0, 0,     0,    1],
        ),
    );
}

sub rotation_y3d {
    my ($class, $radians) = @_;
    _require_numbers($radians);
    my $cos = cos($radians);
    my $sin = sin($radians);

    return $class->new(
        dimension => 3,
        matrix => RPN::Matrix->new(
            [ $cos, 0, $sin, 0],
            [0,     1, 0,     0],
            [-$sin, 0, $cos, 0],
            [0,     0, 0,     1],
        ),
    );
}

sub rotation_z3d {
    my ($class, $radians) = @_;
    _require_numbers($radians);
    my $cos = cos($radians);
    my $sin = sin($radians);

    return $class->new(
        dimension => 3,
        matrix => RPN::Matrix->new(
            [$cos, -$sin, 0, 0],
            [$sin,  $cos, 0, 0],
            [0,         0, 1, 0],
            [0,         0, 0, 1],
        ),
    );
}

sub reflection_xy3d {
    my ($class) = @_;
    return $class->scaling3d(1, 1, -1);
}

sub reflection_xz3d {
    my ($class) = @_;
    return $class->scaling3d(1, -1, 1);
}

sub reflection_yz3d {
    my ($class) = @_;
    return $class->scaling3d(-1, 1, 1);
}

sub then {
    my ($self, $next) = @_;

    die "transform composition requires another transform\n"
        unless is_transform($next);
    die "transform composition requires matching dimensions\n"
        unless $self->dimension == $next->dimension;

    return __PACKAGE__->new(
        dimension => $self->dimension,
        matrix    => $next->{matrix}->multiply($self->{matrix}),
    );
}

sub inverse {
    my ($self) = @_;
    return __PACKAGE__->new(
        dimension => $self->dimension,
        matrix    => $self->{matrix}->inverse,
    );
}

sub apply {
    my ($self, $point) = @_;

    die "transform application requires a vector point\n"
        unless RPN::Vector::is_vector($point);
    die "point dimension must match transform dimension\n"
        unless $point->dim == $self->dimension;

    my $homogeneous = RPN::Vector->new($point->values, 1);
    my $result = $self->{matrix}->multiply_vector($homogeneous);
    my @values = $result->values;
    my $w = pop @values;

    die "transform produced a point at infinity\n"
        if abs($w) < 1e-12;

    @values = map { _clean_number($_ / $w) } @values;
    return RPN::Vector->new(@values);
}

sub as_string {
    my ($self) = @_;
    return sprintf 'transform%dd%s',
        $self->dimension,
        $self->{matrix}->as_string;
}

sub _clean_number {
    my ($value) = @_;
    return 0 if abs($value) < 1e-12;
    my $integer = int($value);
    return $integer if abs($value - $integer) < 1e-12;
    return $value;
}

sub _require_dimension {
    my ($dimension) = @_;
    die "transform dimension must be 2 or 3\n"
        unless defined $dimension && ($dimension == 2 || $dimension == 3);
    return;
}

sub _require_numbers {
    for my $value (@_) {
        die "transform parameters must be numbers\n"
            if !defined($value) || ref($value)
                || $value !~ /^[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?$/;
    }
    return;
}

1;
