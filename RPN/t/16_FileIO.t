use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

use lib 'lib';
use RPN;

my $dir = tempdir(CLEANUP => 1);

$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";

my $calc = RPN->new(no_readline => 1);

#
# readnums
#

my $nums = "$dir/numbers.txt";

open my $nums_fh, '>', $nums or die $!;
print $nums_fh "1 2 3\n";
print $nums_fh "4,5,6\n";
print $nums_fh "# comment\n";
print $nums_fh "7;8;9\n";
close $nums_fh;

$calc->stack->clear;
$calc->process_input("readnums $nums");

is($calc->stack->depth, 9, 'readnums pushes nine numbers');
is($calc->stack->peek, 9, 'readnums top value is last number');

#
# readcsv
#

my $csv = "$dir/data.csv";

open my $csv_fh, '>', $csv or die $!;
print $csv_fh "name,score,count\n";
print $csv_fh "alice,12,3\n";
print $csv_fh "bob,18,4\n";
print $csv_fh "carol,22,5\n";
close $csv_fh;

$calc->stack->clear;
$calc->process_input("readcsv $csv");

is($calc->stack->depth, 6, 'readcsv pushes numeric fields only');
is($calc->stack->peek, 5, 'readcsv top value is last numeric field');

#
# readcolumn by name
#

$calc->stack->clear;
$calc->process_input("readcolumn $csv score");

is($calc->stack->depth, 3, 'readcolumn by name pushes three values');
is($calc->stack->peek, 22, 'readcolumn score top value is 22');

#
# readcolumn by index
#

$calc->stack->clear;
$calc->process_input("readcolumn $csv 2");

is($calc->stack->depth, 3, 'readcolumn by index pushes three values');
is($calc->stack->peek, 5, 'readcolumn index 2 top value is 5');

#
# writecsv
#

my $out = "$dir/out.csv";

$calc->stack->clear;
$calc->process_input('10 20 30');
$calc->process_input("writecsv $out");

ok(-s $out, 'writecsv created output file');

open my $out_fh, '<', $out or die $!;
my @out_lines = <$out_fh>;
close $out_fh;

is($out_lines[0], "index,value\n", 'writecsv writes header');
is($out_lines[1], "0,\"30\"\n", 'writecsv writes top stack item first');
is($out_lines[3], "2,\"10\"\n", 'writecsv writes bottom stack item last');

#
# appendcsv
#

$calc->stack->clear;
$calc->process_input('40 50');
$calc->process_input("appendcsv $out");

open my $app_fh, '<', $out or die $!;
my @app_lines = <$app_fh>;
close $app_fh;

is(scalar @app_lines, 6, 'appendcsv appends two data lines');
is($app_lines[4], "3,\"50\"\n", 'appendcsv continues index numbering');
is($app_lines[5], "4,\"40\"\n", 'appendcsv appends remaining value');

done_testing();