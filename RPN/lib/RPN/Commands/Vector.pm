package RPN::Commands::Vector;

use v5.34;
use strict;
use warnings;

sub register_commands {
    my ($commands) = @_;

    #
    # Vector mathematics
    #

    $commands->register(
        vector => {
            type => 'vector',
            help => 'create a vector from N stack values: N vector',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $n = $calc->stack->pop;
                unless (!ref($n) && $calc->isanumber($n) && int($n) == $n && $n > 0) {
                    $calc->stack->push($n);
                    warn "vector requires a positive integer dimension\n";
                    return;
                }
                unless ($calc->stack->require_depth($n)) {
                    $calc->stack->push($n);
                    return;
                }
                my @values;
                for (1 .. $n) {
                    my $value = $calc->stack->pop;
                    unless (!ref($value) && $calc->isanumber($value)) {
                        $calc->stack->push(reverse @values);
                        $calc->stack->push($value);
                        $calc->stack->push($n);
                        warn "vector values must be numeric\n";
                        return;
                    }
                    push @values, $value;
                }
                @values = reverse @values;
                $calc->stack->push(RPN::Vector->new(@values));
            },
        }
    );

    $commands->register(
        vec2 => {
            type => 'vector',
            help => 'create a 2D vector from top two stack values',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my $y = $calc->stack->pop;
                my $x = $calc->stack->pop;
                unless (!ref($x) && !ref($y) && $calc->isanumber($x) && $calc->isanumber($y)) {
                    $calc->stack->push($x);
                    $calc->stack->push($y);
                    warn "vec2 requires numeric operands\n";
                    return;
                }
                $calc->stack->push(RPN::Vector->new($x, $y));
            },
        }
    );

    $commands->register(
        vec3 => {
            type => 'vector',
            help => 'create a 3D vector from top three stack values',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(3);
                my $z = $calc->stack->pop;
                my $y = $calc->stack->pop;
                my $x = $calc->stack->pop;
                unless (
                    !ref($x) && !ref($y) && !ref($z)
                    && $calc->isanumber($x)
                    && $calc->isanumber($y)
                    && $calc->isanumber($z)
                ) {
                    $calc->stack->push($x);
                    $calc->stack->push($y);
                    $calc->stack->push($z);
                    warn "vec3 requires numeric operands\n";
                    return;
                }
                $calc->stack->push(RPN::Vector->new($x, $y, $z));
            },
        }
    );

    $commands->register(
        dim => {
            type => 'vector',
            help => 'replace a vector with its dimension',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $v = $calc->stack->pop;
                unless (RPN::Vector::is_vector($v)) {
                    $calc->stack->push($v);
                    warn "dim requires a vector\n";
                    return;
                }
                $calc->stack->push($v->dim);
            },
        }
    );

    $commands->register(
        vadd => {
            type => 'vector',
            help => 'add two vectors of the same dimension',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my $b = $calc->stack->pop;
                my $a = $calc->stack->pop;
                unless (RPN::Vector::is_vector($a) && RPN::Vector::is_vector($b)) {
                    $calc->stack->push($a);
                    $calc->stack->push($b);
                    warn "vadd requires two vectors\n";
                    return;
                }
                unless ($a->same_dim($b)) {
                    $calc->stack->push($a);
                    $calc->stack->push($b);
                    warn "vadd requires vectors of the same dimension\n";
                    return;
                }
                $calc->stack->push($a->add($b));
            },
        }
    );

    $commands->register(
        vsub => {
            type => 'vector',
            help => 'subtract top vector from second vector',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my $b = $calc->stack->pop;
                my $a = $calc->stack->pop;
                unless (RPN::Vector::is_vector($a) && RPN::Vector::is_vector($b)) {
                    $calc->stack->push($a);
                    $calc->stack->push($b);
                    warn "vsub requires two vectors\n";
                    return;
                }
                unless ($a->same_dim($b)) {
                    $calc->stack->push($a);
                    $calc->stack->push($b);
                    warn "vsub requires vectors of the same dimension\n";
                    return;
                }
                $calc->stack->push($a->subtract($b));
            },
        }
    );

    $commands->register(
        vscale => {
            type => 'vector',
            help => 'scale a vector by a scalar: vector scalar vscale',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my $scalar = $calc->stack->pop;
                my $vector = $calc->stack->pop;
                unless (RPN::Vector::is_vector($vector) && !ref($scalar) && $calc->isanumber($scalar)) {
                    $calc->stack->push($vector);
                    $calc->stack->push($scalar);
                    warn "vscale requires a vector and a numeric scalar\n";
                    return;
                }
                $calc->stack->push($vector->scale($scalar));
            },
        }
    );

    $commands->register(
        dot => {
            type => 'vector',
            help => 'dot product of two vectors',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my $b = $calc->stack->pop;
                my $a = $calc->stack->pop;
                unless (RPN::Vector::is_vector($a) && RPN::Vector::is_vector($b)) {
                    $calc->stack->push($a);
                    $calc->stack->push($b);
                    warn "dot requires two vectors\n";
                    return;
                }
                unless ($a->same_dim($b)) {
                    $calc->stack->push($a);
                    $calc->stack->push($b);
                    warn "dot requires vectors of the same dimension\n";
                    return;
                }
                $calc->stack->push($a->dot($b));
            },
        }
    );

    $commands->register(
        cross => {
            type => 'vector',
            help => 'cross product of two 3D vectors',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my $b = $calc->stack->pop;
                my $a = $calc->stack->pop;
                unless (RPN::Vector::is_vector($a) && RPN::Vector::is_vector($b)) {
                    $calc->stack->push($a);
                    $calc->stack->push($b);
                    warn "cross requires two vectors\n";
                    return;
                }
                unless ($a->dim == 3 && $b->dim == 3) {
                    $calc->stack->push($a);
                    $calc->stack->push($b);
                    warn "cross requires two 3D vectors\n";
                    return;
                }
                $calc->stack->push($a->cross($b));
            },
        }
    );

    $commands->register(
        magnitude => {
            aliases => ['mag'],
            type    => 'vector',
            help    => 'replace a vector with its magnitude',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $v = $calc->stack->pop;
                unless (RPN::Vector::is_vector($v)) {
                    $calc->stack->push($v);
                    warn "magnitude requires a vector\n";
                    return;
                }
                $calc->stack->push($v->magnitude);
            },
        }
    );

    $commands->register(
        normalize => {
            aliases => ['unit'],
            type    => 'vector',
            help    => 'replace a vector with a unit vector in the same direction',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $v = $calc->stack->pop;
                unless (RPN::Vector::is_vector($v)) {
                    $calc->stack->push($v);
                    warn "normalize requires a vector\n";
                    return;
                }
                if ($v->magnitude == 0) {
                    $calc->stack->push($v);
                    warn "cannot normalize zero vector\n";
                    return;
                }
                $calc->stack->push($v->normalize);
            },
        }
    );


    return;
}

1;
