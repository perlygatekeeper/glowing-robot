use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;

sub close_enough {
    my ($got, $expected, $name) = @_;

    ok(
        abs($got - $expected) < 1e-6,
        $name
    ) or diag("got $got expected $expected");
}

my $calc = RPN->new();

#
# Angle conversions
#

$calc->stack->clear;
$calc->process_input('180');
$calc->process_input('dtor');
close_enough($calc->stack->peek, 3.141592653589793, '180 dtor = pi');

$calc->stack->clear;
$calc->process_input('3.141592653589793');
$calc->process_input('rtod');
close_enough($calc->stack->peek, 180, 'pi rtod = 180');

#
# Temperature
#

$calc->stack->clear;
$calc->process_input('32');
$calc->process_input('ftoc');
close_enough($calc->stack->peek, 0, '32 ftoc = 0');

$calc->stack->clear;
$calc->process_input('100');
$calc->process_input('ctof');
close_enough($calc->stack->peek, 212, '100 ctof = 212');

#
# Distance
#

$calc->stack->clear;
$calc->process_input('1.609');
$calc->process_input('ktom');
close_enough($calc->stack->peek, 1, '1.609 ktom = 1');

$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('mtok');
close_enough($calc->stack->peek, 1.609, '1 mtok = 1.609');

$calc->stack->clear;
$calc->process_input('2.54');
$calc->process_input('ctoi');
close_enough($calc->stack->peek, 1, '2.54 ctoi = 1');

$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('itoc');
close_enough($calc->stack->peek, 2.54, '1 itoc = 2.54');

#
# Weight / mass
#

$calc->stack->clear;
$calc->process_input('28.3495');
$calc->process_input('gtoo');
close_enough($calc->stack->peek, 1, '28.3495 gtoo = 1');

$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('otog');
close_enough($calc->stack->peek, 28.3495, '1 otog = 28.3495');

$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('ktop');
close_enough($calc->stack->peek, 2.20458553791875, '1 ktop = 2.20458553791875');

$calc->stack->clear;
$calc->process_input('2.20458553791875');
$calc->process_input('ptok');
close_enough($calc->stack->peek, 1, '2.20458553791875 ptok = 1');

#
# Volume
#

$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('ltoq');
close_enough($calc->stack->peek, 1.05669, '1 ltoq = 1.05669');

$calc->stack->clear;
$calc->process_input('1.05669');
$calc->process_input('qtol');
close_enough($calc->stack->peek, 1, '1.05669 qtol = 1');

done_testing();