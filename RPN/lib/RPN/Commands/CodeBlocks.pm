package RPN::Commands::CodeBlocks;

use v5.34;
use strict;
use warnings;

use RPN::CodeBlock;

sub register_commands {
    my ($commands) = @_;

    $commands->register(
        codeblocks => {
            category => 'codeblock',
            help     => 'list named code blocks',
            code     => sub {
                my ($calc) = @_;
                my @names = $calc->codeblocks->names;

                if (!@names) {
                    print "No code blocks defined.\n";
                    return;
                }

                printf "%-18s %s\n", 'Name', 'Source';
                printf "%-18s %s\n", '-' x 18, '-' x 40;

                for my $name (@names) {
                    my $block = $calc->codeblocks->get($name);
                    printf "%-18s %s\n", $name, $block->as_string;
                }

                return;
            },
        }
    );

    $commands->register(
        showblock => {
            category => 'codeblock',
            help     => 'display a named code block',
            code     => sub {
                my ($calc, $arg_str, $args) = @_;
                my $name = $args && @$args ? $args->[0] : undef;

                unless (defined $name && length $name) {
                    warn "usage: showblock NAME\n";
                    return;
                }

                unless ($calc->codeblocks->exists($name)) {
                    warn "No such code block '$name'\n";
                    return;
                }

                print "$name = " . $calc->codeblocks->get($name)->as_string . "\n";
                return;
            },
        }
    );

    $commands->register(
        iscodeblock => {
            category => 'codeblock',
            help     => 'test whether the top stack value is a code block',
            code     => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $value = $calc->stack->pop;
                $calc->stack->push($value);
                $calc->stack->push(RPN::CodeBlock::is_codeblock($value) ? 1 : 0);
                return;
            },
        }
    );

    return;
}

1;
