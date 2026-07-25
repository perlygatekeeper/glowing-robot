use v5.34;
use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

use lib 't/lib';
use RPN::TestOutput;

use lib 'lib';
use RPN;
use RPN::Matrix;
use RPN::Transform;
use RPN::Vector;

my $dir = tempdir(CLEANUP => 1);

local $ENV{RPN_HISTORY}    = "$dir/history";
local $ENV{RPN_STACKS}     = "$dir/stacks";
local $ENV{RPN_CONSTANTS}  = "$dir/constants";
local $ENV{RPN_VARIABLES}  = "$dir/variables";
local $ENV{RPN_FUNCTIONS}  = "$dir/functions";
local $ENV{RPN_CODEBLOCKS} = "$dir/codeblocks";

my $calc = RPN->new(install_dir => '.', no_readline => 1);

$calc->process_input('3 4');
$calc->process_input('vec2');
$calc->process_input('5 -2');
$calc->process_input('translate2d');
$calc->process_input('apply2d');
is($calc->stack->pop->as_string, '[8,2]', 'translate2d applies to a point');

$calc->process_input('degrees');
$calc->process_input('1 0');
$calc->process_input('vec2');
$calc->process_input('90');
$calc->process_input('rotate2d');
$calc->process_input('apply2d');
my @rotated = $calc->stack->pop->values;
ok(abs($rotated[0]) < 1e-10, 'rotate2d honors degree mode for x');
ok(abs($rotated[1] - 1) < 1e-10, 'rotate2d honors degree mode for y');

$calc->process_input('1 1');
$calc->process_input('vec2');
$calc->process_input('2 3');
$calc->process_input('translate2d');
$calc->process_input('2 2');
$calc->process_input('scale2d');
$calc->process_input('compose2d');
$calc->process_input('apply2d');
is($calc->stack->pop->as_string, '[6,8]', 'compose2d uses execution order');

$calc->process_input('7 -4');
$calc->process_input('vec2');
$calc->process_input('3 9');
$calc->process_input('translate2d');
$calc->process_input('apply2d');
$calc->process_input('3 9');
$calc->process_input('translate2d');
$calc->process_input('inverse2d');
$calc->process_input('apply2d');
is($calc->stack->pop->as_string, '[7,-4]', 'inverse2d reverses transformation');

$calc->process_input('identity2d');
ok(RPN::Transform::is_transform($calc->stack->peek), 'identity2d pushes transform');
$calc->process_input('transformmatrix');
ok(RPN::Matrix::is_matrix($calc->stack->peek), 'transformmatrix exposes matrix');
is($calc->stack->pop->as_string, '[[1,0,0],[0,1,0],[0,0,1]]', 'identity matrix is correct');

$calc->process_input('2 3');
$calc->process_input('vec2');
$calc->process_input('reflectx2d');
$calc->process_input('apply2d');
is($calc->stack->pop->as_string, '[2,-3]', 'reflectx2d reflects across x-axis');

$calc->process_input('2 3');
$calc->process_input('vec2');
$calc->process_input('reflecty2d');
$calc->process_input('apply2d');
is($calc->stack->pop->as_string, '[-2,3]', 'reflecty2d reflects across y-axis');

$calc->stack->clear;
$calc->process_input(q{'bad});
$calc->process_input('2');
stderr_like(
    sub { $calc->process_input('translate2d') },
    qr/parameters must be numbers/,
    'translate2d rejects nonnumeric parameters',
);
is_deeply([$calc->stack->values], [2, 'bad'], 'invalid translation preserves operands');

$calc->stack->clear;
$calc->process_input('1 2');
$calc->process_input('vec2');
$calc->process_input('3 4');
$calc->process_input('vec2');
stderr_like(
    sub { $calc->process_input('apply2d') },
    qr/requires a 2D point and 2D transform/,
    'apply2d rejects a non-transform operand',
);
is($calc->stack->depth, 2, 'invalid apply2d preserves operands');

done_testing();
