package RPN::Commands::Variables;

use v5.34;
use strict;
use warnings;

sub register_commands {
    my ($self) = @_;


    $self->register(
        store => {
            aliases => ['sto'],
            category => 'variable',
            help    => 'pop NAME and store the top stack value in that variable',
            code    => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(2);

                my $name  = $calc->stack->pop;
                my $value = $calc->stack->peek;

                unless (defined $name && !ref($name) && $name =~ /^[A-Za-z_]\w*$/) {
                    $calc->stack->push($name) if defined $name;
                    warn "store requires a variable name string on the stack\n";
                    return;
                }

                if ($self->is_registered_command_name($name)) {
                    $calc->stack->push($name);
                    warn "Cannot store variable '$name': name already used by a command\n";
                    return;
                }

                if ($calc->constants->exists($name)) {
                    $calc->stack->push($name);
                    warn "Cannot store variable '$name': name already used by a constant\n";
                    return;
                }

                $calc->variables->set($name, $value);
            },
        }
    );

    $self->register(
        recall => {
            aliases => ['rcl'],
            category => 'variable',
            help    => 'pop NAME and push that variable value onto the stack',
            code    => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(1);

                my $name = $calc->stack->pop;

                unless (defined $name && !ref($name)) {
                    $calc->stack->push($name) if defined $name;
                    warn "recall requires a variable name string on the stack\n";
                    return;
                }

                unless ($calc->variables->exists($name)) {
                    $calc->stack->push($name);
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
            category => 'variable',
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
            category => 'variable',
            help => 'pop NAME and delete that stored variable',
            code => sub {
                my ($calc) = @_;

                return unless $calc->stack->require_depth(1);

                my $name = $calc->stack->pop;

                unless (defined $name && !ref($name)) {
                    $calc->stack->push($name) if defined $name;
                    warn "delvar requires a variable name string on the stack\n";
                    return;
                }

                unless ($calc->variables->exists($name)) {
                    $calc->stack->push($name);
                    warn "No such variable '$name'\n";
                    return;
                }

                $calc->variables->delete($name);
            },
        }
    );

    $self->register(
        savevars => {
            category => 'variable',
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
            category => 'variable',
            help => 'load variables from disk: loadvars [file]',
            code => sub {
                my ($calc, $arg_str, $args) = @_;
                my $file = $args && @$args ? $args->[0] : undef;
                $calc->load_variables($file);
                print "Loaded variables.\n";
            },
        }
    );


}

1;
