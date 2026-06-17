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

done_testing();
