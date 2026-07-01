package RPN::Commands::Trig;

use v5.34;
use strict;
use warnings;

sub register_commands {
    my ($commands) = @_;

    $commands->register(
        radians => {
            category => 'trig',
            help => 'sets angle mode to radians',
            code => sub {
                my ($calc) = @_;
                $calc->angle_mode('radians');
            },
        }
    );

    $commands->register(
        degrees => {
            category => 'trig',
            help => 'sets angle mode to degrees',
            code => sub {
                my ($calc) = @_;
                $calc->angle_mode('degrees');
            },
        }
    );

    $commands->register(
        sine => {
            aliases => ['sin'],
            category => 'trig',
            help    => 'replaces the number on top of the stack with its sine',
            code    => sub {
                my ($calc) = @_;

                $commands->_unary_numeric(
                    $calc,
                    sub { sin($calc->angle_to_radians($_[0])) }
                );
            },
        }
    );

    $commands->register(
        cosine => {
            aliases => ['cos'],
            category => 'trig',
            help    => 'replaces the number on top of the stack with its cosine',
            code    => sub {
                my ($calc) = @_;
                $commands->_unary_numeric(
                    $calc,
                    sub { cos($calc->angle_to_radians($_[0])) }
                );
            },
        }
    );

    $commands->register(
        tangent => {
            aliases => ['tan'],
            category => 'trig',
            help    => 'replaces the number on top of the stack with its tangent',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $value = $calc->stack->pop;
                unless (!ref($value) && $calc->isanumber($value)) {
                    $calc->stack->push($value);
                    warn "tangent requires a numeric operand\n";
                    return;
                }
                my $radians = $calc->angle_to_radians($value);
                my $cosine  = cos($radians);
                if ($calc->nearly_zero($cosine)) {
                    $calc->stack->push($value);
                    warn "tangent undefined at $value\n";
                    return;
                }
                $calc->stack->push(sin($radians) / $cosine);
            },
        }
    );

    $commands->register(
        sinh => {
            category => 'trig',
            help => 'hyperbolic sine',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric(
                    $calc,
                    sub { (exp($_[0]) - exp(-$_[0])) / 2 }
                );
            },
        }
    );

    $commands->register(
        cosh => {
            category => 'trig',
            help => 'hyperbolic cosine',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric(
                    $calc,
                    sub { (exp($_[0]) + exp(-$_[0])) / 2 }
                );
            },
        }
    );

    $commands->register(
        tanh => {
            category => 'trig',
            help => 'hyperbolic tangent',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric(
                    $calc,
                    sub {
                        my $e2x = exp(2 * $_[0]);
                        ($e2x - 1) / ($e2x + 1);
                    }
                );
            },
        }
    );

    $commands->register(
        asinh => {
            category => 'trig',
            help => 'inverse hyperbolic sine',
            code => sub {
                my ($calc) = @_;
                $commands->_unary_numeric(
                    $calc,
                    sub { log($_[0] + sqrt($_[0] * $_[0] + 1)) }
                );
            },
        }
    );

    $commands->register(
        acosh => {
            category => 'trig',
            help => 'inverse hyperbolic cosine',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $value = $calc->stack->pop;
                unless (!ref($value) && $calc->isanumber($value)) {
                    $calc->stack->push($value);
                    warn "acosh requires a numeric operand\n";
                    return;
                }
                if ($value < 1) {
                    $calc->stack->push($value);
                    warn "acosh requires a value greater than or equal to 1\n";
                    return;
                }
                $calc->stack->push(log($value + sqrt($value * $value - 1)));
            },
        }
    );

    $commands->register(
        atanh => {
            category => 'trig',
            help => 'inverse hyperbolic tangent',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $value = $calc->stack->pop;
                unless (!ref($value) && $calc->isanumber($value)) {
                    $calc->stack->push($value);
                    warn "atanh requires a numeric operand\n";
                    return;
                }
                if ($value <= -1 || $value >= 1) {
                    $calc->stack->push($value);
                    warn "atanh requires a value greater than -1 and less than 1\n";
                    return;
                }
                $calc->stack->push(0.5 * log((1 + $value) / (1 - $value)));
            },
        }
    );

    return;
}

1;
