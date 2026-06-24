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

#
# ln
#

$calc->process_input('1');
$calc->process_input('ln');

ok(
    abs($calc->stack->pop) < 1e-10,
    'ln(1) = 0'
);

#
# exp
#

$calc->process_input('0');
$calc->process_input('exp');

ok(
    abs($calc->stack->pop - 1) < 1e-10,
    'exp(0) = 1'
);

#
# exp(ln(x))
#

$calc->process_input('5');
$calc->process_input('ln');
$calc->process_input('exp');

ok(
    abs($calc->stack->pop - 5) < 1e-10,
    'exp(ln(5)) = 5'
);

#
# log
#

$calc->process_input('1000');
$calc->process_input('log');

ok(
    abs($calc->stack->pop - 3) < 1e-10,
    'log10(1000) = 3'
);

#
# inv
#

$calc->process_input('4');
$calc->process_input('inv');

ok(
    abs($calc->stack->pop - 0.25) < 1e-10,
    'inv(4) = 0.25'
);

#
# abs positive
#

$calc->process_input('5');
$calc->process_input('abs');

is(
    $calc->stack->pop,
    5,
    'abs(5) = 5'
);

#
# abs negative
#

$calc->process_input('-5');
$calc->process_input('abs');

is(
    $calc->stack->pop,
    5,
    'abs(-5) = 5'
);

#
# log2
#

$calc->process_input('8');
$calc->process_input('log2');

ok(
    abs($calc->stack->pop - 3) < 1e-10,
    'log2(8) = 3'
);

#
# exp10
#

$calc->process_input('3');
$calc->process_input('exp10');

ok(
    abs($calc->stack->pop - 1000) < 1e-10,
    'exp10(3) = 1000'
);

#
# sqr
#

$calc->process_input('5');
$calc->process_input('sqr');

is(
    $calc->stack->pop,
    25,
    'sqr(5) = 25'
);

#
# cube
#

$calc->process_input('3');
$calc->process_input('cube');

is(
    $calc->stack->pop,
    27,
    'cube(3) = 27'
);

#
# cbrt positive
#

$calc->process_input('27');
$calc->process_input('cbrt');

ok(
    abs($calc->stack->pop - 3) < 1e-10,
    'cbrt(27) = 3'
);

#
# cbrt negative
#

$calc->process_input('-8');
$calc->process_input('cbrt');

ok(
    abs($calc->stack->pop + 2) < 1e-10,
    'cbrt(-8) = -2'
);

done_testing();
