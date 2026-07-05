package RPN::Commands::Combinatorics;

use v5.34;
use strict;
use warnings;

sub register_commands {
    my ($commands) = @_;

    #
    # Combinatorics / Probability
    #

    $commands->register(
        factorial => {
            aliases => ['fact'],
            category => 'combinatorics',
            help    => 'factorial: n factorial',
            code    => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(1,'factorial');

                my $n = $calc->stack->pop;

                unless (_comb_is_nonnegative_integer($calc, $n)) {
                    $calc->stack->push($n);
                    warn "factorial requires a non-negative integer\n";
                    return;
                }

                $calc->stack->push(_comb_factorial($n));
            },
        }
    );

    $commands->register(
        permutations => {
            aliases => ['npr', 'perm', 'permute'],
            category => 'combinatorics',
            help    => 'number of permutations (n permute r): n r permutations',
            code    => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(2,'permutations');

                my $r = $calc->stack->pop;
                my $n = $calc->stack->pop;

                unless (_comb_is_nonnegative_integer($calc, $n)
                    && _comb_is_nonnegative_integer($calc, $r)) {
                    $calc->stack->push($n);
                    $calc->stack->push($r);
                    warn "permutations requires non-negative integer operands\n";
                    return;
                }

                $calc->stack->push(_comb_npr($n, $r));
            },
        }
    );

    $commands->register(
        combinations => {
            aliases => ['ncr', 'comb', 'binom'],
            category => 'combinatorics',
            help    => 'number of combinations (n choose r): n r combinations',
            code    => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(2,'combinations');

                my $r = $calc->stack->pop;
                my $n = $calc->stack->pop;

                unless (_comb_is_nonnegative_integer($calc, $n)
                    && _comb_is_nonnegative_integer($calc, $r)) {
                    $calc->stack->push($n);
                    $calc->stack->push($r);
                    warn "combinations requires non-negative integer operands\n";
                    return;
                }

                $calc->stack->push(_comb_ncr($n, $r));
            },
        }
    );

    $commands->register(
        binompdf => {
            category => 'combinatorics',
            help => 'binomial probability: n k p binompdf',
            code => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(3,'binompdf');

                my $p = $calc->stack->pop;
                my $k = $calc->stack->pop;
                my $n = $calc->stack->pop;

                unless (_comb_is_nonnegative_integer($calc, $n)
                    && _comb_is_nonnegative_integer($calc, $k)
                    && !ref($p)
                    && $calc->isanumber($p)
                    && $p >= 0
                    && $p <= 1) {
                    $calc->stack->push($n);
                    $calc->stack->push($k);
                    $calc->stack->push($p);
                    warn "binompdf requires n k p where n and k are non-negative integers and 0 <= p <= 1\n";
                    return;
                }

                $calc->stack->push(_comb_binompdf($n, $k, $p));
            },
        }
    );

    $commands->register(
        binomcdf => {
            category => 'combinatorics',
            help => 'cumulative binomial probability: n k p binomcdf',
            code => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(3,'binomcdf');

                my $p = $calc->stack->pop;
                my $k = $calc->stack->pop;
                my $n = $calc->stack->pop;

                unless (_comb_is_nonnegative_integer($calc, $n)
                    && _comb_is_nonnegative_integer($calc, $k)
                    && !ref($p)
                    && $calc->isanumber($p)
                    && $p >= 0
                    && $p <= 1) {
                    $calc->stack->push($n);
                    $calc->stack->push($k);
                    $calc->stack->push($p);
                    warn "binomcdf requires n k p where n and k are non-negative integers and 0 <= p <= 1\n";
                    return;
                }

                $calc->stack->push(_comb_binomcdf($n, $k, $p));
            },
        }
    );

    return;
}

sub _comb_is_nonnegative_integer {
    my ($calc, $n) = @_;
    return !ref($n)
        && $calc->isanumber($n)
        && int($n) == $n
        && $n >= 0;
}

sub _comb_factorial {
    my ($n) = @_;
    my $result = 1;
    for my $i (2 .. $n) {
        $result *= $i;
    }
    return $result;
}

sub _comb_npr {
    my ($n, $r) = @_;
    return 0 if $r > $n;
    my $result = 1;
    for my $i (($n - $r + 1) .. $n) {
        $result *= $i;
    }
    return $result;
}

sub _comb_ncr {
    my ($n, $r) = @_;
    return 0 if $r > $n;
    $r = $n - $r if $r > $n - $r;
    my $result = 1;
    for my $i (1 .. $r) {
        $result = $result * ($n - $r + $i) / $i;
    }
    return $result;
}

sub _comb_binompdf {
    my ($n, $k, $p) = @_;
    return _comb_ncr($n, $k) * ($p ** $k) * ((1 - $p) ** ($n - $k));
}

sub _comb_binomcdf {
    my ($n, $k, $p) = @_;
    my $sum = 0;
    for my $i (0 .. $k) {
        $sum += _comb_binompdf($n, $i, $p);
    }
    return $sum;
}

1;
