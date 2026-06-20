use strict;
use warnings;

use Test::More;
use Test::Output;

use lib 'lib';
use RPN;

sub close_enough {
    my ($got, $expected, $name) = @_;

    ok(
        abs($got - $expected) < 1e-6,
        $name
    ) or diag("got $got expected $expected");
}

my $calc = RPN->new(no_readline => 1);

#
# fv
#

$calc->stack->clear;
$calc->process_input('1000');
$calc->process_input('0.05');
$calc->process_input('10');
$calc->process_input('fv');

close_enough(
    $calc->stack->peek,
    1628.89462677744,
    'fv: 1000 at 5% for 10 periods'
);

#
# pv
#

$calc->stack->clear;
$calc->process_input('1628.89462677744');
$calc->process_input('0.05');
$calc->process_input('10');
$calc->process_input('pv');

close_enough(
    $calc->stack->peek,
    1000,
    'pv reverses fv'
);

#
# pmt
#

$calc->stack->clear;
$calc->process_input('1000');
$calc->process_input('0.01');
$calc->process_input('12');
$calc->process_input('pmt');

close_enough(
    $calc->stack->peek,
    88.8487886783416,
    'pmt: loan payment'
);

#
# pmt zero rate
#

$calc->stack->clear;
$calc->process_input('1200');
$calc->process_input('0');
$calc->process_input('12');
$calc->process_input('pmt');

close_enough(
    $calc->stack->peek,
    100,
    'pmt zero rate'
);

#
# nper
#

$calc->stack->clear;
$calc->process_input('1000');
$calc->process_input('0.01');
$calc->process_input('88.8487886783416');
$calc->process_input('nper');

close_enough(
    $calc->stack->peek,
    12,
    'nper reverses pmt'
);

#
# nper zero rate
#

$calc->stack->clear;
$calc->process_input('1200');
$calc->process_input('0');
$calc->process_input('100');
$calc->process_input('nper');

close_enough(
    $calc->stack->peek,
    12,
    'nper zero rate'
);

#
# nper impossible payment
#

$calc->stack->clear;
$calc->process_input('1000');
$calc->process_input('0.01');
$calc->process_input('5');

stderr_like(
    sub { $calc->process_input('nper') },
    qr/payment is too small/,
    'nper warns when payment cannot amortize loan'
);

#
# rate
#

$calc->stack->clear;
$calc->process_input('1000');
$calc->process_input('1628.89462677744');
$calc->process_input('10');
$calc->process_input('rate');

close_enough(
    $calc->stack->peek,
    0.05,
    'rate: CAGR-style periodic rate'
);

done_testing();