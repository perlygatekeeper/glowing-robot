use v5.34;
use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

use lib 'lib';
use RPN;

my $dir = tempdir(CLEANUP => 1);

local $ENV{RPN_HISTORY}    = "$dir/history";
local $ENV{RPN_STACKS}     = "$dir/stacks";
local $ENV{RPN_CONSTANTS}  = "$dir/constants";
local $ENV{RPN_VARIABLES}  = "$dir/variables";
local $ENV{RPN_FUNCTIONS}  = "$dir/functions";
local $ENV{RPN_CODEBLOCKS} = "$dir/codeblocks";

my $calc = RPN->new(install_dir => '.', no_readline => 1);
my $chapter = $calc->examples_dir . '/04_statistics';

for my $file (
    qw(
        normalize_dataset.txt
        z_scores.txt
        outlier_detection.txt
    )
) {
    ok($calc->functions->load_file("$chapter/$file"), "load $file");
}

$calc->variables->set(data_min => 10);
$calc->variables->set(data_max => 30);
$calc->process_input('10 15 20 30');
$calc->process_input('normalize_values');
is_deeply(
    [reverse $calc->stack->values],
    [0, 0.25, 0.5, 1],
    'normalization example maps values into zero-to-one range',
);

$calc->stack->clear;
$calc->variables->set(data_mean => 5);
$calc->variables->set(data_stddev => 2);
$calc->process_input('2 4 4 4 5 5 7 9');
$calc->process_input('zscore_values');
is_deeply(
    [reverse $calc->stack->values],
    [-1.5, -0.5, -0.5, -0.5, 0, 0, 1, 2],
    'z-score example standardizes the documented data set',
);

$calc->stack->clear;
$calc->process_input('2 4 4 4 5 5 7 9');
$calc->process_input('select_outliers');
is_deeply([reverse $calc->stack->values], [9], 'outlier example keeps |z| >= 2');

done_testing();
