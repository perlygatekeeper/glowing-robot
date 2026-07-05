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
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
            help    => 'pops two numbers and pushes their quotient',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2,'divide');
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
            category => 'numeric',
            help    => 'raises the second stack value to the power of the top stack value',
            code    => sub {
                my ($calc) = @_;
                $commands->_binary_numeric($calc, sub { $_[0] ** $_[1] });
            },
        }
    );

    $commands->register(
        square => {
            category => 'numeric',
            help => 'squares the number on top of the stack',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { $_[0] * $_[0] });
            },
        }
    );

    $commands->register(
        cube => {
            category => 'numeric',
            help => 'cubes the number on top of the stack',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { $_[0] * $_[0] * $_[0] });
            },
        }
    );

    $commands->register(
        squareroot => {
            aliases => [qw(sqrt)],
            category => 'numeric',
            help    => 'replaces the number on top of the stack with its square root',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'squareroot');
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
            category => 'numeric',
            help => 'negates the number on top of the stack',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { -$_[0] });
            },
        }
    );

    $commands->register(
        increment => {
            category => 'numeric',
            help => 'increments the number on top of the stack',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { $_[0] + 1 });
            },
        }
    );

    $commands->register(
        decrement => {
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
            help => 'square a value',
            code => sub {
                my ($calc) = @_;
                my $x = $calc->stack->pop;
                $calc->stack->push( $x * $x );
            },
        }
    );

    $commands->register(
        cbrt => {
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
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
            category => 'numeric',
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
    # Special functions
    #

    $commands->register(
        erf => {
            category => 'numeric',
            help => 'error function: erf(x)',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { POSIX::erf($_[0]) });
            },
        }
    );

    $commands->register(
        erfc => {
            category => 'numeric',
            help => 'complementary error function: erfc(x)',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { POSIX::erfc($_[0]) });
            },
        }
    );

    $commands->register(
        gamma => {
            category => 'numeric',
            help => 'gamma function: Gamma(x)',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'gamma');
                my $x = $calc->stack->pop;

                unless (!ref($x) && $calc->isanumber($x)) {
                    $calc->stack->push($x);
                    warn "gamma requires a numeric operand\n";
                    return;
                }

                if (_is_nonpositive_integer($x)) {
                    $calc->stack->push($x);
                    warn "gamma undefined for zero and negative integers\n";
                    return;
                }

                $calc->stack->push(POSIX::tgamma($x));
            },
        }
    );

    $commands->register(
        lgamma => {
            category => 'numeric',
            help => 'natural logarithm of the gamma function: ln(Gamma(x))',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'lgamma');
                my $x = $calc->stack->pop;

                unless (!ref($x) && $calc->isanumber($x)) {
                    $calc->stack->push($x);
                    warn "lgamma requires a numeric operand\n";
                    return;
                }

                if ($x <= 0) {
                    $calc->stack->push($x);
                    warn "lgamma requires a positive value\n";
                    return;
                }

                $calc->stack->push(POSIX::lgamma($x));
            },
        }
    );

    $commands->register(
        beta => {
            category => 'numeric',
            help => 'beta function: x y beta computes B(x,y)',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2,'beta');
                my ($y, $x) = $calc->stack->pop2;

                unless (!ref($x) && $calc->isanumber($x)
                     && !ref($y) && $calc->isanumber($y)) {
                    $calc->stack->push($x);
                    $calc->stack->push($y);
                    warn "beta requires numeric operands\n";
                    return;
                }

                if ($x <= 0 || $y <= 0) {
                    $calc->stack->push($x);
                    $calc->stack->push($y);
                    warn "beta requires positive values\n";
                    return;
                }

                my $log_beta = POSIX::lgamma($x)
                             + POSIX::lgamma($y)
                             - POSIX::lgamma($x + $y);

                $calc->stack->push(exp($log_beta));
            },
        }
    );

    #
    # Bessel functions
    #

    $commands->register(
        j0 => {
            category => 'numeric',
            help => 'Bessel function of the first kind, order 0: J0(x)',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { POSIX::j0($_[0]) });
            },
        }
    );

    $commands->register(
        j1 => {
            category => 'numeric',
            help => 'Bessel function of the first kind, order 1: J1(x)',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric($calc, sub { POSIX::j1($_[0]) });
            },
        }
    );

    $commands->register(
        jn => {
            category => 'numeric',
            help => 'Bessel function of the first kind: x n jn computes Jn(x)',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2,'jn');
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
            category => 'numeric',
            help => 'Bessel function of the second kind, order 0: Y0(x)',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'y0');
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
            category => 'numeric',
            help => 'Bessel function of the second kind, order 1: Y1(x)',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'y1');
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
            category => 'numeric',
            help => 'Bessel function of the second kind: x n yn computes Yn(x)',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2,'yn');
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
            category => 'numeric',
            help    => 'pops two numbers and pushes their modulus',
            code    => sub {
                my ($calc) = @_;
    
                return unless $calc->stack->require_depth(2,'modulo');
    
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


sub _is_nonpositive_integer {
    my ($value) = @_;
    return $value <= 0 && $value == int($value);
}

1;
