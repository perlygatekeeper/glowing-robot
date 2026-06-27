use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

use lib 'lib';
use RPN::Constants;

my $dir = tempdir(CLEANUP => 1);
my $file = "$dir/constants.txt";

open my $fh, '>', $file or die $!;
print {$fh} <<'CONSTANTS';
# Existing simple format remains valid.
legacy = 123
space_syntax 456

metadata: category="physics" ; source="CODATA 2022"

c = 299792458 ; units="m/s" ; description="Speed of light in vacuum"
g0 = 9.80665 ; units="m/s^2" ; description="Standard acceleration due to gravity"

# Constant-specific metadata overrides inherited metadata.
G = 6.67430e-11 ; units="m^3/(kg*s^2)" ; category="Fundamental Physics" ; description="Newtonian constant of gravitation"

metadata: reset
metadata: category="mathematics"

quote_test = 1 ; description="Euler said \"Read Gauss.\""
escape_test = 2 ; description="Line one\nLine two" ; note="Backslash: \\"

metadata: clear
plain_after_clear = 789
CONSTANTS
close $fh;

my $constants = RPN::Constants->new;
ok($constants->load_file($file), 'loaded metadata constants file');

is($constants->get('legacy'), 123, 'legacy equals syntax still loads');
is($constants->get('space_syntax'), 456, 'legacy space syntax still loads');

is($constants->get('c'), 299792458, 'metadata constant returns numeric value');

my %c_meta = $constants->metadata('c');
is($c_meta{category}, 'Physics', 'metadata default category inherited and normalized');
is($c_meta{source}, 'CODATA 2022', 'metadata default source inherited');
is($c_meta{units}, 'm/s', 'constant units parsed');
is($c_meta{description}, 'Speed of light in vacuum', 'constant description parsed');

my %g_meta = $constants->metadata('G');
is($g_meta{category}, 'Fundamental Physics', 'constant metadata overrides default metadata');
is($g_meta{source}, 'CODATA 2022', 'unoverridden metadata remains inherited');

my %quote_meta = $constants->metadata('quote_test');
is($quote_meta{description}, 'Euler said "Read Gauss."', 'escaped quotes parsed');

my %escape_meta = $constants->metadata('escape_test');
is($escape_meta{description}, "Line one\nLine two", 'escaped newline parsed');
is($escape_meta{note}, 'Backslash: \\', 'escaped backslash parsed');

my %plain_meta = $constants->metadata('plain_after_clear');
ok(!exists $plain_meta{category}, 'metadata clear removes inherited defaults');

my $record = $constants->record('c');
is($record->{value}, 299792458, 'record exposes value');
is($record->{metadata}{category}, 'Physics', 'record exposes metadata');

my $saved = "$dir/saved_constants.txt";
ok($constants->save_file($saved), 'saved metadata constants file');

my $roundtrip = RPN::Constants->new;
ok($roundtrip->load_file($saved), 'reloaded saved metadata constants file');
is($roundtrip->get('c'), 299792458, 'round-tripped value');
my %round_c_meta = $roundtrip->metadata('c');
is($round_c_meta{description}, 'Speed of light in vacuum', 'round-tripped metadata');
my %round_quote_meta = $roundtrip->metadata('quote_test');
is($round_quote_meta{description}, 'Euler said "Read Gauss."', 'round-tripped escaped quote metadata');

done_testing();
