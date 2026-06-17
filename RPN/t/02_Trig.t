use strict;
use warnings;
use Test::More;

use lib 'lib';
use RPN;

sub close_enough {
    my ($got, $expected, $name) = @_;

    ok(
        abs($got - $expected) < 0.000001,
        $name
    ) or diag("got $got expected $expected");
}

my $calc = RPN->new();

$calc->process_input('0');
$calc->process_input('sine');
close_enough($calc->stack->peek, 0, 'sin(0 radians) = 0');

$calc->stack->clear;
$calc->process_input('0');
$calc->process_input('cosine');
close_enough($calc->stack->peek, 1, 'cos(0 radians) = 1');

$calc->stack->clear;
$calc->process_input('0');
$calc->process_input('tangent');
close_enough($calc->stack->peek, 0, 'tan(0 radians) = 0');

$calc->stack->clear;
$calc->process_input('degrees');
$calc->process_input('90');
$calc->process_input('sine');
close_enough($calc->stack->peek, 1, 'sin(90 degrees) = 1');

$calc->stack->clear;
$calc->process_input('degrees');
$calc->process_input('180');
$calc->process_input('cosine');
close_enough($calc->stack->peek, -1, 'cos(180 degrees) = -1');

$calc->stack->clear;
$calc->process_input('radians');
$calc->process_input('3.141592653589793');
$calc->process_input('sine');
close_enough($calc->stack->peek, 0, 'sin(pi radians) = 0');

$calc->stack->clear;
$calc->process_input('degrees');
$calc->process_input('90');
$calc->process_input('tangent');

is(
    $calc->stack->peek,
    90,
    'tan(90 degrees) leaves stack unchanged'
);

$calc->stack->clear;
$calc->process_input('radians');
$calc->process_input('1.5707963267948966');
$calc->process_input('tangent');

close_enough(
    $calc->stack->peek,
    1.5707963267948966,
    'tan(pi/2) leaves stack unchanged'
);

done_testing();
