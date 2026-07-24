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
my $chapter = $calc->examples_dir . '/03_functional_programming';

for my $file (
    qw(
        square_every_element.txt
        keep_even_values.txt
        sum_collection.txt
        product_collection.txt
        composable_functions.txt
        callbacks.txt
    )
) {
    ok($calc->functions->load_file("$chapter/$file"), "load $file");
}

$calc->process_input('2 3 4');
$calc->process_input('square_every');
is_deeply([$calc->stack->values], [16, 9, 4], 'map squares every value');

$calc->stack->clear;
$calc->process_input('1 2 3 4 5 6');
$calc->process_input('keep_even');
is_deeply([$calc->stack->values], [6, 4, 2], 'filter keeps even values');

$calc->stack->clear;
$calc->process_input('10 20 30 40');
$calc->process_input('sum_with_reduce');
is($calc->stack->pop, 100, 'reduce sums a collection');

$calc->process_input('2 3 4 5');
$calc->process_input('product_with_reduce');
is($calc->stack->pop, 120, 'reduce multiplies a collection');

$calc->process_input('10');
$calc->process_input('double_then_add_one');
is($calc->stack->pop, 21, 'small functions compose in order');

$calc->process_input('7');
$calc->process_input('square_callback');
$calc->process_input('run_callback');
is($calc->stack->pop, 49, 'square callback executes later');

$calc->process_input('7');
$calc->process_input('negate_callback');
$calc->process_input('run_callback');
is($calc->stack->pop, -7, 'negate callback executes later');

done_testing();
