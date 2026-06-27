use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

# use Test::Output;
use lib 't/lib';
use RPN::TestOutput;

use lib 'lib';
use RPN;

sub close_enough {
    my ($got, $expected, $name) = @_;

    ok(
        abs($got - $expected) < 1e-9,
        $name
    ) or diag("got $got expected $expected");
}

sub matrix_close_enough {
    my ($m, $expected, $name) = @_;

    ok(RPN::Matrix::is_matrix($m), "$name is matrix");

    for my $r (0 .. $m->rows - 1) {
        for my $c (0 .. $m->cols - 1) {
            close_enough(
                $m->get($r, $c),
                $expected->[$r][$c],
                "$name [$r,$c]"
            );
        }
    }
}

my $dir = tempdir(CLEANUP => 1);

$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";
$ENV{RPN_VARIABLES} = "$dir/variables";
$ENV{RPN_FUNCTIONS} = "$dir/functions";

my $calc = RPN->new(no_readline => 1);

#
# Matrix.pm inverse tests
#

matrix_close_enough(
    RPN::Matrix->new([5])->inverse,
    [[0.2]],
    '1x1 inverse'
);

matrix_close_enough(
    RPN::Matrix->new([1, 0], [0, 1])->inverse,
    [[1, 0], [0, 1]],
    'identity inverse'
);

matrix_close_enough(
    RPN::Matrix->new([1, 2], [3, 4])->inverse,
    [[-2, 1], [1.5, -0.5]],
    '2x2 inverse'
);

matrix_close_enough(
    RPN::Matrix->new([1, 2, 3], [0, 1, 4], [5, 6, 0])->inverse,
    [[-24, 18, 5], [20, -15, -4], [-5, 4, 1]],
    '3x3 inverse'
);

#
# inverse command
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2], [3, 4]));
$calc->process_input('inverse');

matrix_close_enough(
    $calc->stack->peek,
    [[-2, 1], [1.5, -0.5]],
    'inverse command'
);

#
# invm alias
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2], [3, 4]));
$calc->process_input('invm');

matrix_close_enough(
    $calc->stack->peek,
    [[-2, 1], [1.5, -0.5]],
    'invm alias'
);

#
# non-matrix preserves stack
#

$calc->stack->clear;
$calc->process_input("'hello");

stderr_like(
    sub { $calc->process_input('inverse') },
    qr/inverse requires a matrix/,
    'inverse rejects non-matrix'
);

is($calc->stack->peek, 'hello', 'non-matrix operand preserved');

#
# non-square matrix preserves stack
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2, 3], [4, 5, 6]));

stderr_like(
    sub { $calc->process_input('inverse') },
    qr/inverse requires a square matrix/,
    'inverse rejects non-square matrix'
);

is(
    $calc->format_value($calc->stack->peek),
    '[[1,2,3],[4,5,6]]',
    'non-square matrix preserved'
);

#
# singular matrix preserves stack
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2], [2, 4]));

stderr_like(
    sub { $calc->process_input('inverse') },
    qr/inverse requires a non-singular matrix/,
    'inverse rejects singular matrix'
);

is(
    $calc->format_value($calc->stack->peek),
    '[[1,2],[2,4]]',
    'singular matrix preserved'
);

done_testing();
