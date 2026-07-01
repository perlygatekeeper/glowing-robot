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
            help     => 'push a random integer; randint N gives 1..N, randint A B gives A..B',
            code     => sub {
                my ($calc, $arg_str, $args) = @_;
                my ($low, $high);
                if ($args && @$args == 1) {
                    $low  = 1;
                    $high = $args->[0];
                }
                elsif ($args && @$args >= 2) {
                    ($low, $high) = @$args[0, 1];
                }
                else {
                    warn "usage: randint <high> or randint <low> <high>\n";
                    return;
                }
                unless ($low =~ /^-?\d+$/ && $high =~ /^-?\d+$/) {
                    warn "randint requires integer arguments\n";
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
        seed => {
            category => 'random',
            help     => 'seed the random number generator',
            code     => sub {
                my ($calc, $arg_str, $args) = @_;
                my $seed = $args && @$args ? $args->[0] : time;
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
