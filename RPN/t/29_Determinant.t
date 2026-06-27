use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

# use Test::Output;
use lib 't/lib';
use RPN::TestOutput;

use lib 'lib';
use RPN;

my $dir = tempdir(CLEANUP => 1);

$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";
$ENV{RPN_VARIABLES} = "$dir/variables";
$ENV{RPN_FUNCTIONS} = "$dir/functions";

my $calc = RPN->new(no_readline => 1);

#
# direct Matrix.pm determinant tests
#

is(
    RPN::Matrix->new([5])->determinant,
    5,
    '1x1 determinant'
);

is(
    RPN::Matrix->new([1, 2], [3, 4])->determinant,
    -2,
    '2x2 determinant'
);

is(
    RPN::Matrix->new([1, 0], [0, 1])->determinant,
    1,
    'unit 2x2 determinant'
);

is(
    RPN::Matrix->new([1, 0, 0], [0, 1, 0], [0, 0, 1])->determinant,
    1,
    'unit 3x3 determinant'
);

is(
    RPN::Matrix->new(
        [1, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1],
    )->determinant,
    1,
    'unit 4x4 determinant'
);

is(
    RPN::Matrix->new([1, 2], [2, 4])->determinant,
    0,
    'singular 2x2 determinant'
);

is(
    RPN::Matrix->new([1, 2, 3], [0, 4, 5], [1, 0, 6])->determinant,
    22,
    '3x3 determinant'
);

#
# determinant command
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2], [3, 4]));
$calc->process_input('determinant');

is(
    $calc->stack->peek,
    -2,
    'determinant command'
);

#
# det alias
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2], [3, 4]));
$calc->process_input('det');

is(
    $calc->stack->peek,
    -2,
    'det alias'
);

#
# non-matrix preserves stack
#

$calc->stack->clear;
$calc->process_input("'hello");

stderr_like(
    sub { $calc->process_input('determinant') },
    qr/determinant requires a matrix/,
    'determinant rejects non-matrix'
);

is($calc->stack->peek, 'hello', 'non-matrix operand preserved');

#
# non-square matrix preserves stack
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2, 3], [4, 5, 6]));

stderr_like(
    sub { $calc->process_input('determinant') },
    qr/determinant requires a square matrix/,
    'determinant rejects non-square matrix'
);

is(
    $calc->format_value($calc->stack->peek),
    '[[1,2,3],[4,5,6]]',
    'non-square matrix preserved'
);

done_testing();
