package RPN::Commands::Tutorials;

use v5.34;
use strict;
use warnings;

use File::Basename qw(basename);

sub register_commands {
    my ($commands) = @_;

    #
    # Tutorial commands
    #

    $commands->register(
        tutorials => {
            type => 'documentation',
            help => 'list available tutorials',
            code => sub {

                my %seen;

                for my $file (glob('docs/tutorials/*.txt')) {

                    my ($key, $version)
                        = _tutorial_key_and_version($file);

                    $seen{$key} = 1;
                }

                print "Available Tutorials\n\n";

                print "  $_\n"
                    for sort keys %seen;
            },
        },
    );

    $commands->register(
        tutorial => {
            type => 'documentation',
            help => 'display a tutorial: tutorial <name>',
            code => sub {
                my ($calc, $arg_str, $args) = @_;

                my $wanted = lc($args->[0] // '');

                unless (length $wanted) {
                    warn "usage: tutorial <name>\n";
                    return;
                }

                my $best_file;
                my $best_version = -1;

                for my $file (glob('docs/tutorials/*.txt')) {

                    my ($key, $version)
                        = _tutorial_key_and_version($file);

                    next unless $key eq $wanted;

                    if ($version > $best_version) {
                        $best_version = $version;
                        $best_file    = $file;
                    }
                }

                unless ($best_file) {
                    warn "Unknown tutorial '$wanted'\n";
                    warn "Use 'tutorials' to list available tutorials\n";
                    return;
                }

                my $pager = _select_pager();

                unless ($pager) {
                    warn 'No pager found; tried $ENV{PAGER}, less, and more' . "\n";
                    return;
                }

                system('clear');
                _run_pager($pager, $best_file);
                system('clear');

                # my $pager = $ENV{PAGER} || 'less';

                # system('clear');
                # if ($pager =~ /\s/) {
                #     system("$pager '$best_file'");
                #  }
                # else {
                #     system($pager, $best_file);
                # }
                # system('clear');

                return;

            },
        },
    );

    $commands->register(
        quickstart => {
            type => 'documentation',
            help => 'display the quick reference guide',
            code => sub {
                my ($calc) = @_;

                $calc->process_input('tutorial quickstart');
            },
        },
    );

    return;
}

sub _tutorial_key_and_version {
    my ($file) = @_;

    my $name = basename($file, '.txt');

    my $version = 0;

    if ($name =~ s/_(?:v|version)(\d+)$//i) {
        $version = $1;
    }

    return (lc($name), $version);
}

sub _select_pager {
    for my $pager ($ENV{PAGER}, 'less', 'more') {
        next unless defined $pager && length $pager;
        return $pager if _command_available($pager);
    }

    return;
}

sub _command_available {
    my ($pager) = @_;

    my ($command) = split /\s+/, $pager;
    return unless defined $command && length $command;

    return 1 if $command =~ m{/} && -x $command;

    for my $dir (split /:/, $ENV{PATH} // '') {
        return 1 if -x "$dir/$command";
    }

    return;
}

sub _run_pager {
    my ($pager, $file) = @_;

    if ($pager =~ /\s/) {
        system("$pager '$file'");
    }
    else {
        system($pager, $file);
    }

    return;
}

1;
