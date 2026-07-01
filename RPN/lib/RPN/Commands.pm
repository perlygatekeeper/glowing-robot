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
use RPN::Commands::CodeBlocks;
use RPN::Commands::Conversion;
use RPN::Commands::Random;
use RPN::Commands::Variables;
use RPN::Commands::Constants;
use RPN::Commands::Functions;
use RPN::Commands::Trig;
use POSIX ();
use File::Basename qw(basename);
use Text::Abbrev qw(abbrev);

sub new {
    my ($class, $calc) = @_;

    my $self = {
        calc     => $calc,
        commands => {},
        abbrevs  => {},
        categories => {},
    };

    bless $self, $class;

    $self->_initialize();

    return $self;
}

sub _initialize {
    my ($self) = @_;

    $self->{categories} = {
        boolean       => 'true or false',
        constant      => 'named constants',
        conversion    => 'unit conversions',
        debug         => 'developer functions',
        discovery     => 'command discovery and documentation',
        display       => 'printing and displaying stack values',
        execution     => 'execution and flow-control primitives',
        flow          => 'flow control',
        numeric       => 'arithmetic functions',
        session       => 'session history, persistence, and exit commands',
        stack         => 'stack manipulation',
        string        => 'string operations',
        trig          => 'trigonometric functions',
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
        codeblock     => 'structured executable code block values',
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
    RPN::Commands::CodeBlocks::register_commands($self);
    RPN::Commands::Conversion::register_commands($self);
    RPN::Commands::Random::register_commands($self);
    RPN::Commands::Variables::register_commands($self);
    RPN::Commands::Constants::register_commands($self);
    RPN::Commands::Functions::register_commands($self);
    RPN::Commands::Trig::register_commands($self);

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
                     category => 'boolean',
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
                        category => 'boolean',
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
    # Display / utility
    #

    $self->register(
        peek => {
            aliases => ['.'],
            category => 'display',
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
            category => 'display',
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
            category => 'display',
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
            category => 'display',
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
            category => 'display',
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
            category => 'display',
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
            category => 'display',
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
            category => 'display',
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
            category => 'display',
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
            category => 'session',
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
            category => 'session',
            help => 'persist all calculator state',
            code => sub {
                my ($calc) = @_;
                $calc->save_all;
                print "Saved persistent calculator state.\n";
            },
        }
    );

    $self->register(
        quit => {
            aliases => [qw(exit bye ZZ)],
            category => 'session',
            help    => 'exits the program',
            code => sub {
                 my ($calc) = @_;
                 $calc->{running} = 0;
             },
         }
     );

    $self->register(
        noop => {
            category => 'execution',
            help => 'no operation',
            code => sub {
                return;
            },
        }
    );

    $self->register(
        call => {
            category => 'execution',
            help => 'execute the top stack value as an executable value',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);

                my $exec = $calc->stack->pop;

                unless ($calc->is_executable($exec)) {
                    $calc->stack->push($exec);
                    warn "call requires an executable value\n";
                    return;
                }

                return $calc->execute($exec);
            },
        }
    );

    $self->register(
        map => {
            category => 'execution',
            help => 'apply an executable value to each stack item: executable map',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);

                my @original = $calc->stack->values;
                my $exec = $calc->stack->pop;

                unless ($calc->is_executable($exec)) {
                    $calc->stack->clear;
                    $calc->stack->push(@original);
                    warn "map requires an executable value
";
                    return;
                }

                my @items = $calc->stack->values;
                my @results;

                $calc->stack->clear;

                foreach my $item (@items) {
                    $calc->stack->push($item);

                    my $before = $calc->stack->depth;
                    $calc->execute($exec);
                    my $after = $calc->stack->depth;

                    if ($after - $before != 0) {
                        $calc->stack->clear;
                        $calc->stack->push(@original);
                        warn "map executable must consume 1 value and produce 1 value
";
                        return;
                    }

                    push @results, $calc->stack->pop;
                }

                $calc->stack->clear;
                $calc->stack->push(@results);
                return;
            },
        }
    );

    $self->register(
        filter => {
            category => 'execution',
            help => 'keep stack items whose executable predicate returns true: executable filter',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);

                my @original = $calc->stack->values;
                my $exec = $calc->stack->pop;

                unless ($calc->is_executable($exec)) {
                    $calc->stack->clear;
                    $calc->stack->push(@original);
                    warn "filter requires an executable value\n";
                    return;
                }

                my @items = $calc->stack->values;
                my @results;

                $calc->stack->clear;

                foreach my $item (@items) {
                    $calc->stack->push($item);

                    my $before = $calc->stack->depth;
                    $calc->execute($exec);
                    my $after = $calc->stack->depth;

                    if ($after - $before != 0) {
                        $calc->stack->clear;
                        $calc->stack->push(@original);
                        warn "filter executable must consume 1 value and produce 1 truth value\n";
                        return;
                    }

                    my $keep = $calc->stack->pop;
                    push @results, $item if $keep;
                }

                $calc->stack->clear;
                $calc->stack->push(@results);
                return;
            },
        }
    );

    $self->register(
        reduce => {
            category => 'execution',
            help => 'combine stack items using an executable value: executable reduce',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);

                my @original = $calc->stack->values;
                my $exec = $calc->stack->pop;

                unless ($calc->is_executable($exec)) {
                    $calc->stack->clear;
                    $calc->stack->push(@original);
                    warn "reduce requires an executable value\n";
                    return;
                }

                my @items = reverse $calc->stack->values;

                if (!@items) {
                    $calc->stack->clear;
                    return;
                }

                my $accumulator = shift @items;

                foreach my $item (@items) {
                    $calc->stack->clear;
                    $calc->stack->push($item, $accumulator);

                    my $before = $calc->stack->depth;
                    $calc->execute($exec);
                    my $after = $calc->stack->depth;

                    if ($after - $before != -1) {
                        $calc->stack->clear;
                        $calc->stack->push(@original);
                        warn "reduce executable must consume 2 values and produce 1 value\n";
                        return;
                    }

                    $accumulator = $calc->stack->pop;
                }

                $calc->stack->clear;
                $calc->stack->push($accumulator);
                return;
            },
        }
    );

    $self->register(
        version => {
            aliases => ['ver'],
            category => 'discovery',
            help    => 'prints calculator version',
            code    => sub {
                my ($calc) = @_;
                print "RPN version " . $calc->version . "\n";
            },
        }
    );

    $self->register(
        aliases => {
            category => 'discovery',
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
            category => 'discovery',
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
        commands => {
            category => 'discovery',
            help => 'lists commands with abbreviations, aliases, categories, and descriptions',
            code => sub {
                my ($calc, $args, $arguments) = @_;
                my $query = @$arguments ? lc($arguments->[0]) : '';

                if (!length $query) {
                    $self->_print_command_catalog();
                }
                elsif ($query eq 'categories') {
                    $self->_print_command_categories();
                }
                elsif ($query eq 'bycategory') {
                    $self->_print_command_catalog_by_category();
                }
                elsif ($query eq 'aliases') {
                    $self->_print_command_catalog(aliases_only => 1);
                }
                elsif ($query eq 'abbreviations' || $query eq 'abbrevs') {
                    $self->_print_command_catalog(abbrevs_only => 1);
                }
                else {
                    my $category = $self->_normalize_category($arguments->[0]);
                    if (exists $self->{categories}{$category}) {
                        $self->_print_command_catalog(category => $category);
                    }
                    else {
                        warn "No such command category '$arguments->[0]'\n";
                    }
                }
            },
        }
    );

    $self->register(
        categories => {
            aliases => ['types'],
            category => 'discovery',
            help    => 'list command categories',
            code    => sub {
                my ($calc) = @_;
                $self->print_categories;
            },
        }
    );

    $self->register(
        help => {
            aliases => ['?'],
            category => 'discovery',
            help    => 'guide users to tutorials, commands, categories, and detailed help',
            code    => sub {
                my ($calc, $arg_str, $args) = @_;
                $self->print_help($args);
            },
        }
    );

    #
    # Whole-stack / statistics
    #

    $self->register(
        count => {
            category => 'statistics',
            help => 'pushes the current stack depth onto the stack',
            code => sub {
                my ($calc) = @_;
                $calc->stack->push($calc->stack->depth);
            },
        }
    );

    $self->register(
        sum => {
            category => 'statistics',
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
            category => 'statistics',
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
            category => 'statistics',
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
            category => 'statistics',
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
            category => 'statistics',
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
        spread => {
            aliases => ['span'],
            category => 'statistics',
            help    => 'replaces the entire stack with maximum minus minimum',
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
            category => 'statistics',
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
            category => 'statistics',
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
            category => 'statistics',
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
            category => 'flow',
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
            category => 'flow',
            help    => 'execute an executable value when a condition is true: condition executable if',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);

                my $top    = $calc->stack->pop;
                my $second = $calc->stack->pop;

                my ($test, $exec);

                if ($calc->is_executable($top)) {
                    # Preferred PostScript-style order:
                    #     condition executable if
                    ($test, $exec) = ($second, $top);
                }
                elsif ($calc->is_executable($second)) {
                    # Compatibility with the older RPN order:
                    #     executable condition if
                    ($test, $exec) = ($top, $second);
                }
                else {
                    $calc->stack->push($second);
                    $calc->stack->push($top);
                    warn "if requires a condition and an executable value\n";
                    return;
                }

                return unless $test;
                return $calc->execute($exec);
            },
        }
    );

    $self->register(
        ifelse => {
            category => 'flow',
            help => 'execute one of two executable values based on a condition: condition true-exec false-exec ifelse',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(3);

                my $top    = $calc->stack->pop;
                my $middle = $calc->stack->pop;
                my $bottom = $calc->stack->pop;

                my ($test, $true_exec, $false_exec);

                if ($calc->is_executable($middle) && $calc->is_executable($top)) {
                    # Preferred PostScript-style order:
                    #     condition true-exec false-exec ifelse
                    ($test, $true_exec, $false_exec) = ($bottom, $middle, $top);
                }
                elsif ($calc->is_executable($bottom) && $calc->is_executable($middle)) {
                    # Compatibility with the older RPN order:
                    #     false-exec true-exec condition ifelse
                    ($test, $true_exec, $false_exec) = ($top, $middle, $bottom);
                }
                else {
                    $calc->stack->push($bottom);
                    $calc->stack->push($middle);
                    $calc->stack->push($top);
                    warn "ifelse requires a condition and two executable values\n";
                    return;
                }

                return $calc->execute($test ? $true_exec : $false_exec);
            },
        }
    );



    $self->register(
        while => {
            category => 'flow',
            help => 'repeat an executable value while a condition executable returns true: condition-exec body-exec while',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);

                my $body_exec = $calc->stack->pop;
                my $cond_exec = $calc->stack->pop;

                unless ($calc->is_executable($cond_exec) && $calc->is_executable($body_exec)) {
                    $calc->stack->push($cond_exec);
                    $calc->stack->push($body_exec);
                    warn "while requires condition and body executable values\n";
                    return;
                }

                while (1) {
                    my ($ok, $condition) = _execute_loop_condition($calc, $cond_exec, 'while');
                    return unless $ok;
                    last unless $condition;

                    $calc->execute($body_exec);
                }

                return;
            },
        }
    );

    $self->register(
        until => {
            category => 'flow',
            help => 'repeat an executable value until a condition executable returns true: condition-exec body-exec until',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);

                my $body_exec = $calc->stack->pop;
                my $cond_exec = $calc->stack->pop;

                unless ($calc->is_executable($cond_exec) && $calc->is_executable($body_exec)) {
                    $calc->stack->push($cond_exec);
                    $calc->stack->push($body_exec);
                    warn "until requires condition and body executable values\n";
                    return;
                }

                while (1) {
                    my ($ok, $condition) = _execute_loop_condition($calc, $cond_exec, 'until');
                    return unless $ok;
                    last if $condition;

                    $calc->execute($body_exec);
                }

                return;
            },
        }
    );

    #
    # File I/O
    #

    $self->register(
        readnums => {
            category => 'io',
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
            category => 'io',
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
            category => 'io',
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
            category => 'io',
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
            category => 'io',
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
    # Date / time
    #

    $self->register(
        now => {
            category => 'datetime',
            help => 'push current epoch time',
            code => sub {
                my ($calc) = @_;
                $calc->stack->push(time);
            },
        }
    );

    $self->register(
        today => {
            category => 'datetime',
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
            category => 'datetime',
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
            category => 'datetime',
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
        range => {
            aliases => ['..', 'seq', 'sequence'],
            category => 'sequence',
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
        rangeby => {
            aliases => ['...', 'seqby', 'sequenceby'],
            category => 'sequence',
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
                    warn "rangeby requires numeric arguments\n";
                    return;
                }
                if ($step == 0) {
                    warn "rangeby step may not be zero\n";
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

    $self->_validate_registration($name, $definition);

    # Backward compatibility: older command modules may still provide
    # a `type` key. Internally, command grouping is now represented as
    # `category`. Do not retain `type` in the registry.
    if (exists $definition->{type}) {
        $definition->{category} //= $definition->{type};
        delete $definition->{type};
    }

    $self->{commands}{$name} = $definition;
    return;
}

sub _validate_registration {
    my ($self, $name, $definition) = @_;

    die "Command registration failed: missing required field 'name'\n"
        unless defined $name && length $name;

    die "Command registration failed for '$name': definition must be a hash reference\n"
        unless ref($definition) eq 'HASH';

    # Backward compatibility for command modules that still pass
    # `type`. The canonical registry field is now `category`.
    my $category = exists $definition->{category}
        ? $definition->{category}
        : $definition->{type};

    die "Command registration failed for '$name': missing required field 'category'\n"
        unless defined $category && length $category;

    die "Command registration failed for '$name': missing required field 'help'\n"
        unless defined $definition->{help} && length $definition->{help};

    die "Command registration failed for '$name': missing required field 'code'\n"
        unless exists $definition->{code};

    die "Command registration failed for '$name': code must be a CODE reference\n"
        unless ref($definition->{code}) eq 'CODE';

    die "Command registration failed for '$name': duplicate command name\n"
        if exists $self->{commands}{$name};

    foreach my $existing_name (keys %{ $self->{commands} }) {
        my $existing_aliases = $self->{commands}{$existing_name}{aliases} || [];
        foreach my $existing_alias (@$existing_aliases) {
            die "Command registration failed for '$name': command name conflicts with alias for '$existing_name'\n"
                if $name eq $existing_alias;
        }
    }

    if (exists $definition->{aliases}) {
        die "Command registration failed for '$name': aliases must be an array reference\n"
            unless ref($definition->{aliases}) eq 'ARRAY';

        my %seen;
        foreach my $alias (@{ $definition->{aliases} }) {
            die "Command registration failed for '$name': alias must be non-empty\n"
                unless defined $alias && length $alias;

            die "Command registration failed for '$name': duplicate alias '$alias'\n"
                if $seen{$alias}++;

            die "Command registration failed for '$name': alias '$alias' duplicates command name '$name'\n"
                if $alias eq $name;

            die "Command registration failed for '$name': alias '$alias' conflicts with existing command\n"
                if exists $self->{commands}{$alias};

            foreach my $existing_name (keys %{ $self->{commands} }) {
                my $existing_aliases = $self->{commands}{$existing_name}{aliases} || [];
                foreach my $existing_alias (@$existing_aliases) {
                    die "Command registration failed for '$name': alias '$alias' conflicts with alias for '$existing_name'\n"
                        if $alias eq $existing_alias;
                }
            }
        }
    }

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

sub categories {
    my ($self) = @_;
    return $self->{categories};
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

sub print_help {
    my ($self, $args) = @_;
    if ($args && @$args) {
        if ($args->[0] eq 'categories') {
             return $self->print_categories;
        }

        if ($args->[0] eq 'category' || $args->[0] eq 'type') {
            my $category = $args->[1];
            unless (defined $category && length $category) {
                warn "usage: help category <category>\n";
                return;
            }
            return $self->_print_help_by_category($category);
        }

        if ($self->{calc}->functions->exists($args->[0])) {
            return $self->_print_help_for_function($args->[0]);
        }
        return $self->_print_help_for_command($args->[0]);
    }
    return $self->_print_help_overview;
}

sub _print_help_overview {
    my ($self) = @_;

    print <<'HELP';
Welcome to the RPN Calculator.

Learning
--------

    tutorials
        Browse the available tutorials.

Browsing
--------

    categories
        Browse command categories.

    commands
        Browse the complete command catalog.

Getting Details
---------------

    help <command>
        Display help for a command.

    help category <category>
        Display help for a command category.

Reference
---------

    aliases
        Display command aliases.

    abbreviations
        Display command abbreviations.

HELP

    return;
}

sub _print_help_all {
    my ($self) = @_;
    $self->_print_help_header;
    foreach my $command (
        sort {
            $self->{commands}{$a}{category} cmp $self->{commands}{$b}{category}
                ||
            $a cmp $b
        }
        keys %{ $self->{commands} }
    ) {
        $self->_print_help_line($command);
    }
    return;
}

sub print_categories {
    my ($self) = @_;
    printf "%-18s %s\n", "Category", "Description";
    printf "%-18s %s\n", "-" x 18, "-" x 40;
    foreach my $category (sort keys %{ $self->{categories} }) {
        printf "%-18s %s\n",
            $self->_display_category($category),
            $self->{categories}{$category};
    }
    return;
}

sub _print_help_by_category {
    my ($self, $category) = @_;

    my $category_key = $self->_normalize_category($category);

    my @matches = grep {
        ($self->{commands}{$_}{category} // '') eq $category_key
    } sort keys %{ $self->{commands} };

    unless (@matches) {
        print "No commands found for category '$category'.\n";
        print "\n";
        print "Use:\n";
        print "\n";
        print "    help categories\n";
        print "\n";
        print "to see available command categories.\n";
        return;
    }

    my $display_category = $self->_display_category($category_key);
    my $description = $self->{categories}{$category_key} || '';

    print "Category: $display_category\n";
    print "\n";
    print "$description\n" if length $description;
    print "\n" if length $description;

    print "Commands\n";
    print "--------\n";
    print "\n";

    $self->_print_help_header;

    for my $command (@matches) {
        $self->_print_help_line($command);
    }

    print "\n";
    print "See also:\n";
    print "\n";
    print "    commands $display_category\n";
    print "    categories\n";

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

    if (my $exact = $self->_exact_command_name($query)) {
        $self->_print_help_header;
        $self->_print_help_line($exact);
        return;
    }

    my @matches = $self->_find_help_matches($query);
    if (@matches > 1) {
        return $self->_print_help_matches($query, @matches);
    }

    my $command = $self->{abbrevs}{$query};
    if ($command) {
        $self->_print_help_header;
        $self->_print_help_line($command);
        return;
    }

    if (@matches) {
        return $self->_print_help_matches($query, @matches);
    }

    warn "No command '$query' was found.\n";
    return;
}

sub _exact_command_name {
    my ($self, $query) = @_;
    return unless defined $query && length $query;

    return $query if exists $self->{commands}{$query};

    foreach my $command (sort keys %{ $self->{commands} }) {
        foreach my $alias (@{ $self->{commands}{$command}{aliases} || [] }) {
            return $command if $alias eq $query;
        }
    }

    return;
}

sub _find_help_matches {
    my ($self, $query) = @_;

    my $needle = lc($query // '');
    $needle =~ s/^\s+//;
    $needle =~ s/\s+$//;
    return unless length $needle;

    my @matches;

    foreach my $category (sort keys %{ $self->{categories} }) {
        my $display = $self->_display_category($category);
        if ($self->_help_term_matches($needle, $category, $display)) {
            push @matches, {
                kind  => 'Category',
                name  => $display,
                usage => "help category $display",
            };
        }
    }

    foreach my $tutorial ($self->_tutorial_help_matches($needle)) {
        push @matches, {
            kind  => 'Tutorial',
            name  => $tutorial,
            usage => "tutorial $tutorial",
        };
    }

    foreach my $command (sort keys %{ $self->{commands} }) {
        next unless $self->_command_help_matches($needle, $command);
        push @matches, {
            kind  => 'Command',
            name  => $command,
            usage => "help $command",
        };
    }

    return @matches;
}

sub _help_term_matches {
    my ($self, $needle, @candidates) = @_;

    my $compact = $needle;
    $compact =~ s/[\s_-]+//g;
    my $singular = $compact;
    $singular =~ s/s\z// if length $singular > 1;

    foreach my $candidate (@candidates) {
        next unless defined $candidate && length $candidate;
        my $value = lc $candidate;
        $value =~ s/[\s_-]+//g;
        my $value_singular = $value;
        $value_singular =~ s/s\z// if length $value_singular > 1;

        return 1 if $value eq $compact;
        return 1 if $value_singular eq $singular;
        return 1 if index($value, $compact) == 0;
        return 1 if index($value_singular, $singular) == 0;
    }

    return;
}

sub _tutorial_help_matches {
    my ($self, $needle) = @_;

    my %seen;
    foreach my $file (glob($self->{calc}->tutorials_dir . '/*.txt')) {
        my $name = basename($file, '.txt');
        $name =~ s/_(?:v|version)\d+$//i;

        my $display = $name;
        $display =~ s/_/ /g;
        $display = join ' ', map { ucfirst lc $_ } split /\s+/, $display;

        my $key = lc $name;
        $key =~ s/_/ /g;

        next unless $self->_help_term_matches($needle, $key, $display);
        $seen{$display} = 1;
    }

    return sort keys %seen;
}

sub _command_help_matches {
    my ($self, $needle, $command) = @_;

    my $entry = $self->{commands}{$command};
    return 1 if $self->_help_term_matches($needle, $command);

    foreach my $alias (@{ $entry->{aliases} || [] }) {
        return 1 if $self->_help_term_matches($needle, $alias);
    }

    return;
}

sub _print_help_matches {
    my ($self, $query, @matches) = @_;

    print "Multiple matches found for '$query':\n";
    print "\n";

    foreach my $match (@matches) {
        printf "    %-9s %-18s Use: %s\n",
            $match->{kind},
            $match->{name},
            $match->{usage};
    }

    print "\n";
    return;
}

sub _print_help_header {
    my ($self) = @_;
    printf "%-18s %-12s %s\n", "Command", "Category", "Help";
    printf "%-18s %-12s %s\n", "-" x 18, "-" x 12, "-" x 40;
    return;
}

sub _print_help_line {
    my ($self, $command) = @_;
    my $entry   = $self->{commands}{$command};
    my $category = $self->_display_category($entry->{category} || '');
    my $help    = $entry->{help} || '';
    my $aliases = $entry->{aliases};
    if ($aliases && @$aliases) {
        $help .= " aliases: " . join(", ", @$aliases);
    }
    printf "%-18s %-12s %s\n", $command, $category, $help;
    return;
}

sub _normalize_category {
    my ($self, $category) = @_;
    $category //= '';
    $category =~ s/^\s+//;
    $category =~ s/\s+$//;
    $category = lc $category;
    $category =~ s/[\s-]+/_/g;
    return $category;
}

sub _display_category {
    my ($self, $category) = @_;
    return '' unless defined $category && length $category;
    return join ' ', map { ucfirst lc $_ } split /_+/, $category;
}

sub _print_command_catalog {
    my ($self, %args) = @_;

    printf "%-18s %-10s %-22s %-15s %s\n",
        "Command", "Abbrev", "Aliases", "Category", "Description";
    printf "%-18s %-10s %-22s %-15s %s\n",
        "-" x 18, "-" x 10, "-" x 22, "-" x 15, "-" x 40;

    foreach my $command (sort keys %{ $self->{commands} }) {
        my $entry = $self->{commands}{$command};
        my $category = $entry->{category} || '';
        next if defined $args{category} && $category ne $args{category};

        my $aliases = $entry->{aliases} || [];
        next if $args{aliases_only} && !@$aliases;

        my $abbrev = $self->_shortest_command_abbrev($command);
        next if $args{abbrevs_only} && !length $abbrev;

        printf "%-18s %-10s %-22s %-15s %s\n",
            $command,
            $abbrev,
            join(", ", @$aliases),
            $self->_display_category($category),
            $entry->{help} || '';
    }

    return;
}


sub _print_command_catalog_by_category {
    my ($self) = @_;

    foreach my $category (sort keys %{ $self->{categories} }) {
        my @commands = grep {
            ($self->{commands}{$_}{category} || '') eq $category
        } sort keys %{ $self->{commands} };

        next unless @commands;

        printf "%s (%d)\n", $self->_display_category($category), scalar @commands;
        printf "%s\n", "-" x (length($self->_display_category($category)) + 4 + length(scalar @commands));
        for my $command (@commands) {
            my $entry = $self->{commands}{$command};
            my $aliases = $entry->{aliases} || [];
            my $abbrev = $self->_shortest_command_abbrev($command);

            printf "    %-18s %-10s %-22s %s\n",
                $command,
                $abbrev,
                join(", ", @$aliases),
                $entry->{help} || '';
        }
        print "\n";
    }

    return;
}

sub _print_command_categories {
    my ($self) = @_;

    printf "%-18s %s\n", "Category", "Description";
    printf "%-18s %s\n", "-" x 18, "-" x 40;

    foreach my $category (sort keys %{ $self->{categories} }) {
        printf "%-18s %s\n",
            $self->_display_category($category),
            $self->{categories}{$category} || '';
    }

    return;
}

sub _shortest_command_abbrev {
    my ($self, $command) = @_;

    my $abbrevs = $self->abbrevs;
    my @matches =
        sort { length($a) <=> length($b) || $a cmp $b }
        grep {
            $abbrevs->{$_} eq $command
                && index($command, $_) == 0
                && length($_) < length($command)
        }
        keys %$abbrevs;

    return $matches[0] || '';
}


sub _metadata_display {
    my ($value) = @_;

    return defined($value) && length($value) ? $value : '-';
}

sub _execute_loop_condition {
    my ($calc, $exec, $command_name) = @_;

    my $before = $calc->stack->depth;
    $calc->execute($exec);
    my $after = $calc->stack->depth;

    if ($after <= $before) {
        warn "$command_name condition executable must leave a condition value\n";
        return;
    }

    my $condition = $calc->stack->pop;

    return (1, $condition ? 1 : 0);
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
