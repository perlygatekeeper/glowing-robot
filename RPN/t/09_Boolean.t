use strict;
use warnings;
use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new();

#
# Numeric
#

$calc->process_input('2');
$calc->process_input('3');
$calc->process_input('<');

is(
    $calc->stack->peek,
    1,
    '2 < 3'
);

$calc->stack->clear;

$calc->process_input('5');
$calc->process_input('5');
$calc->process_input('==');

is(
    $calc->stack->peek,
    1,
    '5 == 5'
);

$calc->stack->clear;

$calc->process_input('10');
$calc->process_input('3');
$calc->process_input('<=>');

is(
    $calc->stack->peek,
    1,
    '10 <=> 3'
);

#
# Strings
#

$calc->stack->clear;

$calc->process_input('"apple"');
$calc->process_input('"banana"');
$calc->process_input('lt');

is(
    $calc->stack->peek,
    1,
    'apple lt banana'
);

$calc->stack->clear;

$calc->process_input('"apple"');
$calc->process_input('"apple"');
$calc->process_input('eq');

is(
    $calc->stack->peek,
    1,
    'apple eq apple'
);

$calc->stack->clear;

$calc->process_input('"apple"');
$calc->process_input('"banana"');
$calc->process_input('cmp');

is(
    $calc->stack->peek,
    -1,
    'apple cmp banana'
);

done_testing();