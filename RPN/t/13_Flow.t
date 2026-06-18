use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new();

#
# execute
#

$calc->stack->clear;
$calc->process_input('2');
$calc->process_input('3');
$calc->process_input('"add"');
$calc->process_input('execute');

is($calc->stack->peek, 5, 'execute runs command string from stack');

#
# if true
#

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('"increment"');
$calc->process_input('1');
$calc->process_input('if');

is($calc->stack->peek, 11, 'if executes command when true');

#
# if false
#

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('"increment"');
$calc->process_input('0');
$calc->process_input('if');

is($calc->stack->peek, 10, 'if does not execute command when false');

#
# ifelse true
#

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('"decrement"');
$calc->process_input('"increment"');
$calc->process_input('1');
$calc->process_input('ifelse');

is($calc->stack->peek, 11, 'ifelse executes true command');

#
# ifelse false
#

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('"decrement"');
$calc->process_input('"increment"');
$calc->process_input('0');
$calc->process_input('ifelse');

is($calc->stack->peek, 9, 'ifelse executes false command');

done_testing();
