package RPN::Commands::Stack;

use strict;
use warnings;


sub _sort_stack {
    my ($calc, $direction) = @_;

    my @values = $calc->stack->values;
    if (@values && $calc->isanumber($values[0])) {
        @values =
            $direction < 0
            ? sort { $b <=> $a } @values
            : sort { $a <=> $b } @values;
    }
    else {
        @values =
            $direction < 0
            ? sort { $b cmp $a } @values
            : sort { $a cmp $b } @values;
    }
    $calc->stack->set_values(@values);
}

sub register_commands {
    my ($commands) = @_;

    #
    # Move existing stack commands here first.
    #
    # Suggested existing commands to move:
    #
    # dup
    # drop
    # swap
    # clear
    # depth
    # reverse
    # sort
    # unique
    # stack / stacks / newstack / dropstack / switchstack
    # any other command whose type is now 'stack'

    #
    # Stack Contents-effecting
    #

    $commands->register(
        sort => {
            category => 'stack',
            help => 'sort the stack in ascending order',
            code => sub {
                my ($calc) = @_;
                _sort_stack($calc, 1);
            },
        }
    );

    $commands->register(
        sortr => {
            category => 'stack',
            help => 'sort the stack in descending order',
            code => sub {
                my ($calc) = @_;
                _sort_stack($calc, -1);
            },
        }
    );

    $commands->register(
        unique => {
            category => 'stack',
            help => 'remove duplicate values while preserving order',
            code => sub {
                my ($calc) = @_;
                my %seen;
                my @values =
                    grep { !$seen{$_}++ }
                    $calc->stack->values;
                $calc->stack->set_values(@values);
            },
        }
    );


    $commands->register(
        stack => {
            category => 'stack',
            help => '(stack NAME) switches stacks, (stack list) lists stacks, (stack) reports current stack',
            code => sub {
                my ($calc, $arg_str, $args) = @_;
                my $stack = $calc->stack;
                if ($args && @$args) {
                    my $name = $args->[0];
                    if ($name eq 'list' || $name eq '.' || $name eq '?' || $name eq '*') {
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

    $commands->register(
        pop => {
            aliases => ['drop'],
            category => 'stack',
            help => 'remove the top value from the stack',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                $calc->stack->pop;
            },
        }
    );

    $commands->register(
        shuffle => {
            category => 'stack',
            help => 'randomly shuffle the current stack',
            code => sub {
                my ($calc) = @_;
                my @values = $calc->stack->values;
                for (my $i = $#values; $i > 0; $i--) {
                    my $j = int(rand($i + 1));
                    @values[$i, $j] = @values[$j, $i];
                }
                $calc->stack->set_values(@values);
            },
        }
    );

    $commands->register(
        duplicate => {
            aliases => ['dup'],
            category => 'stack',
            help    => 'duplicates the number on top of the stack',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                $calc->stack->push($calc->stack->peek);
            },
        }
    );

    $commands->register(
        exchange => {
            aliases => [qw(x swap)],
            category => 'stack',
            help    => 'swaps the top two values on the stack',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);
                my ($a, $b) = $calc->stack->pop2;
                $calc->stack->push($b, $a);
            },
        }
    );


    $commands->register(
        clear => {
            aliases => ['clr'],
            category => 'stack',
            help    => 'empties the stack',
            code    => sub {
                my ($calc) = @_;
                $calc->stack->clear;
            },
        }
    );

    $commands->register(
        deletestack => {
            aliases => [qw(dropstack rmstack)],
            category => 'stack',
            help    => 'delete a named stack: deletestack <name>',
            code => sub {
                my ($calc, $arg_str, $args) = @_;

                my $name = $args->[0];

                unless (defined $name) {
                    warn "usage: deletestack <name>\n";
                    return;
                }

                $calc->stack->delete_stack($name);
            },
        }
    );

    $commands->register(
        depth => {
            category => 'stack',
            help => 'pushes the current stack depth onto the stack',
            code => sub {
                my ($calc) = @_;
                $calc->stack->push($calc->stack->depth);
            },
        }
    );

    #
    # Extra stack operations
    #

    $commands->register(
        reverse => {
            category => 'stack',
            help => 'reverse the current stack',
            code => sub {
                my ($calc) = @_;
                my @values = reverse $calc->stack->values;
                $calc->stack->set_values(@values);
            },
        }
    );

    $commands->register(
        pick => {
            category => 'stack',
            help => 'copy value at depth N to the top of the stack',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $n = $calc->stack->pop;
                unless (defined $n && $n =~ /^\d+$/) {
                    warn "pick requires a non-negative integer\n";
                    return;
                }
                return unless $calc->stack->require_depth($n + 1);
                $calc->stack->push($calc->stack->peek_at($n));
            },
        }
    );

    $commands->register(
        pullup => {
            aliases => ['rollup'],
            category => 'stack',
            help    => 'move value at depth N to the top of the stack',
            code    => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $n = $calc->stack->pop;
                unless (defined $n && $n =~ /^\d+$/) {
                    warn "pullup requires a non-negative integer\n";
                    return;
                }
                return unless $calc->stack->require_depth($n + 1);
                my @values = $calc->stack->values;
                my $value  = splice @values, $n, 1;
                unshift @values, $value;
                $calc->stack->set_values(@values);
            },
        }
    );

    $commands->register(
        pushdown => {
            category => 'stack',
            help => 'move the top value down to depth N',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $n = $calc->stack->pop;
                unless (defined $n && $n =~ /^\d+$/) {
                    warn "pushdown requires a non-negative integer\n";
                    return;
                }
                return unless $calc->stack->require_depth($n + 1);
                my @values = $calc->stack->values;
                my $value  = shift @values;
                splice @values, $n, 0, $value;
                $calc->stack->set_values(@values);
            },
        }
    );

    $commands->register(
        roll => {
            category => 'stack',
            help => 'pop N and circularly rotate the whole stack by that many positions',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $n = $calc->stack->pop;
                unless (defined $n && $n =~ /^-?\d+$/ && $n != 0) {
                    warn "roll requires a non-zero integer\n";
                    return;
                }
                my @values = $calc->stack->values;
                my $size   = @values;
                return if $size < 2;
                $n %= $size;
                if ($n < 0) {
                    @values = (@values[-$n .. $#values], @values[0 .. -$n - 1]);
                }
                elsif ($n > 0) {
                    @values = (@values[$size - $n .. $#values], @values[0 .. $size - $n - 1]);
                }
                $calc->stack->set_values(@values);
            },
        }
    );

    $commands->register(
        clearall => {
            category => 'stack',
            help => 'clear all stacks and return to the default stack',
            code => sub {
                my ($calc) = @_;
                $calc->stack->clear_all;
                print "All stacks cleared.\n";
            },
        }
    );


        $commands->register(
        stackexists => {
            category => 'stack',
            help => 'return true if named stack exists: stackname stackexists',
            code => sub {
                my ($calc) = @_;
                my $name = $calc->stack->pop;

                $calc->stack->push(
                    $calc->stack->stack_exists($name) ? 1 : 0
                );
            },
        }
    );

    $commands->register(
        stacksize => {
            category => 'stack',
            help => 'push depth of named stack: stackname stacksize',
            code => sub {
                my ($calc) = @_;
                my $name = $calc->stack->pop;

                my $size = $calc->stack->stack_size($name);

                unless (defined $size) {
                    warn "Unknown stack '$name'\n";
                    return;
                }

                $calc->stack->push($size);
            },
        }
    );

    $commands->register(
        copystack => {
            category => 'stack',
            help => 'copy stack: copystack <src> <dst>',
            code => sub {
                my ($calc, $arg_str, $args) = @_;

                my ($src, $dst) = @$args;

                unless (defined $src && defined $dst) {
                    warn "usage: copystack <src> <dst>\n";
                    return;
                }

                $calc->stack->copy_stack($src, $dst);
            },
        }
    );

    $commands->register(
        dupstack => {
            category => 'stack',
            help => 'duplicate current stack: dupstack <dst>',
            code => sub {
                my ($calc, $arg_str, $args) = @_;

                my $dst = $args->[0];

                unless (defined $dst && length $dst) {
                    warn "usage: dupstack <dst>\n";
                    return;
                }

                $calc->stack->dup_stack($dst);
            },
        }
    );

    $commands->register(
        renamestack => {
            aliases => ['movestack'],
            category => 'stack',
            help    => 'rename stack: renamestack <old> <new>',
            code => sub {
                my ($calc, $arg_str, $args) = @_;

                my ($old, $new) = @$args;

                unless (defined $old && defined $new) {
                    warn "usage: renamestack <old> <new>\n";
                    return;
                }

                $calc->stack->rename_stack($old, $new);
            },
        }
    );

    $commands->register(
        clearstack => {
            category => 'stack',
            help => 'clear named stack: clearstack <name>',
            code => sub {
                my ($calc, $arg_str, $args) = @_;

                my $name = $args->[0];

                unless (defined $name) {
                    warn "usage: clearstack <name>\n";
                    return;
                }

                $calc->stack->clear_named_stack($name);
            },
        }
    );

    $commands->register(
        mergestacks => {
            category => 'stack',
            help => 'append source stack onto destination: mergestacks <src> <dst>',
            code => sub {
                my ($calc, $arg_str, $args) = @_;

                my ($src, $dst) = @$args;

                unless (defined $src && defined $dst) {
                    warn "usage: mergestacks <src> <dst>\n";
                    return;
                }

                $calc->stack->merge_stacks($src, $dst);
            },
        }
    );

    $commands->register(
        pour => {
            category => 'stack',
            help => 'pour source stack onto destination, reversing order: pour <src> <dst>',
            code => sub {
                my ($calc, $arg_str, $args) = @_;

                my ($src, $dst) = @$args;

                unless (defined $src && defined $dst) {
                    warn "usage: pour <src> <dst>\n";
                    return;
                }

                $calc->stack->pour_stack($src, $dst);
            },
        }
    );

    $commands->register(
        stackinfo => {
            category => 'stack',
            help => 'display information about all stacks',
            code => sub {
                my ($calc) = @_;
                my $stack = $calc->stack;

                printf "%-18s %8s %s\n", "Stack", "Depth", "Current";
                printf "%-18s %8s %s\n", "-" x 18, "-" x 8, "-" x 7;

                for my $name ($stack->stack_names) {
                    printf "%-18s %8d %s\n",
                        $name,
                        $stack->depth_of($name),
                        $name eq $stack->current_name ? "*" : "";
                }
            },
        }
    );

    return;
}

1;
