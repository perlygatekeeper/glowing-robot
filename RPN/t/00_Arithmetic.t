use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new();

#
# Addition
#
$calc->stack->clear;
$calc->process_input('2');
$calc->process_input('3');
$calc->process_input('add');
is(
    $calc->stack->peek,
    5,
    '2 3 add = 5'
);

#
# Subtraction
#
$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('3');
$calc->process_input('subtract');
is(
    $calc->stack->peek,
    7,
    '10 3 subtract = 7'
);


#
# Multiplication
#
$calc->stack->clear;
$calc->process_input('4');
$calc->process_input('3');
$calc->process_input('multiply');
is(
    $calc->stack->peek,
    12,
    '4 3 multiply = 12'
);

#
# Divide
#
$calc->stack->clear;
$calc->process_input('12');
$calc->process_input('4');
$calc->process_input('divide');
is(
    $calc->stack->peek,
    3,
    '12 4 divide = 3'
);

$calc->stack->clear;
$calc->process_input('5');
$calc->process_input('square');
is($calc->stack->peek, 25, '5 square = 25');

$calc->stack->clear;
$calc->process_input('3');
$calc->process_input('cube');
is($calc->stack->peek, 27, '3 cube = 27');

$calc->stack->clear;
$calc->process_input('25');
$calc->process_input('sqrt');
is($calc->stack->peek, 5, '25 sqrt = 5');

$calc->stack->clear;
$calc->process_input('5');
$calc->process_input('negate');
is($calc->stack->peek, -5, '5 negate = -5');

$calc->stack->clear;
$calc->process_input('5');
$calc->process_input('increment');
is($calc->stack->peek, 6, '5 increment = 6');

$calc->stack->clear;
$calc->process_input('5');
$calc->process_input('decrement');
is($calc->stack->peek, 4, '5 decrement = 4');

$calc->stack->clear;
$calc->process_input('17');
$calc->process_input('5');
$calc->process_input('modulo');
is($calc->stack->peek, 2, '17 5 modulo = 2');

$calc->stack->clear;
$calc->process_input('2');
$calc->process_input('10');
$calc->process_input('exponentiate');
is($calc->stack->peek, 1024, '2 10 exponentiate = 1024');

done_testing();
