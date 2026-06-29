package RPN::Commands::Matrix;

use v5.34;
use strict;
use warnings;

use RPN::Matrix;
use RPN::Vector;

sub register_commands {
    my ($commands) = @_;

    #
    # Matrix mathematics
    #

    $commands->register(
        matrix => {
            category => 'matrix',
            help => 'create a matrix from N row vectors: N matrix',
            code => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(1);

                my $n = $calc->stack->pop;

                unless (!ref($n) && $calc->isanumber($n) && int($n) == $n && $n > 0) {
                    $calc->stack->push($n);
                    warn "matrix requires a positive integer row count\n";
                    return;
                }

                unless ($calc->stack->require_depth($n)) {
                    $calc->stack->push($n);
                    return;
                }

                my @rows;

                for (1 .. $n) {
                    my $row = $calc->stack->pop;

                    unless (RPN::Vector::is_vector($row)) {
                        $calc->stack->push(reverse @rows);
                        $calc->stack->push($row);
                        $calc->stack->push($n);
                        warn "matrix requires row vectors\n";
                        return;
                    }

                    push @rows, [ $row->values ];
                }

                @rows = reverse @rows;

                eval {
                    $calc->stack->push(RPN::Matrix->new(@rows));
                    1;
                } or do {
                    my $error = $@ || "unknown matrix error\n";

                    foreach my $row (@rows) {
                        $calc->stack->push(RPN::Vector->new(@$row));
                    }

                    $calc->stack->push($n);

                    warn $error;
                    return;
                };
            },
        }
    );

    $commands->register(
        matcols => {
            category => 'matrix',
            help => 'create a matrix from N column vectors: N matcols',
            code => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(1);

                my $n = $calc->stack->pop;

                unless (!ref($n) && $calc->isanumber($n) && int($n) == $n && $n > 0) {
                    $calc->stack->push($n);
                    warn "matcols requires a positive integer column count\n";
                    return;
                }

                unless ($calc->stack->require_depth($n)) {
                    $calc->stack->push($n);
                    return;
                }

                my @cols;

                for (1 .. $n) {
                    my $col = $calc->stack->pop;

                    unless (RPN::Vector::is_vector($col)) {
                        $calc->stack->push(reverse @cols);
                        $calc->stack->push($col);
                        $calc->stack->push($n);
                        warn "matcols requires column vectors\n";
                        return;
                    }

                    push @cols, [ $col->values ];
                }

                @cols = reverse @cols;

                my $rows = scalar @{ $cols[0] };

                foreach my $col (@cols) {
                    unless (@$col == $rows) {
                        foreach my $restore (@cols) {
                            $calc->stack->push(RPN::Vector->new(@$restore));
                        }

                        $calc->stack->push($n);

                        warn "matcols requires columns of the same dimension\n";
                        return;
                    }
                }

                my @matrix_rows;

                for my $r (0 .. $rows - 1) {
                    my @row;

                    for my $c (0 .. $#cols) {
                        push @row, $cols[$c][$r];
                    }

                    push @matrix_rows, \@row;
                }

                $calc->stack->push(RPN::Matrix->new(@matrix_rows));
            },
        }
    );

    $commands->register(
        matparse => {
            category => 'matrix',
            help => 'parse a matrix literal from the stack: [[1,2],[3,4]] matparse',
            code => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(1);

                my $text = $calc->stack->pop;

                unless (!ref($text)) {
                    $calc->stack->push($text);
                    warn "matparse requires a matrix literal string\n";
                    return;
                }

                my $matrix = eval { RPN::Matrix->parse($text) };

                if ($@ || !RPN::Matrix::is_matrix($matrix)) {
                    $calc->stack->push($text);
                    warn "matparse could not parse matrix literal\n";
                    return;
                }

                $calc->stack->push($matrix);
            },
        }
    );

    $commands->register(
        loadmatrix => {
            category => 'matrix',
            help => 'load a matrix from a file: loadmatrix <file>',
            code => sub {
                my ($calc, $arg_str, $args) = @_;

                unless ($args && @$args) {
                    warn "usage: loadmatrix <file>\n";
                    return;
                }

                my $file = $args->[0];

                open my $fh, '<', $file
                    or do {
                        warn "Cannot read matrix file '$file': $!\n";
                        return;
                    };

                my @lines = grep { /\S/ && !/^\s*#/ } <$fh>;
                close $fh;

                chomp @lines;

                my $text = join "\n", @lines;

                my $matrix;

                if ($text =~ /^\s*\[/) {
                    $matrix = eval { RPN::Matrix->parse($text) };
                }
                else {
                    my @rows;

                    foreach my $line (@lines) {
                        my @values = grep { length } split /[\s,;]+/, $line;

                        unless (@values) {
                            next;
                        }

                        foreach my $value (@values) {
                            unless ($calc->isanumber($value)) {
                                warn "loadmatrix requires numeric values\n";
                                return;
                            }
                        }

                        push @rows, \@values;
                    }

                    $matrix = eval { RPN::Matrix->new(@rows) };
                }

                if ($@ || !RPN::Matrix::is_matrix($matrix)) {
                    warn "loadmatrix could not create matrix\n";
                    return;
                }

                $calc->stack->push($matrix);
            },
        }
    );

    $commands->register(
        rows => {
            category => 'matrix',
            help => 'replace a matrix with its row count',
            code => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(1);

                my $m = $calc->stack->pop;

                unless (RPN::Matrix::is_matrix($m)) {
                    $calc->stack->push($m);
                    warn "rows requires a matrix\n";
                    return;
                }

                $calc->stack->push($m->rows);
            },
        }
    );

    $commands->register(
        cols => {
            category => 'matrix',
            help => 'replace a matrix with its column count',
            code => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(1);

                my $m = $calc->stack->pop;

                unless (RPN::Matrix::is_matrix($m)) {
                    $calc->stack->push($m);
                    warn "cols requires a matrix\n";
                    return;
                }

                $calc->stack->push($m->cols);
            },
        }
    );

    $commands->register(
        madd => {
            category => 'matrix',
            help => 'add two matrices of the same dimensions',
            code => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(2);

                my $b = $calc->stack->pop;
                my $a = $calc->stack->pop;

                unless (RPN::Matrix::is_matrix($a) && RPN::Matrix::is_matrix($b)) {
                    $calc->stack->push($a);
                    $calc->stack->push($b);
                    warn "madd requires two matrices\n";
                    return;
                }

                unless ($a->same_dim($b)) {
                    $calc->stack->push($a);
                    $calc->stack->push($b);
                    warn "madd requires matrices of the same dimensions\n";
                    return;
                }

                $calc->stack->push($a->add($b));
            },
        }
    );

    $commands->register(
        msub => {
            category => 'matrix',
            help => 'subtract top matrix from second matrix',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my $b = $calc->stack->pop;
                my $a = $calc->stack->pop;
                unless (RPN::Matrix::is_matrix($a) && RPN::Matrix::is_matrix($b)) {
                    $calc->stack->push($a);
                    $calc->stack->push($b);
                    warn "msub requires two matrices\n";
                    return;
                }
                unless ($a->same_dim($b)) {
                    $calc->stack->push($a);
                    $calc->stack->push($b);
                    warn "msub requires matrices of the same dimensions\n";
                    return;
                }
                $calc->stack->push($a->subtract($b));
            },
        }
    );

    $commands->register(
        mmul => {
            category => 'matrix',
            help => 'multiply matrices, matrix/vector, or vector/matrix operands',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my $b = $calc->stack->pop;
                my $a = $calc->stack->pop;

                if (RPN::Matrix::is_matrix($a) && RPN::Matrix::is_matrix($b)) {
                    unless ($a->cols == $b->rows) {
                        $calc->stack->push($a);
                        $calc->stack->push($b);
                        warn "mmul requires left columns to equal right rows\n";
                        return;
                    }
                    $calc->stack->push($a->multiply($b));
                    return;
                }

                if (RPN::Matrix::is_matrix($a) && RPN::Vector::is_vector($b)) {
                    my @v = $b->values;
                    unless ($a->cols == @v) {
                        $calc->stack->push($a);
                        $calc->stack->push($b);
                        warn "matrix columns must equal vector dimension\n";
                        return;
                    }
                    $calc->stack->push($a->multiply_vector($b));
                    return;
                }

                if (RPN::Vector::is_vector($a) && RPN::Matrix::is_matrix($b)) {
                    my @v = $a->values;
                    unless (@v == $b->rows) {
                        $calc->stack->push($a);
                        $calc->stack->push($b);
                        warn "vector dimension must equal matrix rows\n";
                        return;
                    }
                    $calc->stack->push($b->left_multiply_vector($a));
                    return;
                }

                $calc->stack->push($a);
                $calc->stack->push($b);

                warn "mmul requires matrices or matrix/vector operands\n";
                return;
            },
        }
    );

    $commands->register(
        transpose => {
            aliases => ['trans'],
            category => 'matrix',
            help    => 'transpose a matrix',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $m = $calc->stack->pop;
                unless (RPN::Matrix::is_matrix($m)) {
                    $calc->stack->push($m);
                    warn "transpose requires a matrix\n";
                    return;
                }
                $calc->stack->push($m->transpose);
            },
        }
    );

    $commands->register(
        determinant => {
            aliases => ['det'],
            category => 'matrix',
            help    => 'compute determinant of a square matrix',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $m = $calc->stack->pop;
                unless (RPN::Matrix::is_matrix($m)) {
                    $calc->stack->push($m);
                    warn "determinant requires a matrix\n";
                    return;
                }
                unless ($m->rows == $m->cols) {
                    $calc->stack->push($m);
                    warn "determinant requires a square matrix\n";
                    return;
                }
                $calc->stack->push($m->determinant);
            },
        }
    );

    $commands->register(
        inverse => {
            aliases => ['invm'],
            category => 'matrix',
            help    => 'compute inverse of a square non-singular matrix',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $m = $calc->stack->pop;
                unless (RPN::Matrix::is_matrix($m)) {
                    $calc->stack->push($m);
                    warn "inverse requires a matrix\n";
                    return;
                }
                unless ($m->rows == $m->cols) {
                    $calc->stack->push($m);
                    warn "inverse requires a square matrix\n";
                    return;
                }
                if ($m->determinant == 0) {
                    $calc->stack->push($m);
                    warn "inverse requires a non-singular matrix\n";
                    return;
                }
                $calc->stack->push($m->inverse);
            },
        }
    );

    $commands->register(
        mpow => {
            category => 'matrix',
            help => 'raise a square matrix to a non-negative integer power: matrix n mpow',
            code => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(2);

                my $n = $calc->stack->pop;
                my $m = $calc->stack->pop;

                unless (RPN::Matrix::is_matrix($m)) {
                    $calc->stack->push($m);
                    $calc->stack->push($n);
                    warn "mpow requires a matrix and exponent\n";
                    return;
                }

                unless (!ref($n) && $calc->isanumber($n) && int($n) == $n && $n >= 0) {
                    $calc->stack->push($m);
                    $calc->stack->push($n);
                    warn "mpow requires a non-negative integer exponent\n";
                    return;
                }

                unless ($m->rows == $m->cols) {
                    $calc->stack->push($m);
                    $calc->stack->push($n);
                    warn "mpow requires a square matrix\n";
                    return;
                }

                $calc->stack->push($m->power($n));
            },
        }
    );

    return;
}



1;
