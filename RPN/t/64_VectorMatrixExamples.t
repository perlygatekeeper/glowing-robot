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
        distance_between_points.txt
        average_vectors.txt
    )
) {
    ok(
        $calc->functions->load_file($calc->examples_dir . "/06_vectors/$file"),
        "load $file",
    );
}

for my $file (
    qw(
        identity_matrix.txt
        matrix_matrix.txt
        matrix_vector.txt
        rotation_matrix.txt
        reflection_matrix.txt
        transpose.txt
    )
) {
    ok(
        $calc->functions->load_file($calc->examples_dir . "/07_matrices/$file"),
        "load $file",
    );
}

$calc->process_input('1 2');
$calc->process_input('vec2');
$calc->process_input('4 6');
$calc->process_input('vec2');
$calc->process_input('distance_between');
is($calc->stack->pop, 5, 'distance-between example returns 5');

$calc->process_input('2 4');
$calc->process_input('vec2');
$calc->process_input('6 8');
$calc->process_input('vec2');
$calc->process_input('average_two_vectors');
is($calc->stack->pop->as_string, '[4,6]', 'average-vector example returns [4,6]');

$calc->process_input('compose_matrices');
is(
    $calc->stack->pop->as_string,
    '[[19,22],[43,50]]',
    'matrix-composition example has documented result',
);

$calc->process_input('apply_transform');
is($calc->stack->pop->as_string, '[17,39]', 'matrix-vector example has documented result');

$calc->process_input('1 0');
$calc->process_input('vec2');
$calc->process_input('rotate_90');
is($calc->stack->pop->as_string, '[0,1]', 'rotation example rotates counterclockwise');

$calc->process_input('3 4');
$calc->process_input('vec2');
$calc->process_input('reflect_x');
is($calc->stack->pop->as_string, '[3,-4]', 'reflection example negates y');

$calc->process_input('transpose_example');
is(
    $calc->stack->pop->as_string,
    '[[1,4],[2,5],[3,6]]',
    'transpose example has documented result',
);

done_testing();
