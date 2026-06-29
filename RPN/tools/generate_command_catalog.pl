#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use File::Spec;
use File::Temp qw(tempdir tempfile);
use Getopt::Long qw(GetOptions);
use lib 'lib';
use RPN;

my $output = 'docs/Command_Catalog_v3.8.7.txt';
my $check  = 0;
my $help   = 0;

GetOptions(
    'output=s' => \$output,
    'check'    => \$check,
    'help'     => \$help,
) or usage(2);

usage(0) if $help;

my $catalog = command_catalog_text();

if ($check) {
    -e $output
        or die "Command catalog not found: $output\n";

    open my $fh, '<', $output
        or die "Cannot read $output: $!\n";
    local $/;
    my $existing = <$fh>;
    close $fh;

    if ($existing ne $catalog) {
        print "Command catalog is out of date: $output\n";
        print "Run:\n";
        print "    make catalog\n";
        exit 1;
    }

    print "Command catalog is current.\n";
    exit 0;
}

open my $out, '>', $output
    or die "Cannot write $output: $!\n";
print {$out} $catalog;
close $out;

print "Wrote $output\n";
exit 0;

sub command_catalog_text {
    my $tmp_home = tempdir(CLEANUP => 1);
    local $ENV{HOME}          = $tmp_home;
    local $ENV{RPN_HISTORY}   = File::Spec->catfile($tmp_home, '.rpn_history');
    local $ENV{RPN_STACKS}    = File::Spec->catfile($tmp_home, '.rpn_stacks');
    local $ENV{RPN_VARIABLES} = File::Spec->catfile($tmp_home, '.rpn_variables');
    local $ENV{RPN_CONSTANTS} = File::Spec->catfile($tmp_home, '.rpn_constants');
    local $ENV{RPN_FUNCTIONS} = File::Spec->catfile($tmp_home, '.rpn_functions');

    my $calc = RPN->new(
        no_readline => 1,
        install_dir => '.',
    );

    my $registry = $calc->commands;
    my $commands = $registry->commands;

    my $text = '';
    $text .= sprintf "%-18s %-10s %-22s %-15s %s\n",
        'Command', 'Abbrev', 'Aliases', 'Category', 'Description';
    $text .= sprintf "%-18s %-10s %-22s %-15s %s\n",
        '-' x 18, '-' x 10, '-' x 22, '-' x 15, '-' x 40;

    for my $command (sort keys %$commands) {
        my $entry = $commands->{$command};
        my $aliases = $entry->{aliases} || [];

        $text .= sprintf "%-18s %-10s %-22s %-15s %s\n",
            $command,
            $registry->_shortest_command_abbrev($command),
            join(', ', @$aliases),
            $registry->_display_category($entry->{type} || ''),
            $entry->{help} || '';
    }

    return $text;
}

sub usage {
    my ($status) = @_;
    print <<'USAGE';
Usage: perl -Ilib tools/generate_command_catalog.pl [options]

Options:
    --output FILE   Catalog file to write or check
                    default: docs/Command_Catalog_v3.8.7.txt
    --check         Verify FILE matches the generated catalog
    --help          Show this help

The command catalog is generated from the live command registry.
USAGE
    exit $status;
}
