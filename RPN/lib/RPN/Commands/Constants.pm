package RPN::Commands::Constants;

use v5.34;
use strict;
use warnings;

sub register_commands {
    my ($commands) = @_;

    #
    # Constants
    #

    $commands->register(
        constants => {
            aliases => ['const'],
            category => 'constant',
            help    => 'list, push, define, or browse constants',
            code    => sub {
                my ($calc, $arg_str, $args) = @_;

                #
                # const
                #   list constants in compact form
                #

                unless ($args && @$args) {
                    _print_constants_table($calc);
                    return;
                }

                #
                # constants all
                #   list constants with first-class metadata
                #

                if (@$args == 1 && lc($args->[0]) eq 'all') {
                    _print_constants_table($calc, verbose => 1);
                    return;
                }

                #
                # constants categories
                #   list defined categories
                #

                if (@$args == 1 && lc($args->[0]) eq 'categories') {
                    _print_constant_categories($calc);
                    return;
                }

                #
                # const name
                #   push constant
                #

                if (@$args == 1 && $calc->constants->exists($args->[0])) {
                    $calc->stack->push($calc->constants->get($args->[0]));
                    return;
                }

                #
                # constants category
                #   list constants in a category
                #

                if (@$args == 1) {
                    my $category = $args->[0];
                    my @names = $calc->constants->names_in_category($category);

                    unless (@names) {
                        warn "No constant or category '$category' was found. ";
                        return;
                    }

                    _print_constants_table($calc, verbose => 1, names => \@names);
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

    $commands->register(
        constinfo => {
            category => 'constant',
            help => 'show value and metadata for one constant',
            code => sub {
                my ($calc, $arg_str, $args) = @_;

                unless ($args && @$args == 1) {
                    warn "usage: constinfo <name> ";
                    return;
                }

                my $name = $args->[0];
                my $record = $calc->constants->record($name);

                unless ($record) {
                    warn "No constant '$name' was found. ";
                    return;
                }

                my $source = $calc->constants->is_builtin($name)
                    ? 'builtin'
                    : 'user';

                printf "%-12s %s\n", 'Name',   $name;
                printf "%-12s %s\n", 'Source', $source;
                printf "%-12s %s\n", 'Value',  $record->{value};

                my %metadata = %{ $record->{metadata} || {} };
                foreach my $key (sort keys %metadata) {
                    printf "%-12s %s\n", _metadata_label($key), $metadata{$key};
                }

                return;
            },
        }
    );

    $commands->register(
        delconst => {
            category => 'constant',
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

    $commands->register(
        loadconst => {
            category => 'constant',
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

    $commands->register(
        saveconst => {
            category => 'constant',
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


    return;
}

sub _print_constants_table {
    my ($calc, %args) = @_;

    my @names = $args{names}
        ? @{ $args{names} }
        : $calc->constants->names;

    if ($args{verbose}) {
        printf "%-12s %-12s %-20s %-18s %-18s\n",
            "Name", "Source", "Value", "Units", "Category";
        printf "%-12s %-12s %-20s %-18s %-18s\n",
            "-" x 12, "-" x 12, "-" x 20, "-" x 18, "-" x 18;

        foreach my $name (@names) {
            my $record = $calc->constants->record($name);
            next unless $record;

            my $source = $calc->constants->is_builtin($name)
                ? 'builtin'
                : 'user';
            my $metadata = $record->{metadata} || {};

            printf "%-12s %-12s %-20s %-18s %-18s\n",
                $name,
                $source,
                $record->{value},
                _metadata_display($metadata->{units}),
                _metadata_display($metadata->{category});
        }

        return;
    }

    printf "%-12s %-12s %s\n", "Name", "Source", "Value";
    printf "%-12s %-12s %s\n", "-" x 12, "-" x 12, "-" x 30;

    foreach my $name (@names) {
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


sub _print_constant_categories {
    my ($calc) = @_;

    my @categories = $calc->constants->categories;

    print "Available Categories\n";
    print "--------------------\n";

    foreach my $category (@categories) {
        print "$category\n";
    }

    print "\n" . scalar(@categories) . " categories\n";

    return;
}


sub _metadata_display {
    my ($value) = @_;

    return defined($value) && length($value) ? $value : '-';
}


sub _metadata_label {
    my ($key) = @_;

    return join ' ', map { ucfirst lc } split /_+/, $key;
}



1;
