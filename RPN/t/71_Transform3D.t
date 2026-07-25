use v5.34;
use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

use lib 'lib';
use RPN;
use RPN::Transform;
use RPN::Vector;

sub point_is {
    my ($point, $expected, $name) = @_;
    my @got = $point->values;
    for my $i (0 .. $#$expected) {
        ok(
            abs($got[$i] - $expected->[$i]) < 1e-10,
            "$name component $i",
        ) or diag("got $got[$i], expected $expected->[$i]");
    }
}

my $quarter_turn = atan2(1, 1) * 2;
my $point = RPN::Vector->new(1, 2, 3);

point_is(
    RPN::Transform->translation3d(4, -2, 5)->apply($point),
    [5, 0, 8],
    '3D translation',
);

point_is(
    RPN::Transform->scaling3d(2, 3, 4)->apply($point),
    [2, 6, 12],
    '3D scaling',
);

point_is(
    RPN::Transform->rotation_x3d($quarter_turn)
        ->apply(RPN::Vector->new(0, 1, 0)),
    [0, 0, 1],
    'x-axis rotation',
);

point_is(
    RPN::Transform->rotation_y3d($quarter_turn)
        ->apply(RPN::Vector->new(0, 0, 1)),
    [1, 0, 0],
    'y-axis rotation',
);

point_is(
    RPN::Transform->rotation_z3d($quarter_turn)
        ->apply(RPN::Vector->new(1, 0, 0)),
    [0, 1, 0],
    'z-axis rotation',
);

point_is(
    RPN::Transform->reflection_xy3d->apply($point),
    [1, 2, -3],
    'xy-plane reflection',
);

point_is(
    RPN::Transform->reflection_xz3d->apply($point),
    [1, -2, 3],
    'xz-plane reflection',
);

point_is(
    RPN::Transform->reflection_yz3d->apply($point),
    [-1, 2, 3],
    'yz-plane reflection',
);

my $composed = RPN::Transform->translation3d(1, 2, 3)
    ->then(RPN::Transform->scaling3d(2, 2, 2));
point_is(
    $composed->apply(RPN::Vector->new(1, 1, 1)),
    [4, 6, 8],
    '3D composition',
);
point_is(
    $composed->inverse->apply($composed->apply($point)),
    [1, 2, 3],
    '3D inverse',
);

my $dir = tempdir(CLEANUP => 1);
local $ENV{RPN_HISTORY}    = "$dir/history";
local $ENV{RPN_STACKS}     = "$dir/stacks";
local $ENV{RPN_CONSTANTS}  = "$dir/constants";
local $ENV{RPN_VARIABLES}  = "$dir/variables";
local $ENV{RPN_FUNCTIONS}  = "$dir/functions";
local $ENV{RPN_CODEBLOCKS} = "$dir/codeblocks";

my $calc = RPN->new(install_dir => '.', no_readline => 1);

$calc->process_input('1 2 3');
$calc->process_input('point3d');
$calc->process_input('4 -2 5');
$calc->process_input('translate3d');
$calc->process_input('apply3d');
is($calc->stack->pop->as_string, '[5,0,8]', 'translate3d command');

$calc->process_input('degrees');
$calc->process_input('1 0 0');
$calc->process_input('point3d');
$calc->process_input('90');
$calc->process_input('rotatez3d');
$calc->process_input('apply3d');
my @rotated = $calc->stack->pop->values;
ok(abs($rotated[0]) < 1e-10, 'rotatez3d command x');
ok(abs($rotated[1] - 1) < 1e-10, 'rotatez3d command y');
ok(abs($rotated[2]) < 1e-10, 'rotatez3d command z');

$calc->process_input('0 0 0');
$calc->process_input('point3d');
$calc->process_input('2 3 6');
$calc->process_input('point3d');
$calc->process_input('distance3d');
is($calc->stack->pop, 7, 'distance3d computes Euclidean distance');

$calc->process_input('0 0');
$calc->process_input('point2d');
$calc->process_input('3 4');
$calc->process_input('point2d');
$calc->process_input('distance2d');
is($calc->stack->pop, 5, 'distance2d computes Euclidean distance');

$calc->process_input('1 1 1');
$calc->process_input('point3d');
$calc->process_input('1 2 3');
$calc->process_input('translate3d');
$calc->process_input('2 2 2');
$calc->process_input('scale3d');
$calc->process_input('compose3d');
$calc->process_input('apply3d');
is($calc->stack->pop->as_string, '[4,6,8]', 'compose3d uses execution order');

done_testing();
