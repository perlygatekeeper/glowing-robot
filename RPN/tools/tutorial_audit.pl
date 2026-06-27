#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use File::Find qw(find);
use File::Spec;
use File::Temp qw(tempdir);
use Getopt::Long qw(GetOptions);
use lib 'lib';
use RPN;

my $prompt       = 'RPN>';
my $tutorial_dir = 'docs/tutorials';
my $quiet        = 0;
my $help         = 0;

GetOptions(
    'prompt=s'       => \$prompt,
    'tutorial-dir=s' => \$tutorial_dir,
    'quiet'          => \$quiet,
    'help'           => \$help,
) or usage(2);

usage(0) if $help;

-d $tutorial_dir
    or die "Tutorial directory not found: $tutorial_dir\n";

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

my %known;
$known{$_} = 1 for keys %{ $calc->commands->commands };
$known{$_} = 1 for keys %{ $calc->commands->abbrevs };

# Built-in constants are valid prompt tokens even though they are not commands.
if ($calc->constants && $calc->constants->can('names')) {
    $known{$_} = 1 for $calc->constants->names;
}

# Constant names shipped in bundled constant libraries are valid tutorial
# references, even if they are loaded only by an example before use.
for my $dir (qw(constants examples/constants)) {
    next unless -d $dir;
    find(
        {
            no_chdir => 1,
            wanted   => sub {
                return unless -f $_;
                return unless /\.txt\z/;
                open my $fh, '<', $File::Find::name or return;
            while (my $line = <$fh>) {
                if ($line =~ /\A\s*([A-Za-z_]\w*)\s*=/) {
                    $known{$1} = 1;
                }
            }
            close $fh;
            },
        },
        $dir
    );
}

# Function definition sentinel used by the interactive function editor.
$known{end} = 1;

my %argument_command = map { $_ => 1 } qw(
    help type tutorial stack stacks constants const constinfo delconst loadconst saveconst
    vars variables sto store delvar loadvar savevar funcs functions define def deldef
    history clearhistory
);

my @files;
find(
    sub {
        return unless -f $_;
        return unless /\.txt\z/;
        push @files, $File::Find::name;
    },
    $tutorial_dir
);

@files = sort @files;

my @unknown;
my $prompt_lines = 0;
my $prompt_re = qr/^\Q$prompt\E\s*(.*\S)?\s*\z/;

for my $file (@files) {
    open my $fh, '<', $file
        or die "Cannot read $file: $!\n";

    my %local_name;
    my $line_no = 0;

    while (my $line = <$fh>) {
        ++$line_no;
        chomp $line;

        next unless $line =~ $prompt_re;
        my $input = $1 // '';
        next unless $input =~ /\S/;

        ++$prompt_lines;
        my @tokens = tutorial_tokens($input);

        for (my $i = 0; $i < @tokens; ++$i) {
            my $token = $tokens[$i];
            next unless should_check_token($token);

            my $previous = $tokens[$i - 1] // '';

            if ($previous =~ /\A(?:define|def)\z/) {
                $local_name{$token} = 1;
                next;
            }

            if ($previous =~ /\A(?:sto|store)\z/) {
                $local_name{$token} = 1;
                next;
            }

            if ($argument_command{$previous}) {
                next;
            }

            next if $known{$token};
            next if $local_name{$token};

            push @unknown, {
                file  => $file,
                line  => $line_no,
                token => $token,
                input => $input,
            };
        }
    }

    close $fh;
}

if (@unknown) {
    print "Tutorial command audit failed.\n";
    print "\n";
    print "Unknown prompt tokens:\n";
    for my $entry (@unknown) {
        print "  $entry->{file}:$entry->{line}: $entry->{token}\n";
        print "      RPN> $entry->{input}\n";
    }
    print "\n";
    print "Scanned ", scalar(@files), " tutorial files and $prompt_lines prompt lines.\n";
    exit 1;
}

unless ($quiet) {
    print "Tutorial command audit passed.\n";
    print "Scanned ", scalar(@files), " tutorial files and $prompt_lines prompt lines.\n";
}

exit 0;

sub tutorial_tokens {
    my ($input) = @_;

    # Quoted strings are data, not command references.
    $input =~ s/"(?:\\.|[^"])*"/ /g;
    $input =~ s/'(?:\\.|[^'])*'/ /g;

    return grep { length } split /\s+/, $input;
}

sub should_check_token {
    my ($token) = @_;

    return 0 unless defined $token && length $token;
    return 0 if $token =~ /\A[-+]?\d/;
    return 0 if $token =~ /[\[\],;]/;
    return 0 if $token =~ /\A#|\A\/|\.txt\z|\.rpn\z/;

    # Operator commands such as +, *, <, >= are valid command tokens.
    return 1 if $token =~ /\A[+\-*\/^%<>=!]+\z/;

    return $token =~ /\A[A-Za-z_]\w*\z/;
}

sub usage {
    my ($status) = @_;
    print <<'USAGE';
Usage: perl -Ilib tools/tutorial_audit.pl [options]

Options:
    --tutorial-dir DIR   Directory containing tutorial .txt files
                         default: docs/tutorials
    --prompt STRING      Prompt marker used for tutorial input lines
                         default: RPN>
    --quiet              Suppress success output
    --help               Show this help

The audit scans only lines beginning with the tutorial prompt. It verifies
that command-looking tokens are registered commands, aliases, built-in
constants, or names defined earlier in the same tutorial example stream.
USAGE
    exit $status;
}
