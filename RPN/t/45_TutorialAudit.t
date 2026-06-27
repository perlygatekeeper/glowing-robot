#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use Test::More;
use File::Path qw(make_path);
use File::Temp qw(tempdir);

my $tmp = tempdir(CLEANUP => 1);
my $good = "$tmp/good";
my $bad  = "$tmp/bad";
make_path($good, $bad);

write_file(
    "$good/Good_v01.txt",
    <<'TXT'
# Good tutorial

RPN> 1 2 +
RPN> define square
RPN> dup *
RPN> end
RPN> 5 square
RPN> sto tax_rate
RPN> 1 tax_rate +
RPN> "hello world"
TXT
);

write_file(
    "$bad/Bad_v01.txt",
    <<'TXT'
# Bad tutorial

RPN> 1 2 definitely_not_a_command
TXT
);

ok(
    run_audit($good) == 0,
    'tutorial audit accepts known commands, literals, and local names'
);

ok(
    run_audit($bad) != 0,
    'tutorial audit rejects unknown command-looking tokens'
);

done_testing();

sub run_audit {
    my ($dir) = @_;
    return system(
        $^X,
        '-Ilib',
        'tools/tutorial_audit.pl',
        '--quiet',
        '--tutorial-dir',
        $dir,
    );
}

sub write_file {
    my ($file, $content) = @_;
    open my $fh, '>', $file
        or die "Cannot write $file: $!";
    print {$fh} $content;
    close $fh;
}
