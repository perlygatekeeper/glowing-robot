package RPN::Commands::Functions;

use v5.34;
use strict;
use warnings;

sub register_commands {
    my ($commands) = @_;

    $commands->register(
        define => {
            aliases  => ['def'],
            category => 'function',
            help     => 'define a user function: define <name> <body>',
            code     => sub {
                my ($calc, $arg_str, $args) = @_;
                unless ($args && @$args >= 2) {
                    warn "usage: def <name> <body>\n";
                    return;
                }
                my $name = shift @$args;
                my $body = join ' ', @$args;
                unless ($name =~ /^[A-Za-z_0-9]\w*$/) {
                    warn "Invalid function name '$name'\n";
                    return;
                }
                if ($calc->constants->exists($name)) {
                    warn "Cannot define function '$name': name already used by a constant\n";
                    return;
                }
                if ($commands->is_registered_command_name($name)) {
                    warn "Cannot define function '$name': name already used by a command\n";
                    return;
                }
                if ($calc->variables->exists($name)) {
                    warn "Cannot define function '$name': name already used by a variable\n";
                    return;
                }
                if ($body =~ /^(['"])(.*)\1$/s) {
                    $body = $calc->_unescape_quoted_string($2, $1);
                }
                $calc->functions->set($name, $body);
            },
        }
    );

    $commands->register(
        undef => {
            category => 'function',
            help     => 'pop NAME and delete that user function',
            code     => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);
                my $name = $calc->stack->pop;
                unless (defined $name && !ref($name)) {
                    $calc->stack->push($name) if defined $name;
                    warn "undef requires a function name string on the stack\n";
                    return;
                }
                unless ($calc->functions->exists($name)) {
                    $calc->stack->push($name);
                    warn "No such function '$name'\n";
                    return;
                }
                $calc->functions->delete($name);
            },
        }
    );

    $commands->register(
        functions => {
            aliases  => ['funcs'],
            category => 'function',
            help     => 'list user-defined functions',
            code     => sub {
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

    $commands->register(
        savefuncs => {
            category => 'function',
            help     => 'save user-defined functions to disk: savefuncs [file]',
            code     => sub {
                my ($calc, $arg_str, $args) = @_;
                my $file = $args && @$args ? $args->[0] : undef;
                $calc->save_functions($file);
                print "Saved functions.\n";
            },
        }
    );

    $commands->register(
        loadfuncs => {
            category => 'function',
            help     => 'load user-defined functions from disk: loadfuncs [file]',
            code     => sub {
                my ($calc, $arg_str, $args) = @_;
                my $file = $args && @$args ? $args->[0] : undef;
                $calc->load_functions($file);
                print "Loaded functions.\n";
            },
        }
    );

    $commands->register(
        showfunc => {
            category => 'function',
            help     => 'show the definition of a function',
            code     => sub {
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
}

1;
