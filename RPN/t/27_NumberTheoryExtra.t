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
# primorial
#

$calc->stack->clear;
$calc->process_input('5');
$calc->process_input('primorial');
is($calc->stack->peek, 30, '5 primorial');

$calc->stack->clear;
$calc->process_input('11');
$calc->process_input('primorial');
is($calc->stack->peek, 2310, '11 primorial');

#
# mobius
#

$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('mobius');
is($calc->stack->peek, 1, 'mobius(1)');

$calc->stack->clear;
$calc->process_input('6');
$calc->process_input('mobius');
is($calc->stack->peek, 1, 'mobius(6)');

$calc->stack->clear;
$calc->process_input('30');
$calc->process_input('mobius');
is($calc->stack->peek, -1, 'mobius(30)');

$calc->stack->clear;
$calc->process_input('12');
$calc->process_input('mobius');
is($calc->stack->peek, 0, 'mobius(12)');

#
# mertens
#

$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('mertens');
is($calc->stack->peek, 1, 'mertens(1)');

$calc->stack->clear;
$calc->process_input('2');
$calc->process_input('mertens');
is($calc->stack->peek, 0, 'mertens(2)');

$calc->stack->clear;
$calc->process_input('3');
$calc->process_input('mertens');
is($calc->stack->peek, -1, 'mertens(3)');

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('mertens');
is($calc->stack->peek, -1, 'mertens(10)');

#
# invalid operand preserves stack
#

$calc->stack->clear;
$calc->process_input("'hello");

stderr_like(
    sub { $calc->process_input('mobius') },
    qr/positive integer/,
    'mobius rejects invalid operand'
);

is($calc->stack->peek, 'hello', 'operand preserved');

done_testing();
