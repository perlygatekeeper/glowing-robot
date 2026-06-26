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
# matrix × vector
#

$calc->stack->clear;

$calc->stack->push(
    RPN::Matrix->new(
        [1,2],
        [3,4],
    )
);

$calc->stack->push(
    RPN::Vector->new(5,6)
);

$calc->process_input('mmul');

ok(
    RPN::Vector::is_vector(
        $calc->stack->peek
    ),
    'matrix*vector returns vector'
);

is(
    $calc->stack->peek->as_string,
    '[17,39]',
    'matrix*vector'
);

#
# vector × matrix
#

$calc->stack->clear;

$calc->stack->push(
    RPN::Vector->new(5,6)
);

$calc->stack->push(
    RPN::Matrix->new(
        [1,2],
        [3,4],
    )
);

$calc->process_input('mmul');

is(
    $calc->stack->peek->as_string,
    '[23,34]',
    'vector*matrix'
);

#
# identity matrix
#

my $identity = RPN::Matrix->new(
    [1,0],
    [0,1],
);

my $vector = RPN::Vector->new(7,9);

$calc->stack->clear;
$calc->stack->push($identity);
$calc->stack->push($vector);

$calc->process_input('mmul');

is(
    $calc->stack->peek->as_string,
    '[7,9]',
    'identity*vector'
);

#
# dimension mismatch
#

$calc->stack->clear;

$calc->stack->push(
    RPN::Matrix->new(
        [1,2,3],
        [4,5,6],
    )
);

$calc->stack->push(
    RPN::Vector->new(1,2)
);

stderr_like(
    sub {
        $calc->process_input('mmul');
    },
    qr/vector dimension/,
    'dimension mismatch warning'
);

is(
    $calc->stack->depth,
    2,
    'stack preserved'
);

#
# invalid operand
#

$calc->stack->clear;

$calc->process_input("'hello");

$calc->stack->push(
    RPN::Vector->new(1,2)
);

stderr_like(
    sub {
        $calc->process_input('mmul');
    },
    qr/mmul requires matrices or matrix\/vector operands/,
    'invalid operand warning'
);

is(
    $calc->stack->depth,
    2,
    'invalid operand preserves stack'
);

done_testing();
