package RPN::Commands::Random;

use v5.34;
use strict;
use warnings;

sub register_commands {
    my ($commands) = @_;

    $commands->register(
        rand => {
            category => 'random',
            help     => 'push a random floating point number in the range [0,1)',
            code     => sub {
                my ($calc) = @_;
                $calc->stack->push(rand());
            },
        }
    );

    $commands->register(
        randint => {
            category => 'random',
            help     => 'pop MIN and MAX and push a random integer in that inclusive range',
            code     => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);

                my ($high, $low) = $calc->stack->pop2;
                unless (!ref($low) && !ref($high)
                     && $low =~ /^-?\d+$/ && $high =~ /^-?\d+$/) {
                    $calc->stack->push($low);
                    $calc->stack->push($high);
                    warn "randint requires integer MIN and MAX on the stack\n";
                    return;
                }

                if ($high < $low) {
                    ($low, $high) = ($high, $low);
                }

                my $value = $low + int(rand($high - $low + 1));
                $calc->stack->push($value);
            },
        }
    );

    $commands->register(
        dieroll => {
            category => 'random',
            help     => 'pop SIDES and push a random integer from 1 to SIDES',
            code     => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);

                my $sides = $calc->stack->pop;
                unless (!ref($sides) && $sides =~ /^\d+$/ && $sides >= 1) {
                    $calc->stack->push($sides);
                    warn "dieroll requires a positive integer SIDES value on the stack\n";
                    return;
                }

                my $value = 1 + int(rand($sides));
                $calc->stack->push($value);
            },
        }
    );

    $commands->register(
        seed => {
            category => 'random',
            help     => 'pop SEED and seed the random number generator',
            code     => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $seed = $calc->stack->pop;
                unless (defined $seed && !ref($seed) && $seed =~ /^-?\d+(?:\.\d+)?$/) {
                    $calc->stack->push($seed) if defined $seed;
                    warn "seed requires a numeric seed on the stack
";
                    return;
                }
                srand($seed);
                $calc->stack->push($seed);
            },
        }
    );

    $commands->register(
        choose => {
            category => 'random',
            help     => 'copy a random stack element to the top',
            code     => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my @values = $calc->stack->values;
                my $index = int(rand(@values));
                $calc->stack->push($values[$index]);
            },
        }
    );

    return;
}

1;
