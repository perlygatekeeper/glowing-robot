#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use Getopt::Long qw(GetOptions);
use lib 'lib';
use RPN::Commands::Examples;

my $output = 'docs/Examples_Catalog_v3.9.2.txt';
my $check  = 0;
my $help   = 0;

GetOptions(
    'output=s' => \$output,
    'check'    => \$check,
    'help'     => \$help,
) or usage(2);

usage(0) if $help;

my $catalog = examples_catalog_text('examples');

if ($check) {
    -e $output
        or die "Examples catalog not found: $output\n";

    open my $fh, '<', $output
        or die "Cannot read $output: $!\n";
    local $/;
    my $existing = <$fh>;
    close $fh;

    if ($existing ne $catalog) {
        print "Examples catalog is out of date: $output\n";
        print "Run:\n";
        print "    make examples-catalog\n";
        exit 1;
    }

    print "Examples catalog is current.\n";
    exit 0;
}

open my $out, '>', $output
    or die "Cannot write $output: $!\n";
print {$out} $catalog;
close $out;

print "Wrote $output\n";
exit 0;

sub examples_catalog_text {
    my ($examples_dir) = @_;
    my @examples = RPN::Commands::Examples::_discover_examples($examples_dir);

    my $text = "RPN Examples Catalog\n";
    $text .= "====================\n\n";
    $text .= "Generated from example metadata. Do not edit by hand.\n\n";

    my $category = '';
    for my $example (@examples) {
        if ($example->{category} ne $category) {
            $category = $example->{category};
            $text .= "$category\n";
            $text .= ('-' x length($category)) . "\n\n";
        }

        $text .= "$example->{name}\n";
        $text .= "    Key: $example->{key}\n";
        $text .= "    $example->{description}\n\n";
    }

    $text .= sprintf "Total: %d examples\n", scalar @examples;
    return $text;
}

sub usage {
    my ($status) = @_;
    print <<'USAGE';
Usage: perl -Ilib tools/generate_examples_catalog.pl [options]

Options:
    --output FILE   Catalog file to write or check
                    default: docs/Examples_Catalog_v3.9.2.txt
    --check         Verify FILE matches the generated catalog
    --help          Show this help

The examples catalog is generated from metadata in examples/*/*.txt.
USAGE
    exit $status;
}
