package RPN::Matrix;

use v5.34;
use strict;
use warnings;

use Scalar::Util qw(blessed);

sub new {
    my ($class, @rows) = @_;

    die "matrix requires at least one row\n"
        unless @rows;

    my $cols = scalar @{ $rows[0] };

    die "matrix rows must not be empty\n"
        unless $cols;

    foreach my $row (@rows) {
        die "matrix rows must be array references\n"
            unless ref($row) eq 'ARRAY';

        die "matrix rows must all have the same length\n"
            unless @$row == $cols;
    }

    my $self = bless {
        rows => scalar @rows,
        cols => $cols,
        data => [ map { [ @$_ ] } @rows ],
    }, $class;

    return $self;
}

sub is_matrix {
    my ($thing) = @_;

    return blessed($thing) && $thing->isa(__PACKAGE__);
}

sub rows {
    my ($self) = @_;
    return $self->{rows};
}

sub cols {
    my ($self) = @_;
    return $self->{cols};
}

sub data {
    my ($self) = @_;
    return map { [ @$_ ] } @{ $self->{data} };
}

sub get {
    my ($self, $row, $col) = @_;
    return $self->{data}[$row][$col];
}

sub as_string {
    my ($self) = @_;
    return '['
        . join(
            ',',
            map { '[' . join(',', @$_) . ']' } @{ $self->{data} }
        )
        . ']';
}

sub same_dim {
    my ($self, $other) = @_;
    return 0 unless is_matrix($other);
    return $self->rows == $other->rows
        && $self->cols == $other->cols;
}

sub add {
    my ($self, $other) = @_;
    die "matrix add requires matrices of the same dimensions\n"
        unless $self->same_dim($other);
    my @result;
    for my $r (0 .. $self->rows - 1) {
        my @row;
        for my $c (0 .. $self->cols - 1) {
            push @row, $self->get($r, $c) + $other->get($r, $c);
        }
        push @result, \@row;
    }
    return RPN::Matrix->new(@result);
}

sub subtract {
    my ($self, $other) = @_;
    die "matrix subtract requires matrices of the same dimensions\n"
        unless $self->same_dim($other);
    my @result;
    for my $r (0 .. $self->rows - 1) {
        my @row;
        for my $c (0 .. $self->cols - 1) {
            push @row, $self->get($r, $c) - $other->get($r, $c);
        }
        push @result, \@row;
    }
    return RPN::Matrix->new(@result);
}

sub multiply {
    my ($self, $other) = @_;
    die "matrix multiply requires left cols == right rows\n"
        unless is_matrix($other) && $self->cols == $other->rows;
    my @result;
    for my $r (0 .. $self->rows - 1) {
        my @row;
        for my $c (0 .. $other->cols - 1) {
            my $sum = 0;
            for my $k (0 .. $self->cols - 1) {
                $sum += $self->get($r, $k) * $other->get($k, $c);
            }
            push @row, $sum;
        }
        push @result, \@row;
    }
    return RPN::Matrix->new(@result);
}

sub transpose {
    my ($self) = @_;
    my @result;
    for my $c (0 .. $self->cols - 1) {
        my @row;
        for my $r (0 .. $self->rows - 1) {
            push @row, $self->get($r, $c);
        }
        push @result, \@row;
    }
    return RPN::Matrix->new(@result);
}

sub parse {
    my ($class, $text) = @_;
    die "matrix literal required\n"
        unless defined $text;
    $text =~ s/^\s+//;
    $text =~ s/\s+$//;
    die "matrix literal must look like [[...],[...]]\n"
        unless $text =~ /^\[\s*\[.*\]\s*\]$/s;
    my @rows;
    while ($text =~ /\[([^\[\]]+)\]/g) {
        my $row_text = $1;
        my @values = grep { length } split /\s*,\s*/, $row_text;
        die "matrix row must not be empty\n"
            unless @values;
        foreach my $value (@values) {
            die "matrix values must be numeric\n"
                unless $value =~ /^[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?$/;
        }
        push @rows, \@values;
    }
    return $class->new(@rows);
}

sub _minor {
    my ($self, $remove_row, $remove_col) = @_;
    my @minor;
    for my $r (0 .. $self->rows - 1) {
        next if $r == $remove_row;
        my @row;
        for my $c (0 .. $self->cols - 1) {
            next if $c == $remove_col;
            push @row, $self->get($r, $c);
        }
        push @minor, \@row;
    }
    return RPN::Matrix->new(@minor);
}

sub determinant {
    my ($self) = @_;
    die "determinant requires a square matrix\n"
        unless $self->rows == $self->cols;
    return $self->get(0, 0)
        if $self->rows == 1;
    return $self->get(0, 0) * $self->get(1, 1)
         - $self->get(0, 1) * $self->get(1, 0)
        if $self->rows == 2;
    my $det = 0;
    for my $c (0 .. $self->cols - 1) {
        my $sign = ($c % 2 == 0) ? 1 : -1;
        $det += $sign
              * $self->get(0, $c)
              * $self->_minor(0, $c)->determinant;
    }
    return $det;
}

sub cofactor {
    my ($self, $row, $col) = @_;

    die "cofactor requires a square matrix\n"
        unless $self->rows == $self->cols;

    my $sign = (($row + $col) % 2 == 0) ? 1 : -1;

    return $sign * $self->_minor($row, $col)->determinant;
}

sub cofactor_matrix {
    my ($self) = @_;

    die "cofactor matrix requires a square matrix\n"
        unless $self->rows == $self->cols;

    my @result;

    for my $r (0 .. $self->rows - 1) {
        my @row;
        for my $c (0 .. $self->cols - 1) {
            push @row, $self->cofactor($r, $c);
        }
        push @result, \@row;
    }
    return RPN::Matrix->new(@result);
}

sub inverse {
    my ($self) = @_;
    die "inverse requires a square matrix\n"
        unless $self->rows == $self->cols;
    my $det = $self->determinant;
    die "inverse requires a non-singular matrix\n"
        if $det == 0;
    if ($self->rows == 1) {
        return RPN::Matrix->new([ 1 / $self->get(0, 0) ]);
    }
    my $cofactor_matrix = $self->cofactor_matrix;
    my $adjugate        = $cofactor_matrix->transpose;
    my @result;
    for my $r (0 .. $adjugate->rows - 1) {
        my @row;
        for my $c (0 .. $adjugate->cols - 1) {
            push @row, $adjugate->get($r, $c) / $det;
        }
        push @result, \@row;
    }
    return RPN::Matrix->new(@result);
}

1;
