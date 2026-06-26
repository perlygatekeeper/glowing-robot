package RPN::Commands;

use v5.34;
use strict;
use warnings;

use RPN::Commands::Matrix;
use RPN::Commands::Vector;
use RPN::Commands::Combinatorics;
use RPN::Commands::NumberTheory;
use RPN::Commands::Financial;
use RPN::Commands::Strings;
use RPN::Commands::Tutorials;
use RPN::Commands::Numeric;
use RPN::Commands::Stack;
use POSIX ();
use Text::Abbrev qw(abbrev);

sub new {
    my ($class, $calc) = @_;

    my $self = {
        calc     => $calc,
        commands => {},
        abbrevs  => {},
        types    => {},
    };

    bless $self, $class;

    $self->_initialize();

    return $self;
}

sub _initialize {
    my ($self) = @_;

    $self->{types} = {
        boolean       => 'true or false',
        constant      => 'named constants',
        conversion    => 'unit conversions',
        debug         => 'developer functions',
        flow          => 'flow control',
        numeric       => 'arithmetic functions',
        stack         => 'stack manipulation',
        string        => 'string operations',
        trig          => 'trigonometric functions',
        utility       => 'help, display, quit',
        statistics    => 'whole-stack and statistical functions',
        random        => 'random number functions',
        datetime      => 'date and time functions',
        sequence      => 'sequence generation and list operations',
        variable      => 'named variables and storage',
        financial     => 'financial compound interest calculations',
        number_theory => 'prime, factor, gcd, lcm, divisor functions',
        function      => 'user-defined functions',
        io            => 'file input and output',
        vector        => 'vector mathematics',
        matrix        => 'matrix mathematics',
        combinatorics => 'factorials, combinations, permutations, probability',
        documentation => 'display tutorials',
    };

    RPN::Commands::Matrix::register_commands($self);
    RPN::Commands::Vector::register_commands($self);
    RPN::Commands::Combinatorics::register_commands($self);
    RPN::Commands::NumberTheory::register_commands($self);
    RPN::Commands::Financial::register_commands($self);
    RPN::Commands::Strings::register_commands($self);
    RPN::Commands::Tutorials::register_commands($self);
    RPN::Commands::Numeric::register_commands($self);
    RPN::Commands::Stack::register_commands($self);

    #
    # Boolean for both Numerical and String Entries
    #

    foreach my $op (
        '<',
        '>',
        '<=',
        '>=',
        '==',
        '!=',
        '<=>',
    ) {
             $self->register(
                 $op => {
                     type => 'boolean',
                     help => "numeric comparison $op",
                     code => sub {
                         my ($calc) = @_;
                         return unless $calc->stack->require_depth(2);
                         my ($a, $b) = $calc->stack->pop2;
                         my $result =
                             eval "\$b $op \$a";
                         $calc->stack->push(
                             ($op eq '<=>')
                                 ? $result
                                 : ($result ? 1 : 0)
                         );
                     },
                 }
             );
         }

    foreach my $op (
            qw(
                lt
                gt
                le
                ge
                eq
                ne
                cmp
            )
        ) {
                $self->register(
                    $op => {
                        type => 'boolean',
                        help => "string comparison $op",
                        code => sub {
                            my ($calc) = @_;
                            return unless $calc->stack->require_depth(2);
                            my ($a, $b) = $calc->stack->pop2;
                            my $result =
                                eval "\$b $op \$a";
                            $calc->stack->push(
                                ($op eq 'cmp')
                                    ? $result
                                    : ($result ? 1 : 0)
                            );
                        },
                    }
                );
            }

    #
    # Trig
    #

    $self->register(
        radians => {
            type => 'trig',
            help => 'sets angle mode to radians',
            code => sub {
                my ($calc) = @_;
                $calc->angle_mode('radians');
            },
        }
    );

    $self->register(
        degrees => {
            type => 'trig',
            help => 'sets angle mode to degrees',
            code => sub {
                my ($calc) = @_;
                $calc->angle_mode('degrees');
            },
        }
    );

    $self->register(
        sine => {
            aliases => ['sin'],
            type    => 'trig',
            help    => 'replaces the number on top of the stack with its sine',
            code    => sub {
                my ($calc) = @_;

                $self->_unary_numeric(
                    $calc,
                    sub { sin($calc->angle_to_radians($_[0])) }
                );
            },
        }
    );

    $self->register(
        cosine => {
            aliases => ['cos'],
            type    => 'trig',
            help    => 'replaces the number on top of the stack with its cosine',
            code    => sub {
                my ($calc) = @_;
                $self->_unary_numeric(
                    $calc,
                    sub { cos($calc->angle_to_radians($_[0])) }
                );
            },
        }
    );

    $self->register(
        tangent => {
            aliases => ['tan'],
            type    => 'trig',
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



    $self->register(
        sinh => {
            type => 'trig',
            help => 'hyperbolic sine',
            code => sub {
                my ($calc) = @_;
                $self->_unary_numeric(
                    $calc,
                    sub { (exp($_[0]) - exp(-$_[0])) / 2 }
                );
            },
        }
    );

    $self->register(
        cosh => {
            type => 'trig',
            help => 'hyperbolic cosine',
            code => sub {
                my ($calc) = @_;
                $self->_unary_numeric(
                    $calc,
                    sub { (exp($_[0]) + exp(-$_[0])) / 2 }
                );
            },
        }
    );

    $self->register(
        tanh => {
            type => 'trig',
            help => 'hyperbolic tangent',
            code => sub {
                my ($calc) = @_;
                $self->_unary_numeric(
                    $calc,
                    sub {
                        my $e2x = exp(2 * $_[0]);
                        ($e2x - 1) / ($e2x + 1);
                    }
                );
            },
        }
    );

    $self->register(
        asinh => {
            type => 'trig',
            help => 'inverse hyperbolic sine',
            code => sub {
                my ($calc) = @_;
                $self->_unary_numeric(
                    $calc,
                    sub { log($_[0] + sqrt($_[0] * $_[0] + 1)) }
                );
            },
        }
    );

    $self->register(
        acosh => {
            type => 'trig',
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

    $self->register(
        atanh => {
            type => 'trig',
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

    #
    # Display / utility
    #

    $self->register(
        peek => {
            aliases => ['.'],
            type    => 'utility',
            help    => 'prints top value on stack without popping it',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                print $calc->format_value($calc->stack->peek) . "\n";
            },
        }
    );

    $self->register(
        print => {
            type => 'utility',
            help => 'pops and prints the top value on the stack',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                print $calc->stack->pop . "\n";
            },
        }
    );

    $self->register(
        peekall => {
            aliases => [':'],
            type    => 'utility',
            help    => 'prints the entire stack without changing it',
            code    => sub {
                my ($calc) = @_;
                my @values = $calc->stack->values;
                for (my $i = 0; $i < @values; $i++) {
                    printf "%3d:\t%s\n", $i, $calc->format_value($values[$i]);
                }
            },
        }
    );

    $self->register(
        peekf => {
            type => 'utility',
            help => 'prints the top value using a printf format without popping it',
            code => sub {
                my ($calc, $arg_str) = @_;
                return unless $calc->stack->require_depth(1);
                my $format = $self->_clean_format($arg_str);
                printf "$format\n", $calc->stack->peek;
            },
        }
    );

    $self->register(
        printf => {
            type => 'utility',
            help => 'pops and prints the top value using a printf format',
            code => sub {
                my ($calc, $arg_str) = @_;
                return unless $calc->stack->require_depth(1);
                my $format = $self->_clean_format($arg_str);
                printf "$format\n", $calc->stack->pop;
            },
        }
    );

    $self->register(
        decimal => {
            aliases => ['dec'],
            type    => 'utility',
            help    => 'prints the top value as a decimal integer without popping it',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                printf "%d\n", $calc->stack->peek;
            },
        }
    );

    $self->register(
        hexadecimal => {
            aliases => ['hex'],
            type    => 'utility',
            help    => 'prints the top value in hexadecimal without popping it',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                printf "0x%x\n", $calc->stack->peek;
            },
        }
    );

    $self->register(
        octal => {
            aliases => ['oct'],
            type    => 'utility',
            help    => 'prints the top value in octal without popping it',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                printf "0%o\n", $calc->stack->peek;
            },
        }
    );

    $self->register(
        binary => {
            aliases => ['bin'],
            type    => 'utility',
            help    => 'prints the top value in binary without popping it',
            code    => sub {
                my ($calc, $arg_str) = @_;
                return unless $calc->stack->require_depth(1);
                my $width = '';
                if (defined $arg_str && $arg_str =~ /^\s*(\d+)\s*$/) {
                    $width = $1;
                }
                if (length $width) {
                    printf "%0${width}b\n", $calc->stack->peek;
                }
                else {
                    printf "%b\n", $calc->stack->peek;
                }
            },
        }
    );

    $self->register(
        history => {
            aliases => ['hist'],
            type    => 'utility',
            help    => 'prints command history',
            code    => sub {
                my ($calc) = @_;
                my @history = $calc->history;
                for (my $i = 0; $i < @history; $i++) {
                    next unless defined $history[$i] && length $history[$i];
                    printf "%3d: %s\n", $i, $history[$i];
                }
            },
        }
    );


    $self->register(
        save => {
            type => 'utility',
            help => 'saves history and stacks',
            code => sub {
                my ($calc) = @_;
                $calc->save_history;
                $calc->save_stacks;
                $calc->save_constants;
                print "Saved history, stacks, and constants.\n";
            },
        }
    );

    $self->register(
        quit => {
            aliases => [qw(exit bye ZZ)],
            type    => 'utility',
            help    => 'exits the program',
            code => sub {
                 my ($calc) = @_;
                 $calc->{running} = 0;
             },
         }
     );

    $self->register(
        noop => {
            type => 'utility',
            help => 'no operation',
            code => sub {
                return;
            },
        }
    );

    $self->register(
        version => {
            aliases => ['ver'],
            type    => 'utility',
            help    => 'prints calculator version',
            code    => sub {
                my ($calc) = @_;
                print "RPN version " . $calc->version . "\n";
            },
        }
    );

    $self->register(
        aliases => {
            type => 'utility',
            help => 'lists commands that have aliases',
            code => sub {
                my ($calc) = @_;
                my $commands = $self->commands;
                printf "%-18s %s\n", "Command", "Aliases";
                printf "%-18s %s\n", "-" x 18, "-" x 30;
                foreach my $command (sort keys %$commands) {
                    my $aliases = $commands->{$command}{aliases}
                        or next;
                    printf "%-18s %s\n", $command, join(", ", @$aliases);
                }
            },
        }
    );

    $self->register(
        abbreviations => {
            aliases => ['abbrevs'],
            type    => 'utility',
            help    => 'lists shortest usable abbreviations for commands',
            code    => sub {
                my ($calc) = @_;
                my $commands = $self->commands;
                my $abbrevs  = $self->abbrevs;
                printf "%-18s %s\n", "Command", "Shortest";
                printf "%-18s %s\n", "-" x 18, "-" x 20;
                foreach my $command (sort keys %$commands) {
                    my @matches =
                        sort { length($a) <=> length($b) || $a cmp $b }
                        grep {
                            $abbrevs->{$_} eq $command
                                && index($command, $_) == 0
                        }
                        keys %$abbrevs;
                    my $short = $matches[0] || $command;
                    my $display = $command;
                    if (length($short) < length($command)) {
                        substr($display, length($short), 0) = '-';
                    }
                    printf "%-18s %s\n", $command, $display;
                }
            },
        }
    );

    #
    # Conversions
    #

    $self->register(
        degrees_radians => {
            aliases => ['dtor'],
            type    => 'conversion',
            help    => 'convert degrees to radians',
            code    => sub {
                my ($calc) = @_;
                $self->_conversion($calc, sub { $_[0] * atan2(1, 1) / 45 });
            },
        }
    );

    $self->register(
        radians_degrees => {
            aliases => ['rtod'],
            type    => 'conversion',
            help    => 'convert radians to degrees',
            code    => sub {
                my ($calc) = @_;
                $self->_conversion($calc, sub { $_[0] / atan2(1, 1) * 45 });
            },
        }
    );

    $self->register(
        fahrenheit_celsius => {
            aliases => ['ftoc'],
            type    => 'conversion',
            help    => 'convert Fahrenheit to Celsius',
            code    => sub {
                my ($calc) = @_;
                $self->_conversion($calc, sub { ($_[0] - 32) / 1.8 });
            },
        }
    );

    $self->register(
        celsius_fahrenheit => {
            aliases => ['ctof'],
            type    => 'conversion',
            help    => 'convert Celsius to Fahrenheit',
            code    => sub {
                my ($calc) = @_;
                $self->_conversion($calc, sub { ($_[0] * 1.8) + 32 });
            },
        }
    );

    $self->register(
        kilometer_mile => {
            aliases => ['ktom'],
            type    => 'conversion',
            help    => 'convert kilometers to miles',
            code    => sub {
                my ($calc) = @_;
                $self->_conversion($calc, sub { $_[0] / 1.609 });
            },
        }
    );

    $self->register(
        mile_kilometer => {
            aliases => ['mtok'],
            type    => 'conversion',
            help    => 'convert miles to kilometers',
            code    => sub {
                my ($calc) = @_;
                $self->_conversion($calc, sub { $_[0] * 1.609 });
            },
        }
    );

    $self->register(
        centimeter_inch => {
            aliases => ['ctoi'],
            type    => 'conversion',
            help    => 'convert centimeters to inches',
            code    => sub {
                my ($calc) = @_;
                $self->_conversion($calc, sub { $_[0] / 2.54 });
            },
        }
    );

    $self->register(
        inch_centimeter => {
            aliases => ['itoc'],
            type    => 'conversion',
            help    => 'convert inches to centimeters',
            code    => sub {
                my ($calc) = @_;
                $self->_conversion($calc, sub { $_[0] * 2.54 });
            },
        }
    );

    $self->register(
        gram_ounce => {
            aliases => ['gtoo'],
            type    => 'conversion',
            help    => 'convert grams to ounces',
            code    => sub {
                my ($calc) = @_;
                $self->_conversion($calc, sub { $_[0] / 28.3495 });
            },
        }
    );

    $self->register(
        ounce_gram => {
            aliases => ['otog'],
            type    => 'conversion',
            help    => 'convert ounces to grams',
            code    => sub {
                my ($calc) = @_;
                $self->_conversion($calc, sub { $_[0] * 28.3495 });
            },
        }
    );

    $self->register(
        kilogram_pound => {
            aliases => ['ktop'],
            type    => 'conversion',
            help    => 'convert kilograms to pounds',
            code    => sub {
                my ($calc) = @_;
                $self->_conversion($calc, sub { $_[0] * 2.20458553791875 });
            },
        }
    );

    $self->register(
        pound_kilogram => {
            aliases => ['ptok'],
            type    => 'conversion',
            help    => 'convert pounds to kilograms',
            code    => sub {
                my ($calc) = @_;
                $self->_conversion($calc, sub { $_[0] / 2.20458553791875 });
            },
        }
    );

    $self->register(
        liter_quart => {
            aliases => ['ltoq'],
            type    => 'conversion',
            help    => 'convert liters to quarts',
            code    => sub {
                my ($calc) = @_;
                $self->_conversion($calc, sub { $_[0] * 1.05669 });
            },
        }
    );

    $self->register(
        quart_liter => {
            aliases => ['qtol'],
            type    => 'conversion',
            help    => 'convert quarts to liters',
            code    => sub {
                my ($calc) = @_;
                $self->_conversion($calc, sub { $_[0] / 1.05669 });
            },
        }
    );

    $self->register(
        types => {
            type => 'utility',
            help => 'list command types',
            code => sub {
                my ($calc) = @_;
                $self->print_types;
            },
        }
    );

    $self->register(
        help => {
            aliases => ['?'],
            type    => 'utility',
            help    => 'prints help for all commands, one command, or one type',
            code    => sub {
                my ($calc, $arg_str, $args) = @_;
                $self->print_help($args);
            },
        }
    );

    #
    # Constants
    #

    $self->register(
        constants => {
            aliases => ['const'],
            type    => 'constant',
            help    => 'list, push, or define constants',
            code    => sub {
                my ($calc, $arg_str, $args) = @_;

                #
                # const
                #   list constants
                #

                unless ($args && @$args) {
                    printf "%-12s %-12s %s\n", "Name", "Source", "Value";
                    printf "%-12s %-12s %s\n", "-" x 12, "-" x 12, "-" x 30;

                    foreach my $name ($calc->constants->names) {
                        my $source = $calc->constants->is_builtin($name)
                            ? 'builtin'
                            : 'user';

                        printf "%-12s %-12s %s\n",
                            $name,
                            $source,
                            $calc->constants->get($name);
                    }

                    return;
                }

                #
                # const name
                #   push constant
                #

                if (@$args == 1) {
                    my $name = $args->[0];

                    unless ($calc->constants->exists($name)) {
                        warn "No constant '$name' was found. ";
                        return;
                    }

                    $calc->stack->push($calc->constants->get($name));
                    return;
                }

                #
                # const name value
                #   define user constant
                #

                my ($name, $value) = @$args[0, 1];

                $calc->constants->set($name, $value);

                return;
            },
        }
    );

    $self->register(
        delconst => {
            type => 'constant',
            help => 'delete a user-defined constant',
            code => sub {
                my ($calc, $arg_str, $args) = @_;

                unless ($args && @$args) {
                    warn "usage: delconst <name> ";
                    return;
                }

                $calc->constants->delete($args->[0]);

                return;
            },
        }
    );

    $self->register(
        loadconst => {
            type => 'constant',
            help => 'load user constants from a file: loadconst [file]',
            code => sub {
                my ($calc, $arg_str, $args) = @_;
                my $file = $args && @$args ? $args->[0] : undef;
                $calc->load_constants($file);
                print "Loaded constants.\n";
                return;
            },
        }
    );

    $self->register(
        saveconst => {
            type => 'constant',
            help => 'save user constants: saveconst [file]',
            code => sub {
                my ($calc, $arg_str, $args) = @_;
                my $file = $args && @$args ? $args->[0] : undef;
                $calc->save_constants($file);
                print "Saved constants.\n";
                return;
            },
        }
    );

    #
    # Whole-stack / statistics
    #

    $self->register(
        count => {
            type => 'statistics',
            help => 'pushes the current stack depth onto the stack',
            code => sub {
                my ($calc) = @_;
                $calc->stack->push($calc->stack->depth);
            },
        }
    );

    $self->register(
        sum => {
            type => 'statistics',
            help => 'replaces the entire stack with the sum of its values',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
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

    $self->register(
        average => {
            aliases => ['avg'],
            type    => 'statistics',
            help    => 'replaces the entire stack with the average of its values',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
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

    $self->register(
        minimum => {
            aliases => ['min'],
            type    => 'statistics',
            help    => 'replaces the entire stack with the minimum value',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
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

    $self->register(
        maximum => {
            aliases => ['max'],
            type    => 'statistics',
            help    => 'replaces the entire stack with the maximum value',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
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

    $self->register(
        product => {
            type => 'statistics',
            help => 'replaces the entire stack with the product of its values',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my @values = $calc->stack->values;
                my $product = 1;
                $product *= $_ for @values;
                $calc->stack->clear;
                $calc->stack->push($product);
            },
        }
    );

    $self->register(
        range => {
            type => 'statistics',
            help => 'replaces the entire stack with maximum minus minimum',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
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

    $self->register(
        median => {
            type => 'statistics',
            help => 'replaces the entire stack with the median value',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
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

    $self->register(
        variance => {
            aliases => ['var'],
            type    => 'statistics',
            help    => 'replaces the entire stack with the population variance',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
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

    $self->register(
        stddev => {
            aliases => ['stdev'],
            type    => 'statistics',
            help    => 'replaces the entire stack with the population standard deviation',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
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


    #
    # Flow / programmability
    #

    $self->register(
        execute => {
            aliases => ['exec'],
            type    => 'flow',
            help    => 'executes the string on top of the stack as an RPN command',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $input = $calc->stack->pop;
                unless ($calc->commands->execute($calc, $input)) {
                    warn "unknown input type '$input'\n";
                }
            },
        }
    );

    $self->register(
        if => {
            aliases => ['ifthen'],
            type    => 'flow',
            help    => 'pops boolean and command; executes command if boolean is true',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my $test  = $calc->stack->pop;
                my $input = $calc->stack->pop;
                if ($test) {
                    unless ($calc->commands->execute($calc, $input)) {
                        warn "unknown input type '$input'\n";
                    }
                }
            },
        }
    );

    $self->register(
        ifelse => {
            type => 'flow',
            help => 'pops boolean and two commands; executes first command if true, second if false',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(3);
                my $test        = $calc->stack->pop;
                my $true_input  = $calc->stack->pop;
                my $false_input = $calc->stack->pop;
                my $input = $test ? $true_input : $false_input;
                unless ($calc->commands->execute($calc, $input)) {
                    warn "unknown input type '$input'\n";
                }
            },
        }
    );

    #
    # File I/O
    #

    $self->register(
        readnums => {
            type => 'io',
            help => 'read numeric tokens from a file and push them onto the stack',
            code => sub {
                my ($calc, $arg_str) = @_;
                my $file = _clean_filename($arg_str);
                return unless $file;
                open my $fh, '<', $file
                    or warn "Cannot read '$file': $!\n" and return;
                while (my $line = <$fh>) {
                    chomp $line;
                    $line =~ s/#.*$//;
                    next unless $line =~ /\S/;
                    $calc->process_input($line);
                }
                close $fh;
            },
        }
    );

    $self->register(
        readcsv => {
            type => 'io',
            help => 'read numeric values from a CSV file and push them onto the stack',
            code => sub {
                my ($calc, $arg_str) = @_;
                my $file = _clean_filename($arg_str);
                return unless $file;
                open my $fh, '<', $file
                    or warn "Cannot read '$file': $!\n" and return;
                while (my $line = <$fh>) {
                    chomp $line;
                    foreach my $field (split /,/, $line) {
                        $field =~ s/^\s+//;
                        $field =~ s/\s+$//;
                        next unless $calc->isanumber($field);
                        $calc->push_number($field);
                    }
                }
                close $fh;
            },
        }
    );

    $self->register(
        readcolumn => {
            type => 'io',
            help => 'read one numeric column from a CSV file by column number or header name',
            code => sub {
                my ($calc, $arg_str, $args) = @_;
                unless ($args && @$args >= 2) {
                    warn "usage: readcolumn <file> <column>\n";
                    return;
                }
                my ($file, $column) = @$args[0, 1];
                open my $fh, '<', $file
                    or warn "Cannot read '$file': $!\n" and return;
                my $header = <$fh>;
                return unless defined $header;
                chomp $header;
                my @headers = map {
                    s/^\s+//;
                    s/\s+$//;
                    $_;
                } split /,/, $header;
                my $index;
                if ($column =~ /^\d+$/) {
                    $index = $column;
                } else {
                    for my $i (0 .. $#headers) {
                        if ($headers[$i] eq $column) {
                            $index = $i;
                            last;
                        }
                    }
                }
                unless (defined $index) {
                    warn "No such column '$column'\n";
                    close $fh;
                    return;
                }
                while (my $line = <$fh>) {
                    chomp $line;
                    my @fields = split /,/, $line;
                    next unless defined $fields[$index];
                    my $value = $fields[$index];
                    $value =~ s/^\s+//;
                    $value =~ s/\s+$//;
                    next unless $calc->isanumber($value);
                    $calc->push_number($value);
                }
                close $fh;
            },
        }
    );

    $self->register(
        writecsv => {
            type => 'io',
            help => 'write current stack to a CSV file',
            code => sub {
                my ($calc, $arg_str) = @_;
                my $file = _clean_filename($arg_str);
                return unless $file;
                _write_stack_csv($calc, $file, 0);
            },
        }
    );

    $self->register(
        appendcsv => {
            type => 'io',
            help => 'append current stack to a CSV file',
            code => sub {
                my ($calc, $arg_str) = @_;
                my $file = _clean_filename($arg_str);
                return unless $file;
                _write_stack_csv($calc, $file, 1);
            },
        }
    );

    #
    # Random numbers
    #

    $self->register(
        rand => {
            type => 'random',
            help => 'push a random floating point number in the range [0,1)',
            code => sub {
                my ($calc) = @_;
                $calc->stack->push(rand());
            },
        }
    );

    $self->register(
        randint => {
            type => 'random',
            help => 'push a random integer; randint N gives 1..N, randint A B gives A..B',
            code => sub {
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

    $self->register(
        seed => {
            type => 'random',
            help => 'seed the random number generator',
            code => sub {
                my ($calc, $arg_str, $args) = @_;
                my $seed = $args && @$args ? $args->[0] : time;
                srand($seed);
                $calc->stack->push($seed);
            },
        }
    );

    $self->register(
        choose => {
            type => 'random',
            help => 'copy a random stack element to the top',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my @values = $calc->stack->values;
                my $index = int(rand(@values));
                $calc->stack->push($values[$index]);
            },
        }
    );

    #
    # Date / time
    #

    $self->register(
        now => {
            type => 'datetime',
            help => 'push current epoch time',
            code => sub {
                my ($calc) = @_;
                $calc->stack->push(time);
            },
        }
    );

    $self->register(
        today => {
            type => 'datetime',
            help => 'push current date as YYYY-MM-DD',
            code => sub {
                my ($calc) = @_;
                my @t = localtime;
                $calc->stack->push(sprintf "%04d-%02d-%02d", $t[5] + 1900, $t[4] + 1, $t[3]);
            },
        }
    );

    $self->register(
        time => {
            type => 'datetime',
            help => 'push current time as HH:MM:SS',
            code => sub {
                my ($calc) = @_;
                my @t = localtime;
                $calc->stack->push(sprintf "%02d:%02d:%02d", $t[2], $t[1], $t[0]);
            },
        }
    );

    $self->register(
        datetime => {
            type => 'datetime',
            help => 'push current date and time as YYYY-MM-DD HH:MM:SS',
            code => sub {
                my ($calc) = @_;
                my @t = localtime;
                $calc->stack->push(
                    sprintf "%04d-%02d-%02d %02d:%02d:%02d",
                        $t[5] + 1900,
                        $t[4] + 1,
                        $t[3],
                        $t[2],
                        $t[1],
                        $t[0]
                );
            },
        }
    );

    #
    # Sequence commands
    #

    $self->register(
        sequence => {
            aliases => ['..', 'seq'],
            type    => 'sequence',
            help    => 'generate a sequence from start to stop',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my $stop  = $calc->stack->pop;
                my $start = $calc->stack->pop;
                my @range;
                if ($calc->isanumber($start) && $calc->isanumber($stop)) {
                    if ($start <= $stop) {
                        for (my $x = $start; $x <= $stop; $x++) {
                            push @range, $x;
                        }
                    }
                    else {
                        for (my $x = $start; $x >= $stop; $x--) {
                            push @range, $x;
                        }
                    }
                }
                else {
                    @range = ($start .. $stop);
                }
                foreach my $value (@range) {
                    $calc->stack->push($value);
                }
            },
        }
    );

    $self->register(
        sequenceby => {
            aliases => ['...', 'seqby'],
            type    => 'sequence',
            help    => 'generate a numeric sequence with explicit step',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(3);
                my $step  = $calc->stack->pop;
                my $stop  = $calc->stack->pop;
                my $start = $calc->stack->pop;
                unless (
                    $calc->isanumber($start)
                    && $calc->isanumber($stop)
                    && $calc->isanumber($step)
                ) {
                    warn "sequenceby requires numeric arguments\n";
                    return;
                }
                if ($step == 0) {
                    warn "sequenceby step may not be zero\n";
                    return;
                }
                if ($step > 0) {
                    for (my $x = $start; $x <= $stop; $x += $step) {
                        $calc->stack->push($x);
                    }
                }
                else {
                    for (my $x = $start; $x >= $stop; $x += $step) {
                        $calc->stack->push($x);
                    }
                }
            },
        }
    );
    #
    # Variables
    #

    $self->register(
        store => {
            aliases => ['sto'],
            type    => 'variable',
            help    => 'store the top stack value in a variable',
            code    => sub {
                my ($calc, $arg_str, $args) = @_;

                unless ($args && @$args) {
                    warn "usage: store <name>\n";
                    return;
                }

                my $name = $args->[0];

                return unless $calc->stack->require_depth(1);

                unless ($name =~ /^[A-Za-z_]\w*$/) {
                    warn "Invalid variable name '$name'\n";
                    return;
                }

                if ($self->is_registered_command_name($name)) {
                    warn "Cannot store variable '$name': name already used by a command\n";
                    return;
                }

                if ($calc->constants->exists($name)) {
                    warn "Cannot store variable '$name': name already used by a constant\n";
                    return;
                }

                my $value = $calc->stack->peek;

                $calc->variables->set($name, $value);
            },
        }
    );

    $self->register(
        recall => {
            aliases => ['rcl'],
            type    => 'variable',
            help    => 'recall a variable and push it onto the stack',
            code    => sub {
                my ($calc, $arg_str, $args) = @_;

                unless ($args && @$args) {
                    warn "usage: recall <name>\n";
                    return;
                }

                my $name = $args->[0];

                unless ($calc->variables->exists($name)) {
                    warn "No such variable '$name'\n";
                    return;
                }

                $calc->stack->push($calc->variables->get($name));
            },
        }
    );

    $self->register(
        variables => {
            aliases => ['vars'],
            type    => 'variable',
            help    => 'list stored variables',
            code    => sub {
                my ($calc) = @_;

                printf "%-18s %s\n", "Name", "Value";
                printf "%-18s %s\n", "-" x 18, "-" x 30;

                foreach my $name ($calc->variables->names) {
                    printf "%-18s %s\n",
                        $name,
                        $calc->variables->get($name);
                }
            },
        }
    );

    $self->register(
        delvar => {
            type => 'variable',
            help => 'delete a stored variable',
            code => sub {
                my ($calc, $arg_str, $args) = @_;

                unless ($args && @$args) {
                    warn "usage: delvar <name>\n";
                    return;
                }

                my $name = $args->[0];

                unless ($calc->variables->exists($name)) {
                    warn "No such variable '$name'\n";
                    return;
                }

                $calc->variables->delete($name);
            },
        }
    );

    $self->register(
        savevars => {
            type => 'variable',
            help => 'save variables to disk: savevars [file]',
            code => sub {
                my ($calc, $arg_str, $args) = @_;
                my $file = $args && @$args ? $args->[0] : undef;
                $calc->save_variables($file);
                print "Saved variables.\n";
            },
        }
    );

    $self->register(
        loadvars => {
            type => 'variable',
            help => 'load variables from disk: loadvars [file]',
            code => sub {
                my ($calc, $arg_str, $args) = @_;
                my $file = $args && @$args ? $args->[0] : undef;
                $calc->load_variables($file);
                print "Loaded variables.\n";
            },
        }
    );

    #
    # User-defined Functions
    #

    $self->register(
        define => {
            aliases => ['def'],
            type => 'function',
            help => 'define a user function: define <name> <body>',
            code => sub {
                my ($calc, $arg_str, $args) = @_;
                unless ($args && @$args >= 2) {
                    warn "usage: def <name> <body>\n";
                    return;
                }
                my $name = shift @$args;
                my $body = join ' ', @$args;
                unless ($name =~ /^[A-Za-z_]\w*$/) {
                    warn "Invalid function name '$name'\n";
                    return;
                }
                if ($calc->constants->exists($name)) {
                    warn "Cannot define function '$name': name already used by a constant\n";
                    return;
                }
                if ($self->is_registered_command_name($name)) {
                    warn "Cannot define function '$name': name already used by a command\n";
                    return;
                }
                if ($calc->variables->exists($name)) {
                    warn "Cannot define function '$name': name already used by a variable\n";
                    return;
                }
                $body =~ s/^(['"])(.*)\1$/$2/;
                $calc->functions->set($name, $body);
            },
        }
    );

    $self->register(
        undef => {
            type => 'function',
            help => 'delete a user function',
            code => sub {
                my ($calc, $arg_str, $args) = @_;
                unless ($args && @$args) {
                    warn "usage: undef <name>\n";
                    return;
                }
                my $name = $args->[0];
                unless ($calc->functions->exists($name)) {
                    warn "No such function '$name'\n";
                    return;
                }
                $calc->functions->delete($name);
            },
        }
    );

    $self->register(
        functions => {
            aliases => ['funcs'],
            type    => 'function',
            help    => 'list user-defined functions',
            code    => sub {
                my ($calc) = @_;
                my @names = $calc->functions->names;
                unless (@names) {
                    print "No user functions are currently defined.\n";
                    print "\n";
                    print "Define one with:\n";
                    print "\n";
                    print "    define double 2 *\n";
                    print "\n";
                    print "Then use\n";
                    print "\n";
                    print "    double\n";
                    print "\n";
                    print "to use it.\n";
                    print "\n";
                    print "See:\n";
                    print "\n";
                    print "    tutorial functions\n";
                    print "\n";
                    print "for more information.\n";
                    return;
                }
                printf "%-18s %s\n", "Name", "Body";
                printf "%-18s %s\n", "-" x 18, "-" x 40;
                foreach my $name (@names) {
                    printf "%-18s %s\n",
                        $name,
                        $calc->functions->get($name);
                }
            },
        }
    );

    $self->register(
        savefuncs => {
            type => 'function',
            help => 'save user-defined functions to disk: savefuncs [file]',
            code => sub {
                my ($calc, $arg_str, $args) = @_;
                my $file = $args && @$args ? $args->[0] : undef;
                $calc->save_functions($file);
                print "Saved functions.\n";
            },
        }
    );

    $self->register(
        loadfuncs => {
            type => 'function',
            help => 'load user-defined functions from disk: loadfuncs [file]',
            code => sub {
                my ($calc, $arg_str, $args) = @_;
                my $file = $args && @$args ? $args->[0] : undef;
                $calc->load_functions($file);
                print "Loaded functions.\n";
            },
        }
    );

    $self->register(
        showfunc => {
            type => 'function',
            help => 'show the definition of a function',
            code => sub {
                my ($calc, $arg_str, $args) = @_;

                my $name = $args->[0];

                unless (defined $name) {
                    warn "Usage: showfunc function_name\n";
                    return;
                }

                unless ($calc->functions->exists($name)) {
                    warn "Unknown function '$name'\n";
                    return;
                }

                print "$name = "
                    . $calc->functions->get($name)
                    . "\n";

                return;
            },
        },
    );

    #
    # END OF COMMANDS
    #

    $self->_rebuild_abbrevs();

    return;
}

sub _binary_boolean {
    my ($self, $calc, $code) = @_;
    return unless $calc->stack->require_depth(2);
    my ($a, $b) = $calc->stack->pop2;
    $calc->stack->push(
        $code->($b, $a)
    );
    return;
}

sub register {
    my ($self, $name, $definition) = @_;
    $self->{commands}{$name} = $definition;
    return;
}

sub _rebuild_abbrevs {
    my ($self) = @_;
    my %abbrevs;
    abbrev(\%abbrevs, sort keys %{ $self->{commands} });
    foreach my $name (keys %{ $self->{commands} }) {
        $abbrevs{$name} = $name;

        if (my $aliases = $self->{commands}{$name}{aliases}) {
            foreach my $alias (@$aliases) {
                $abbrevs{$alias} = $name;
            }
        }
    }
    $self->{abbrevs} = \%abbrevs;
    return;
}

sub command {
    my ($self, $name) = @_;
    my $real = $self->{abbrevs}{$name}
        or return;
    return $self->{commands}{$real};
}

sub registered_command {
    my ($self, $name) = @_;
    return $self->{commands}{$name}
        if exists $self->{commands}{$name};
    foreach my $command_name (keys %{ $self->{commands} }) {
        my $command = $self->{commands}{$command_name};
        next unless $command->{aliases};
        foreach my $alias (@{ $command->{aliases} }) {
            return $command if $alias eq $name;
        }
    }
    return;
}

sub is_registered_command_name {
    my ($self, $name) = @_;
    return defined $self->registered_command($name);
}

sub execute {
    my ($self, $calc, $input) = @_;
    my ($command, $args) = $input =~ /^\s*(\S+)\s*(.*)$/;
    return unless defined $command;
    my @arguments = length($args || '')
        ? split /\s+/, $args
        : ();
    my $entry = $self->command($command)
        or return 0;
    my $code = $entry->{code}
        or return 0;
    $code->($calc, $args, \@arguments);
    return 1;
}

sub execute_registered {
    my ($self, $calc, $input) = @_;
    my ($command, $args) = $input =~ /^\s*(\S+)\s*(.*)$/;
    return unless defined $command;
    my @arguments = length($args || '')
        ? split /\s+/, $args
        : ();
    my $entry = $self->registered_command($command)
        or return 0;
    my $code = $entry->{code}
        or return 0;
    $code->($calc, $args, \@arguments);
    return 1;
}

sub commands {
    my ($self) = @_;
    return $self->{commands};
}

sub abbrevs {
    my ($self) = @_;
    return $self->{abbrevs};
}

sub types {
    my ($self) = @_;
    return $self->{types};
}

sub _unary_numeric {
    my ($self, $calc, $code) = @_;
    return unless $calc->stack->require_depth(1);
    my $a = $calc->stack->pop;
    unless (!ref($a) && $calc->isanumber($a)) {
        $calc->stack->push($a);
        warn "numeric command requires a number\n";
        return;
    }
    $calc->stack->push($code->($a));
    return;
}

sub _binary_numeric {
    my ($self, $calc, $code) = @_;
    return unless $calc->stack->require_depth(2);
    my ($a, $b) = $calc->stack->pop2;
    unless (!ref($a) && $calc->isanumber($a)
         && !ref($b) && $calc->isanumber($b)) {
        $calc->stack->push($b);
        $calc->stack->push($a);
        warn "numeric command requires numeric operands\n";
        return;
    }
    $calc->stack->push($code->($b, $a));
    return;
}

sub _clean_format {
    my ($self, $arg_str) = @_;
    my $format = defined($arg_str) && length($arg_str)
        ? $arg_str
        : '%s';
    $format =~ s/^\s+//;
    $format =~ s/\s+$//;
    $format =~ s/^(['"])(.*)\1$/$2/;
    return $format;
}

sub _conversion {
    my ($self, $calc, $code) = @_;
    return unless $calc->stack->require_depth(1);
    my $value = $calc->stack->pop;
    $calc->stack->push($code->($value));
    return;
}

sub print_help {
    my ($self, $args) = @_;
    if ($args && @$args) {
        if ($args->[0] eq 'types') {
             return $self->print_types;
        }

        if ($args->[0] eq 'type') {
            my $type = $args->[1];
            unless (defined $type && length $type) {
                warn "usage: help type <type>\n";
                return;
            }
            return $self->_print_help_by_type($type);
        }

        if ($self->{calc}->functions->exists($args->[0])) {
            return $self->_print_help_for_function($args->[0]);
        }
        return $self->_print_help_for_command($args->[0]);
    }
    return $self->_print_help_all;
}

sub _print_help_all {
    my ($self) = @_;
    $self->_print_help_header;
    foreach my $command (
        sort {
            $self->{commands}{$a}{type} cmp $self->{commands}{$b}{type}
                ||
            $a cmp $b
        }
        keys %{ $self->{commands} }
    ) {
        $self->_print_help_line($command);
    }
    return;
}

sub print_types {
    my ($self) = @_;
    printf "%-18s %s\n", "Type", "Description";
    printf "%-18s %s\n", "-" x 18, "-" x 40;
    foreach my $type (sort keys %{ $self->{types} }) {
        printf "%-18s %s\n",
            $type,
            $self->{types}{$type};
    }
    return;
}

sub _print_help_by_type {
    my ($self, $type) = @_;

    my @matches = grep {
        ($self->{commands}{$_}{type} // '') eq $type
    } sort keys %{ $self->{commands} };

    unless (@matches) {
        print "No commands found for type '$type'.\n";
        print "\n";
        print "Use:\n";
        print "\n";
        print "    help types\n";
        print "\n";
        print "to see available command types.\n";
        return;
    }

    $self->_print_help_header;

    for my $command (@matches) {
        $self->_print_help_line($command);
    }

    return;
}

sub _print_help_for_function {
    my ($self, $name) = @_;
    my $calc = $self->{calc};
    unless (defined $name && length $name) {
        warn "usage: help <function>\n";
        return;
    }
    unless ($calc->functions->exists($name)) {
        warn "No such function '$name'\n";
        return;
    }
    print "User-defined function\n\n";
    print "$name = " . $calc->functions->get($name) . "\n";
    return;
}

sub _print_help_for_command {
    my ($self, $query) = @_;
    my $command = $self->{abbrevs}{$query};
    unless ($command) {
        warn "No command '$query' was found.\n";
        return;
    }
    $self->_print_help_header;
    $self->_print_help_line($command);
    return;
}

sub _print_help_header {
    my ($self) = @_;
    printf "%-18s %-12s %s\n", "Command", "Type", "Help";
    printf "%-18s %-12s %s\n", "-" x 18, "-" x 12, "-" x 40;
    return;
}

sub _print_help_line {
    my ($self, $command) = @_;
    my $entry   = $self->{commands}{$command};
    my $type    = $entry->{type} || '';
    my $help    = $entry->{help} || '';
    my $aliases = $entry->{aliases};
    if ($aliases && @$aliases) {
        $help .= " aliases: " . join(", ", @$aliases);
    }
    printf "%-18s %-12s %s\n", $command, $type, $help;
    return;
}

sub _clean_filename {
    my ($arg_str) = @_;
    my $file = defined($arg_str) ? $arg_str : '';
    $file =~ s/^\s+//;
    $file =~ s/\s+$//;
    $file =~ s/^(['"])(.*)\1$/$2/;
    unless (length $file) {
        warn "filename required\n";
        return;
    }
    return $file;
}

sub _write_stack_csv {
    my ($calc, $file, $append) = @_;
    my $mode = $append ? '>>' : '>';
    my $needs_header = !$append || !-s $file;
    open my $fh, $mode, $file
        or warn "Cannot write '$file': $!\n" and return;
    print $fh "index,value\n" if $needs_header;
    my @values = $calc->stack->values;
    my $start = 0;
    if ($append && -s $file) {
        open my $read_fh, '<', $file;
        my $lines = 0;
        $lines++ while <$read_fh>;
        close $read_fh;
        $start = $lines > 0 ? $lines - 1 : 0;
    }
    for my $i (0 .. $#values) {
        my $value = $values[$i];
        $value =~ s/"/""/g;
        print $fh ($start + $i) . ",\"$value\"\n";
    }
    close $fh;
    return 1;
}

1;
