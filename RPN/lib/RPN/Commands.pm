package RPN::Commands;

use v5.34;
use strict;
use warnings;

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
        boolean    => 'true or false',
        constant   => 'named constants',
        conversion => 'unit conversions',
        debug      => 'developer functions',
        flow       => 'flow control',
        numeric    => 'arithmetic functions',
        stack      => 'stack manipulation',
        string     => 'string operations',
        trig       => 'trigonometric functions',
        utility    => 'help, display, quit',
    };

    #
    # Arithmetic
    #

    $self->register(
        add => {
            aliases => ['+'],
            type    => 'numeric',
            help    => 'pops two numbers and pushes their sum',
            code    => sub {
                my ($calc) = @_;
                $self->_binary_numeric($calc, sub { $_[0] + $_[1] });
            },
        }
    );

    $self->register(
        subtract => {
            aliases => ['-'],
            type    => 'numeric',
            help    => 'pops two numbers and pushes their difference',
            code    => sub {
                my ($calc) = @_;
                $self->_binary_numeric($calc, sub { $_[0] - $_[1] });
            },
        }
    );

    $self->register(
        multiply => {
            aliases => ['*'],
            type    => 'numeric',
            help    => 'pops two numbers and pushes their product',
            code    => sub {
                my ($calc) = @_;
                $self->_binary_numeric($calc, sub { $_[0] * $_[1] });
            },
        }
    );

    $self->register(
        divide => {
            aliases => ['/'],
            type    => 'numeric',
            help    => 'pops two numbers and pushes their quotient',
            code    => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(2);

                my $divisor = $calc->stack->peek;

                if ($divisor == 0) {
                    warn "divide by zero\n";
                    return;
                }

                my ($a, $b) = $calc->stack->pop2;
                $calc->stack->push($b / $a);
            },
        }
    );

    $self->register(
        modulo => {
            aliases => ['%'],
            type    => 'numeric',
            help    => 'pops two numbers and pushes their modulus',
            code    => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(2);

                my $divisor = $calc->stack->peek;

                if ($divisor == 0) {
                    warn "modulo by zero\n";
                    return;
                }

                my ($a, $b) = $calc->stack->pop2;
                $calc->stack->push($b % $a);
            },
        }
    );

    $self->register(
        exponentiate => {
            aliases => ['**', '^'],
            type    => 'numeric',
            help    => 'raises the second stack value to the power of the top stack value',
            code    => sub {
                my ($calc) = @_;
                $self->_binary_numeric($calc, sub { $_[0] ** $_[1] });
            },
        }
    );

    $self->register(
        square => {
            type => 'numeric',
            help => 'squares the number on top of the stack',
            code => sub {
                my ($calc) = @_;
                $self->_unary_numeric($calc, sub { $_[0] * $_[0] });
            },
        }
    );

    $self->register(
        cube => {
            type => 'numeric',
            help => 'cubes the number on top of the stack',
            code => sub {
                my ($calc) = @_;
                $self->_unary_numeric($calc, sub { $_[0] * $_[0] * $_[0] });
            },
        }
    );

    $self->register(
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

    $self->register(
        negate => {
            type => 'numeric',
            help => 'negates the number on top of the stack',
            code => sub {
                my ($calc) = @_;
                $self->_unary_numeric($calc, sub { -$_[0] });
            },
        }
    );

    $self->register(
        increment => {
            type => 'numeric',
            help => 'increments the number on top of the stack',
            code => sub {
                my ($calc) = @_;
                $self->_unary_numeric($calc, sub { $_[0] + 1 });
            },
        }
    );

    $self->register(
        decrement => {
            type => 'numeric',
            help => 'decrements the number on top of the stack',
            code => sub {
                my ($calc) = @_;
                $self->_unary_numeric($calc, sub { $_[0] - 1 });
            },
        }
    );

    #
    # Stack
    #

    $self->register(
        pop => {
            type => 'stack',
            help => 'pops the top value from the stack',
            code => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(1);

                $calc->stack->pop;
            },
        }
    );

    $self->register(
        duplicate => {
            aliases => ['dup'],
            type    => 'stack',
            help    => 'duplicates the number on top of the stack',
            code    => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(1);

                $calc->stack->push($calc->stack->peek);
            },
        }
    );

    $self->register(
        exchange => {
            aliases => ['x'],
            type    => 'stack',
            help    => 'swaps the top two values on the stack',
            code    => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(2);

                my ($a, $b) = $calc->stack->pop2;
                $calc->stack->push($a, $b);
            },
        }
    );

    $self->register(
        clear => {
            aliases => ['clr'],
            type    => 'stack',
            help    => 'empties the stack',
            code    => sub {
                my ($calc) = @_;
                $calc->stack->clear;
            },
        }
    );

    $self->register(
        depth => {
            type => 'stack',
            help => 'pushes the current stack depth onto the stack',
            code => sub {
                my ($calc) = @_;
                $calc->stack->push($calc->stack->depth);
            },
        }
    );

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

                my $value   = $calc->stack->peek;
                my $radians = $calc->angle_to_radians($value);
                my $cosine  = cos($radians);

                if (abs($cosine) < 1e-12) {
                    warn "tangent undefined at $value\n";
                    return;
                }

                $calc->stack->pop;
                $calc->stack->push(sin($radians) / $cosine);
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

                print $calc->stack->peek . "\n";
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
                    printf "%3d:\t%s\n", $i, $values[$i];
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
        quit => {
            aliases => [qw(exit bye ZZ)],
            type    => 'utility',
            help    => 'exits the program',
            code    => sub {
                exit 0;
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

    $self->register(
        stack => {
            type => 'stack',
            help => 'switches stacks, lists stacks, or reports current stack',
            code => sub {
                my ($calc, $arg_str, $args) = @_;
                my $stack = $calc->stack;
                if ($args && @$args) {
                    my $name = $args->[0];
                    if ($name eq '.' || $name eq '?' || $name eq '*') {
                        printf "%-18s %s\n", "Stack", "Depth";
                        printf "%-18s %s\n", "-" x 18, "-" x 8;
                        foreach my $stack_name ($stack->stack_names) {
                            printf "%-18s %d\n",
                                $stack_name,
                                $stack->depth_of($stack_name);
                        }
                        return;
                    }
                    $stack->switch($name);
                    printf "Switched to stack '%s' (%d deep)\n",
                        $stack->current_name,
                        $stack->depth;
                    return;
                }
                printf "Stack '%s' is in use and has %d elements.\n",
                    $stack->current_name,
                    $stack->depth;
            },
        }
    );

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

    $calc->stack->push($code->($a));

    return;
}

sub _binary_numeric {
    my ($self, $calc, $code) = @_;

    return unless $calc->stack->require_depth(2);

    my ($a, $b) = $calc->stack->pop2;

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

1;







