package RPN::Commands::Statistics;

use v5.34;
use strict;
use warnings;

sub register_commands {
    my ($commands) = @_;

    #
    # Whole-stack / statistics
    #

    $commands->register(
        count => {
            category => 'statistics',
            help => 'pushes the current stack depth onto the stack',
            code => sub {
                my ($calc) = @_;
                $calc->stack->push($calc->stack->depth);
            },
        }
    );

    $commands->register(
        sum => {
            category => 'statistics',
            help => 'replaces the entire stack with the sum of its values',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'sum');
                my @values = $calc->stack->values;
                my $sum = 0;
                foreach my $value (@values) {
                    $sum += $value;
                }
                $calc->stack->clear;
                $calc->stack->push($sum);
            },
        }
    );

    $commands->register(
        average => {
            aliases => ['avg'],
            category => 'statistics',
            help    => 'replaces the entire stack with the average of its values',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'average');
                my @values = $calc->stack->values;
                my $sum = 0;
                foreach my $value (@values) {
                    $sum += $value;
                }
                $calc->stack->clear;
                $calc->stack->push($sum / @values);
            },
        }
    );

    $commands->register(
        minimum => {
            aliases => ['min'],
            category => 'statistics',
            help    => 'replaces the entire stack with the minimum value',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'minimus');
                my @values = $calc->stack->values;
                my $min = $values[0];
                foreach my $value (@values) {
                    $min = $value if $value < $min;
                }
                $calc->stack->clear;
                $calc->stack->push($min);
            },
        }
    );

    $commands->register(
        maximum => {
            aliases => ['max'],
            category => 'statistics',
            help    => 'replaces the entire stack with the maximum value',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'maximum');
                my @values = $calc->stack->values;
                my $max = $values[0];
                foreach my $value (@values) {
                    $max = $value if $value > $max;
                }
                $calc->stack->clear;
                $calc->stack->push($max);
            },
        }
    );

    #
    # Enhanced Statistics
    #

    $commands->register(
        product => {
            category => 'statistics',
            help => 'replaces the entire stack with the product of its values',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'product');
                my @values = $calc->stack->values;
                my $product = 1;
                $product *= $_ for @values;
                $calc->stack->clear;
                $calc->stack->push($product);
            },
        }
    );

    $commands->register(
        spread => {
            aliases => ['span'],
            category => 'statistics',
            help    => 'replaces the entire stack with maximum minus minimum',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'spread');
                my @values = $calc->stack->values;
                my ($min, $max) = ($values[0], $values[0]);
                foreach my $value (@values) {
                    $min = $value if $value < $min;
                    $max = $value if $value > $max;
                }
                $calc->stack->clear;
                $calc->stack->push($max - $min);
            },
        }
    );

    $commands->register(
        median => {
            category => 'statistics',
            help => 'replaces the entire stack with the median value',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'median');
                my @values = sort { $a <=> $b } $calc->stack->values;
                my $n = @values;
                my $median;
                if ($n % 2) {
                    $median = $values[int($n / 2)];
                }
                else {
                    $median = ($values[$n / 2 - 1] + $values[$n / 2]) / 2;
                }
                $calc->stack->clear;
                $calc->stack->push($median);
            },
        }
    );

    $commands->register(
        variance => {
            aliases => ['var'],
            category => 'statistics',
            help    => 'replaces the entire stack with the population variance',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'variance');
                my @values = $calc->stack->values;
                my $n = @values;
                my $sum = 0;
                $sum += $_ for @values;
                my $mean = $sum / $n;
                my $ss = 0;
                $ss += ($_ - $mean) ** 2 for @values;
                $calc->stack->clear;
                $calc->stack->push($ss / $n);
            },
        }
    );

    $commands->register(
        stddev => {
            aliases => ['stdev'],
            category => 'statistics',
            help    => 'replaces the entire stack with the population standard deviation',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'stddev');
                my @values = $calc->stack->values;
                my $n = @values;
                my $sum = 0;
                $sum += $_ for @values;
                my $mean = $sum / $n;
                my $ss = 0;
                $ss += ($_ - $mean) ** 2 for @values;
                $calc->stack->clear;
                $calc->stack->push(sqrt($ss / $n));
            },
        }
    );



}

1;
