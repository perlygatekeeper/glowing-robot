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
my $chapter = $calc->examples_dir . '/12_transformations';

for my $file (
    qw(
        translation_2d.txt
        rotation_2d.txt
        scaling_shearing_2d.txt
        reflection_2d.txt
        composition_inverse_2d.txt
        translation_scaling_3d.txt
        axis_rotations_3d.txt
        plane_reflections_3d.txt
        composition_inverse_3d.txt
    )
) {
    ok($calc->functions->load_file("$chapter/$file"), "load $file");
}

$calc->process_input('3 4');
$calc->process_input('point2d');
$calc->process_input('move_right_5_down_2');
is($calc->stack->pop->as_string, '[8,2]', '2D translation recipe');

$calc->process_input('1 0');
$calc->process_input('point2d');
$calc->process_input('quarter_turn_2d');
my @turned = $calc->stack->pop->values;
ok(abs($turned[0]) < 1e-10 && abs($turned[1] - 1) < 1e-10, '2D rotation recipe');

$calc->process_input('1 1');
$calc->process_input('point2d');
$calc->process_input('scale_then_shear_2d');
is($calc->stack->pop->as_string, '[5,3]', '2D scale and shear recipe');

$calc->process_input('1 1');
$calc->process_input('point2d');
$calc->process_input('move_then_double_2d');
$calc->process_input('apply2d');
$calc->process_input('undo_move_then_double_2d');
$calc->process_input('apply2d');
is($calc->stack->pop->as_string, '[1,1]', '2D composition inverse recipe');

$calc->process_input('1 1 1');
$calc->process_input('point3d');
$calc->process_input('move_then_scale_3d');
is($calc->stack->pop->as_string, '[4,6,8]', '3D translation and scaling recipe');

$calc->process_input('0 1 0');
$calc->process_input('point3d');
$calc->process_input('quarter_turn_x');
my @x_turn = $calc->stack->pop->values;
ok(abs($x_turn[1]) < 1e-10 && abs($x_turn[2] - 1) < 1e-10, '3D axis rotation recipe');

$calc->process_input('1 2 3');
$calc->process_input('point3d');
$calc->process_input('mirror_across_xy');
is($calc->stack->pop->as_string, '[1,2,-3]', '3D plane reflection recipe');

$calc->process_input('1 1 1');
$calc->process_input('point3d');
$calc->process_input('move_then_turn_3d');
$calc->process_input('apply3d');
$calc->process_input('undo_move_then_turn_3d');
$calc->process_input('apply3d');
my @restored = $calc->stack->pop->values;
ok(
    abs($restored[0] - 1) < 1e-10
        && abs($restored[1] - 1) < 1e-10
        && abs($restored[2] - 1) < 1e-10,
    '3D composition inverse recipe',
);

done_testing();
