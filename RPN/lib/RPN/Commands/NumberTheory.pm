package RPN::Commands::NumberTheory;

use v5.34;
use strict;
use warnings;

sub register_commands {
    my ($commands) = @_;
    #
    # Number theory
    #

    $commands->register(
        isprime => {
            type => 'number_theory',
            help => 'push 1 if top value is prime, otherwise 0',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $n = $calc->stack->pop;
                $calc->stack->push(_nt_is_prime($n) ? 1 : 0);
            },
        }
    );

    $commands->register(
        nextprime => {
            aliases => ['prime'],
            type    => 'number_theory',
            help    => 'replace top value with next prime greater than it',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $n = $calc->stack->pop;
                $calc->stack->push(_nt_next_prime($n));
            },
        }
    );

    $commands->register(
        prevprime => {
            type => 'number_theory',
            help => 'replace top value with previous prime less than it',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $n = $calc->stack->pop;
                my $p = _nt_prev_prime($n);
                unless (defined $p) {
                    warn "no previous prime exists\n";
                    return;
                }
                $calc->stack->push($p);
            },
        }
    );

    $commands->register(
        factor => {
            aliases => ['factors'],
            type    => 'number_theory',
            help    => 'replace top value with its prime factors',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $n = $calc->stack->pop;
                my @factors = _nt_factor($n);
                $calc->stack->push($_) for @factors;
            },
        }
    );

    $commands->register(
        divisors => {
            type => 'number_theory',
            help => 'replace top value with its positive divisors',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $n = $calc->stack->pop;
                my @divisors = _nt_divisors($n);
                $calc->stack->push($_) for @divisors;
            },
        }
    );

    $commands->register(
        gcd => {
            type => 'number_theory',
            help => 'replace top two values with their greatest common divisor',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my $b = $calc->stack->pop;
                my $a = $calc->stack->pop;
                $calc->stack->push(_nt_gcd($a, $b));
            },
        }
    );

    $commands->register(
        lcm => {
            type => 'number_theory',
            help => 'replace top two values with their least common multiple',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my $b = $calc->stack->pop;
                my $a = $calc->stack->pop;
                my $gcd = _nt_gcd($a, $b);
                $calc->stack->push($gcd ? abs(int($a * $b)) / $gcd : 0);
            },
        }
    );

    $commands->register(
    totient => {
        aliases => ['eulerphi'],
            type => 'number_theory',
            help => 'replace top value with Euler totient phi(n)',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $n = $calc->stack->pop;
                $calc->stack->push(_nt_phi($n));
            },
        }
    );

    #
    # Number theory extended
    #

    $commands->register(
        primorial => {
            type => 'number_theory',
            help => 'product of all primes <= n: n primorial',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $n = $calc->stack->pop;
                unless (!ref($n) && $calc->isanumber($n) && int($n) == $n && $n >= 0) {
                    $calc->stack->push($n);
                    warn "primorial requires a non-negative integer\n";
                    return;
                }
                $calc->stack->push(_nt_primorial($n));
            },
        }
    );

    $commands->register(
        mobius => {
            type => 'number_theory',
            help => 'Möbius function: n mobius',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $n = $calc->stack->pop;
                unless (!ref($n) && $calc->isanumber($n) && int($n) == $n && $n >= 1) {
                    $calc->stack->push($n);
                    warn "mobius requires a positive integer\n";
                    return;
                }
                $calc->stack->push(_nt_mobius($n));
            },
        }
    );

    $commands->register(
        mertens => {
            type => 'number_theory',
            help => 'Mertens function: n mertens',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $n = $calc->stack->pop;
                unless (!ref($n) && $calc->isanumber($n) && int($n) == $n && $n >= 1) {
                    $calc->stack->push($n);
                    warn "mertens requires a positive integer\n";
                    return;
                }
                $calc->stack->push(_nt_mertens($n));
            },
        }
    );

    return;
}

sub _nt_is_prime {
    my ($n) = @_;
    return 0 unless defined $n && $n =~ /^-?\d+$/;
    return 0 if $n < 2;
    return 1 if $n == 2;
    return 0 if $n % 2 == 0;
    for (my $d = 3; $d * $d <= $n; $d += 2) {
        return 0 if $n % $d == 0;
    }
    return 1;
}

sub _nt_next_prime {
    my ($n) = @_;
    $n = int($n) + 1;
    $n = 2 if $n < 2;
    $n++ until _nt_is_prime($n);
    return $n;
}

sub _nt_prev_prime {
    my ($n) = @_;
    $n = int($n) - 1;
    return undef if $n < 2;
    $n-- until _nt_is_prime($n) || $n < 2;
    return $n >= 2 ? $n : undef;
}

sub _nt_gcd {
    my ($a, $b) = @_;
    $a = abs(int($a));
    $b = abs(int($b));
    while ($b) {
        ($a, $b) = ($b, $a % $b);
    }
    return $a;
}

sub _nt_factor {
    my ($n) = @_;
    $n = abs(int($n));
    return () if $n < 2;
    my @factors;
    while ($n % 2 == 0) {
        push @factors, 2;
        $n /= 2;
    }
    for (my $d = 3; $d * $d <= $n; $d += 2) {
        while ($n % $d == 0) {
            push @factors, $d;
            $n /= $d;
        }
    }
    push @factors, $n if $n > 1;
    return @factors;
}

sub _nt_divisors {
    my ($n) = @_;
    $n = abs(int($n));
    return () if $n < 1;
    my @divisors;
    for my $d (1 .. int(sqrt($n))) {
        if ($n % $d == 0) {
            push @divisors, $d;
            push @divisors, $n / $d unless $d == $n / $d;
        }
    }
    return sort { $a <=> $b } @divisors;
}

sub _nt_phi {
    my ($n) = @_;
    $n = abs(int($n));
    return 0 if $n == 0;
    my $result = $n;
    my %seen;
    for my $p (_nt_factor($n)) {
        next if $seen{$p}++;
        $result -= $result / $p;
    }
    return $result;
}

sub _nt_primorial {
    my ($n) = @_;
    my $result = 1;
    for my $candidate (2 .. $n) {
        $result *= $candidate
            if _nt_is_prime($candidate);
    }
    return $result;
}

sub _nt_mobius {
    my ($n) = @_;
    return 1 if $n == 1;
    my %factors;
    my $d = 2;
    while ($d * $d <= $n) {
        while ($n % $d == 0) {
            $factors{$d}++;
            return 0 if $factors{$d} > 1;
            $n /= $d;
        }
        $d++;
    }
    $factors{$n}++ if $n > 1;
    my $k = scalar keys %factors;
    return ($k % 2) ? -1 : 1;
}

sub _nt_mertens {
    my ($n) = @_;

    my $sum = 0;

    for my $k (1 .. $n) {
        $sum += _nt_mobius($k);
    }

    return $sum;
}

1;
