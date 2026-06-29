#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

my $tmp = tempdir(CLEANUP => 1);
my $catalog = "$tmp/Command_Catalog.txt";

is(
    system($^X, '-Ilib', 'tools/generate_command_catalog.pl', '--output', $catalog),
    0,
    'command catalog generator writes catalog'
);

ok(-s $catalog, 'generated catalog exists and is non-empty');

my $text = read_file($catalog);
like($text, qr/\ACommand\s+Abbrev\s+Aliases\s+Category\s+Description\n/, 'catalog has expected header');
like($text, qr/^commands\s+\S*\s+\s*Discovery\s+/m, 'catalog includes commands in Discovery category');
like($text, qr/^combinations\s+\S*\s+[^\n]*\bncr\b[^\n]*Combinatorics\s+/m, 'catalog includes combinations with ncr alias');

is(
    system($^X, '-Ilib', 'tools/generate_command_catalog.pl', '--output', $catalog, '--check'),
    0,
    'catalog check passes for current generated file'
);

open my $fh, '>>', $catalog or die "Cannot append to $catalog: $!";
print {$fh} "# stale\n";
close $fh;

ok(
    system($^X, '-Ilib', 'tools/generate_command_catalog.pl', '--output', $catalog, '--check') != 0,
    'catalog check fails for stale catalog'
);

done_testing();

sub read_file {
    my ($file) = @_;
    open my $fh, '<', $file or die "Cannot read $file: $!";
    local $/;
    return <$fh>;
}
