package RPN::Commands::Conversion;

use v5.34;
use strict;
use warnings;

sub register_commands {
    my ($commands) = @_;

    $commands->register(
        degrees_radians => {
            aliases  => ['dtor'],
            category => 'conversion',
            help     => 'convert degrees to radians',
            code     => sub {
                my ($calc) = @_;
                _conversion($calc, sub { $_[0] * atan2(1, 1) / 45 });
            },
        }
    );

    $commands->register(
        radians_degrees => {
            aliases  => ['rtod'],
            category => 'conversion',
            help     => 'convert radians to degrees',
            code     => sub {
                my ($calc) = @_;
                _conversion($calc, sub { $_[0] / atan2(1, 1) * 45 });
            },
        }
    );

    $commands->register(
        fahrenheit_celsius => {
            aliases  => ['ftoc'],
            category => 'conversion',
            help     => 'convert Fahrenheit to Celsius',
            code     => sub {
                my ($calc) = @_;
                _conversion($calc, sub { ($_[0] - 32) / 1.8 });
            },
        }
    );

    $commands->register(
        celsius_fahrenheit => {
            aliases  => ['ctof'],
            category => 'conversion',
            help     => 'convert Celsius to Fahrenheit',
            code     => sub {
                my ($calc) = @_;
                _conversion($calc, sub { ($_[0] * 1.8) + 32 });
            },
        }
    );

    $commands->register(
        kilometer_mile => {
            aliases  => ['ktom'],
            category => 'conversion',
            help     => 'convert kilometers to miles',
            code     => sub {
                my ($calc) = @_;
                _conversion($calc, sub { $_[0] / 1.609 });
            },
        }
    );

    $commands->register(
        mile_kilometer => {
            aliases  => ['mtok'],
            category => 'conversion',
            help     => 'convert miles to kilometers',
            code     => sub {
                my ($calc) = @_;
                _conversion($calc, sub { $_[0] * 1.609 });
            },
        }
    );

    $commands->register(
        centimeter_inch => {
            aliases  => ['ctoi'],
            category => 'conversion',
            help     => 'convert centimeters to inches',
            code     => sub {
                my ($calc) = @_;
                _conversion($calc, sub { $_[0] / 2.54 });
            },
        }
    );

    $commands->register(
        inch_centimeter => {
            aliases  => ['itoc'],
            category => 'conversion',
            help     => 'convert inches to centimeters',
            code     => sub {
                my ($calc) = @_;
                _conversion($calc, sub { $_[0] * 2.54 });
            },
        }
    );

    $commands->register(
        gram_ounce => {
            aliases  => ['gtoo'],
            category => 'conversion',
            help     => 'convert grams to ounces',
            code     => sub {
                my ($calc) = @_;
                _conversion($calc, sub { $_[0] / 28.3495 });
            },
        }
    );

    $commands->register(
        ounce_gram => {
            aliases  => ['otog'],
            category => 'conversion',
            help     => 'convert ounces to grams',
            code     => sub {
                my ($calc) = @_;
                _conversion($calc, sub { $_[0] * 28.3495 });
            },
        }
    );

    $commands->register(
        kilogram_pound => {
            aliases  => ['ktop'],
            category => 'conversion',
            help     => 'convert kilograms to pounds',
            code     => sub {
                my ($calc) = @_;
                _conversion($calc, sub { $_[0] * 2.20458553791875 });
            },
        }
    );

    $commands->register(
        pound_kilogram => {
            aliases  => ['ptok'],
            category => 'conversion',
            help     => 'convert pounds to kilograms',
            code     => sub {
                my ($calc) = @_;
                _conversion($calc, sub { $_[0] / 2.20458553791875 });
            },
        }
    );

    $commands->register(
        liter_quart => {
            aliases  => ['ltoq'],
            category => 'conversion',
            help     => 'convert liters to quarts',
            code     => sub {
                my ($calc) = @_;
                _conversion($calc, sub { $_[0] * 1.05669 });
            },
        }
    );

    $commands->register(
        quart_liter => {
            aliases  => ['qtol'],
            category => 'conversion',
            help     => 'convert quarts to liters',
            code     => sub {
                my ($calc) = @_;
                _conversion($calc, sub { $_[0] / 1.05669 });
            },
        }
    );

    return;
}

sub _conversion {
    my ($calc, $code) = @_;
    return unless $calc->stack->require_depth(1);
    my $value = $calc->stack->pop;
    $calc->stack->push($code->($value));
    return;
}

1;
