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

for my $file (
    qw(
        intermediate_values.txt
        scratch_stacks.txt
        common_idioms.txt
    )
) {
    ok(
        $calc->functions->load_file($calc->examples_dir . "/09_stack_techniques/$file"),
        "load $file",
    );
}

for my $file (
    qw(
        callbacks.txt
        conditional_behavior.txt
        transformations.txt
        selection.txt
        accumulation.txt
        custom_control_structures.txt
        functions_calling_functions.txt
        scratch_execution.txt
    )
) {
    ok(
        $calc->functions->load_file($calc->examples_dir . "/11_executable_values/$file"),
        "load $file",
    );
}

$calc->process_input('3 4');
$calc->process_input('hypotenuse');
is($calc->stack->pop, 5, 'intermediate-values example computes hypotenuse');

$calc->process_input('10 20 30');
$calc->process_input('sum_on_scratch');
is_deeply([$calc->stack->values], [60, 30, 20, 10], 'scratch sum preserves caller values');
$calc->stack->clear;

$calc->process_input('-12');
$calc->process_input('absolute_value');
is($calc->stack->pop, 12, 'conditional executable example computes absolute value');

$calc->process_input('1 2 3 4');
$calc->process_input('square_all_values');
is_deeply([reverse $calc->stack->values], [1, 4, 9, 16], 'map transformation squares values');

$calc->stack->clear;
$calc->process_input('-3 0 4 -1 8');
$calc->process_input('select_positive_values');
is_deeply([reverse $calc->stack->values], [4, 8], 'filter selection keeps positive values');

$calc->stack->clear;
$calc->process_input('1 2 3 4');
$calc->process_input('accumulate_product');
is($calc->stack->pop, 24, 'reduce accumulation multiplies values');

$calc->process_input('2');
$calc->process_input(q{"square"});
$calc->process_input('three_times');
is($calc->stack->pop, 256, 'custom control structure repeats executable value');

$calc->process_input('5');
$calc->process_input('double_then_square');
is($calc->stack->pop, 100, 'layered functions compose');

$calc->process_input('10 20 30');
$calc->process_input('average_on_scratch');
is_deeply([$calc->stack->values], [20, 30, 20, 10], 'scratch average preserves caller values');

done_testing();
