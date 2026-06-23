use strict;
use warnings;

use Test::More;
use Test::Output;
use File::Temp qw(tempdir);

use lib 'lib';

use RPN;
use RPN::Matrix;

my $dir = tempdir(CLEANUP => 1);

$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";
$ENV{RPN_VARIABLES} = "$dir/variables";
$ENV{RPN_FUNCTIONS} = "$dir/functions";

my $calc = RPN->new(no_readline => 1);

#
# Matrix.pm identity
#

is(
    RPN::Matrix->identity(3)->as_string,
    '[[1,0,0],[0,1,0],[0,0,1]]',
    'identity matrix'
);

#
# Matrix.pm power
#

is(
    RPN::Matrix->new([1, 2], [3, 4])->power(0)->as_string,
    '[[1,0],[0,1]]',
    'matrix power 0 returns identity'
);

is(
    RPN::Matrix->new([1, 2], [3, 4])->power(1)->as_string,
    '[[1,2],[3,4]]',
    'matrix power 1 returns original matrix'
);

is(
    RPN::Matrix->new([1, 2], [3, 4])->power(2)->as_string,
    '[[7,10],[15,22]]',
    'matrix power 2'
);

is(
    RPN::Matrix->new([1, 1], [1, 0])->power(5)->as_string,
    '[[8,5],[5,3]]',
    'fibonacci Q matrix power 5'
);

#
# mpow command
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2], [3, 4]));
$calc->process_input('2');
$calc->process_input('mpow');

is(
    $calc->stack->peek->as_string,
    '[[7,10],[15,22]]',
    'mpow command'
);

#
# bad exponent preserves stack
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2], [3, 4]));
$calc->process_input("'two");

stderr_like(
    sub { $calc->process_input('mpow') },
    qr/mpow requires a non-negative integer exponent/,
    'mpow rejects bad exponent'
);

is($calc->stack->depth, 2, 'bad exponent preserves stack depth');
is($calc->stack->peek, 'two', 'bad exponent preserves top');

#
# non-square preserves stack
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2, 3], [4, 5, 6]));
$calc->process_input('2');

stderr_like(
    sub { $calc->process_input('mpow') },
    qr/mpow requires a square matrix/,
    'mpow rejects non-square matrix'
);

is($calc->stack->depth, 2, 'non-square preserves stack depth');
is($calc->stack->peek, 2, 'non-square preserves exponent');

#
# non-matrix preserves stack
#

$calc->stack->clear;
$calc->process_input("'hello");
$calc->process_input('2');

stderr_like(
    sub { $calc->process_input('mpow') },
    qr/mpow requires a matrix and exponent/,
    'mpow rejects non-matrix'
);

is($calc->stack->depth, 2, 'non-matrix preserves stack depth');
is($calc->stack->peek, 2, 'non-matrix preserves exponent');

done_testing();