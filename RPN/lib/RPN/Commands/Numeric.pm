package RPN::Commands::Numeric;

use strict;
use warnings;

use POSIX ();

sub register_commands {
    my ($commands) = @_;

    #
    # Move numeric command registrations here:
    #
    # + - * / ^ sqrt sin cos tan ...
    # ln log log2 exp exp10 inv
    # sqr cube cbrt abs sign
    # floor ceil round trunc frac
    # idiv mod hypot
    #

    #
    # Simple Numeric
    #

    $commands->register(
        add => {
            aliases => ['+'],
            type    => 'numeric',
            help    => 'pops two numbers and pushes their sum',
            code    => sub {
                my ($calc) = @_;
                $commands->_binary_numeric($calc, sub { $_[0] + $_[1] });
            },
        }
    );

    $commands->register(
        subtract => {
            aliases => ['-'],
            type    => 'numeric',
            help    => 'pops two numbers and pushes their difference',
            code    => sub {
                my ($calc) = @_;
                $commands->_binary_numeric($calc, sub { $_[0] - $_[1] });
            },
        }
    );

    $commands->register(
        multiply => {
            aliases => ['*'],
            type    => 'numeric',
            help    => 'pops two numbers and pushes their product',
            code    => sub {
                my ($calc) = @_;
                $commands->_binary_numeric($calc, sub { $_[0] * $_[1] });
            },
        }
    );

    $commands->register(
        divide => {
            aliases => ['/'],
            type    => 'numeric',
            help    => 'pops two numbers and pushes their quotient',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my ($a, $b) = $calc->stack->pop2;
                unless (!ref($a) && $calc->isanumber($a)
                     && !ref($b) && $calc->isanumber($b)) {
                    $calc->stack->push($b);
                    $calc->stack->push($a);
                    warn "divide requires numeric operands\n";
                    return;
                }
                if ($a == 0) {
                    $calc->stack->push($b);
                    $calc->stack->push($a);
                    warn "divide by zero\n";
                    return;
                }
                $calc->stack->push($b / $a);
            },
        }
    );

    $commands->register(
        exponentiate => {
            aliases => ['**', '^'],
            type    => 'numeric',
            help    => 'raises the second stack value to the power of the top stack value',
            code    => sub {
                my ($calc) = @_;
                $commands->_binary_numeric($calc, sub { $_[0] ** $_[1] });
            },
        }
    );

    $commands->register(
        square => {
            type => 'numeric',
            help => 'squares the number on top of the stack',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { $_[0] * $_[0] });
            },
        }
    );

    $commands->register(
        cube => {
            type => 'numeric',
            help => 'cubes the number on top of the stack',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { $_[0] * $_[0] * $_[0] });
            },
        }
    );

    $commands->register(
        squareroot => {
            aliases => [qw(sqrt sqr)],
            type    => 'numeric',
            help    => 'replaces the number on top of the stack with its square root',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $value = $calc->stack->peek;
                if ($value < 0) {
                    warn "sqrt of negative number\n";
                    return;
                }
                $calc->stack->pop;
                $calc->stack->push(sqrt($value));
            },
        }
    );

    $commands->register(
        negate => {
            type => 'numeric',
            help => 'negates the number on top of the stack',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { -$_[0] });
            },
        }
    );

    $commands->register(
        increment => {
            type => 'numeric',
            help => 'increments the number on top of the stack',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { $_[0] + 1 });
            },
        }
    );

    $commands->register(
        decrement => {
            type => 'numeric',
            help => 'decrements the number on top of the stack',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { $_[0] - 1 });
            },
        }
    );

    #
    # Natural logarithm
    #

    $commands->register(
        ln => {
            type => 'numeric',
            help => 'natural logarithm',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;
                die "ln requires a positive value\n"
                    unless defined $x && $x > 0;
                $calc->stack->push( log($x) );
            },
        }
    );

    #
    # Base-10 logarithm
    #

    $commands->register(
        log => {
            type => 'numeric',
            help => 'base-10 logarithm',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;
                die "log requires a positive value\n"
                    unless defined $x && $x > 0;
                $calc->stack->push( log($x) / log(10) );
            },
        }
    );

    #
    # Exponential
    #

    $commands->register(
        exp => {
            type => 'numeric',
            help => 'e raised to x',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;
                $calc->stack->push( exp($x) );
            },
        }
    );

    #
    # Reciprocal
    #

    $commands->register(
        inv => {
            type => 'numeric',
            help => 'reciprocal (1/x)',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;

                die "division by zero\n"
                    if !defined($x) || $x == 0;

                $calc->stack->push( 1 / $x );
            },
        }
    );

    #
    # Absolute value
    #

    $commands->register(
        abs => {
            type => 'numeric',
            help => 'absolute value',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;
                $calc->stack->push( CORE::abs($x) );
            },
        }
    );

    #
    # Powers and Roots
    #

    $commands->register(
        log2 => {
            type => 'numeric',
            help => 'base-2 logarithm',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;
                die "log2 requires a positive value\n"
                    unless defined $x && $x > 0;
                $calc->stack->push( log($x) / log(2) );
            },
        }
    );

    $commands->register(
        exp10 => {
            type => 'numeric',
            help => '10 raised to x',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;
                $calc->stack->push( 10 ** $x );
            },
        }
    );

    $commands->register(
        sqr => {
            type => 'numeric',
            help => 'square a value',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;
                $calc->stack->push( $x * $x );
            },
        }
    );

    $commands->register(
        cube => {
            type => 'numeric',
            help => 'cube a value',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;
                $calc->stack->push( $x * $x * $x );
            },
        }
    );

    $commands->register(
        cbrt => {
            type => 'numeric',
            help => 'cube root',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;

                my $result = $x < 0
                    ? -((- $x) ** (1/3))
                    :   $x  ** (1/3);

                $calc->stack->push($result);
            },
        }
    );

    $commands->register(
        sign => {
            type => 'numeric',
            help => 'sign of value (-1, 0, +1)',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;

                my $result =
                    $x > 0 ?  1 :
                    $x < 0 ? -1 :
                              0;

                $calc->stack->push($result);
            },
        }
    );

    $commands->register(
        floor => {
            type => 'numeric',
            help => 'round down',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;
                $calc->stack->push( POSIX::floor($x) );
            },
        }
    );

    $commands->register(
        ceil => {
            type => 'numeric',
            help => 'round up',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;
                $calc->stack->push( POSIX::ceil($x) );
            },
        }
    );

    $commands->register(
        round => {
            type => 'numeric',
            help => 'nearest integer',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;

                my $result = $x >= 0
                    ? POSIX::floor($x + 0.5)
                    : POSIX::ceil($x - 0.5);

                $calc->stack->push($result);
            },
        }
    );

    $commands->register(
        trunc => {
            type => 'numeric',
            help => 'truncate toward zero',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;

                my $result = $x >= 0
                    ? POSIX::floor($x)
                    : POSIX::ceil($x);

                $calc->stack->push($result);
            },
        }
    );

    $commands->register(
        frac => {
            type => 'numeric',
            help => 'fractional portion',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;

                my $int = $x >= 0
                    ? POSIX::floor($x)
                    : POSIX::ceil($x);

                $calc->stack->push($x - $int);
            },
        }
    );

    $commands->register(
        idiv => {
            type => 'numeric',
            help => 'integer division, truncated toward zero',
            code => sub {
                my ($calc) = @_;
                my $b = $calc->stack->pop;
                my $a = $calc->stack->pop;

                die "idiv requires two numeric values\n"
                    unless defined $a && defined $b;

                die "division by zero\n"
                    if $b == 0;

                my $q = $a / $b;

                my $result = $q >= 0
                    ? POSIX::floor($q)
                    : POSIX::ceil($q);

                $calc->stack->push($result);
            },
        }
    );

    $commands->register(
        hypot => {
            type => 'numeric',
            help => 'sqrt(x^2 + y^2)',
            code => sub {
                my ($calc) = @_;
                my $y = $calc->stack->pop;
                my $x = $calc->stack->pop;
                die "hypot requires two numeric values\n"
                    unless defined $x && defined $y;
                $calc->stack->push( sqrt($x * $x + $y * $y) );
            },
        }
    );

    #
    # Bessel functions
    #

    $commands->register(
        j0 => {
            type => 'numeric',
            help => 'Bessel function of the first kind, order 0: J0(x)',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { POSIX::j0($_[0]) });
            },
        }
    );

    $commands->register(
        j1 => {
            type => 'numeric',
            help => 'Bessel function of the first kind, order 1: J1(x)',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { POSIX::j1($_[0]) });
            },
        }
    );

    $commands->register(
        jn => {
            type => 'numeric',
            help => 'Bessel function of the first kind: x n jn computes Jn(x)',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my ($n, $x) = $calc->stack->pop2;

                unless (!ref($x) && $calc->isanumber($x)
                     && !ref($n) && $calc->isanumber($n)) {
                    $calc->stack->push($x);
                    $calc->stack->push($n);
                    warn "jn requires numeric operands\n";
                    return;
                }

                unless ($n == int($n)) {
                    $calc->stack->push($x);
                    $calc->stack->push($n);
                    warn "jn requires an integer order\n";
                    return;
                }

                $calc->stack->push(POSIX::jn(int($n), $x));
            },
        }
    );

    $commands->register(
        y0 => {
            type => 'numeric',
            help => 'Bessel function of the second kind, order 0: Y0(x)',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $x = $calc->stack->pop;

                unless (!ref($x) && $calc->isanumber($x)) {
                    $calc->stack->push($x);
                    warn "y0 requires a numeric operand\n";
                    return;
                }

                if ($x <= 0) {
                    $calc->stack->push($x);
                    warn "y0 requires a positive value\n";
                    return;
                }

                $calc->stack->push(POSIX::y0($x));
            },
        }
    );

    $commands->register(
        y1 => {
            type => 'numeric',
            help => 'Bessel function of the second kind, order 1: Y1(x)',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $x = $calc->stack->pop;

                unless (!ref($x) && $calc->isanumber($x)) {
                    $calc->stack->push($x);
                    warn "y1 requires a numeric operand\n";
                    return;
                }

                if ($x <= 0) {
                    $calc->stack->push($x);
                    warn "y1 requires a positive value\n";
                    return;
                }

                $calc->stack->push(POSIX::y1($x));
            },
        }
    );

    $commands->register(
        yn => {
            type => 'numeric',
            help => 'Bessel function of the second kind: x n yn computes Yn(x)',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my ($n, $x) = $calc->stack->pop2;

                unless (!ref($x) && $calc->isanumber($x)
                     && !ref($n) && $calc->isanumber($n)) {
                    $calc->stack->push($x);
                    $calc->stack->push($n);
                    warn "yn requires numeric operands\n";
                    return;
                }

                unless ($n == int($n)) {
                    $calc->stack->push($x);
                    $calc->stack->push($n);
                    warn "yn requires an integer order\n";
                    return;
                }

                if ($x <= 0) {
                    $calc->stack->push($x);
                    $calc->stack->push($n);
                    warn "yn requires a positive x value\n";
                    return;
                }

                $calc->stack->push(POSIX::yn(int($n), $x));
            },
        }
    );

    $commands->register(
        modulo => {
            aliases => [qw(mod %)],
            type    => 'numeric',
            help    => 'pops two numbers and pushes their modulus',
            code    => sub {
                my ($calc) = @_;
    
                return unless $calc->stack->require_depth(2);
    
                my ($a, $b) = $calc->stack->pop2;
    
                unless (!ref($a) && $calc->isanumber($a)
                     && !ref($b) && $calc->isanumber($b)) {
                    $calc->stack->push($b);
                    $calc->stack->push($a);
                    warn "modulo requires numeric operands\n";
                    return;
                }
    
                if ($a == 0) {
                    $calc->stack->push($b);
                    $calc->stack->push($a);
                    warn "modulo by zero\n";
                    return;
                }
    
                $calc->stack->push($b % $a);
            },
        }
    );

    return;
}

1;
