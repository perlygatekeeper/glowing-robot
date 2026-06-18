use strict;
use warnings;

use Test::More;
use Test::Output;

use lib 'lib';
use RPN;

sub close_enough {
    my ($got, $expected, $name) = @_;

    ok(
        abs($got - $expected) < 1e-10,
        $name
    );
}

my $calc = RPN->new();

#
# pi
#

$calc->stack->clear;
$calc->process_input('pi');

close_enough(
    $calc->stack->peek,
    atan2(1,1) * 4,
    'pi'
);

#
# e
#

$calc->stack->clear;
$calc->process_input('e');

close_enough(
    $calc->stack->peek,
    exp(1),
    'e'
);

#
# square roots
#

$calc->stack->clear;
$calc->process_input('r2');

close_enough(
    $calc->stack->peek,
    sqrt(2),
    'r2'
);

$calc->stack->clear;
$calc->process_input('r3');

close_enough(
    $calc->stack->peek,
    sqrt(3),
    'r3'
);

#
# Avogadro
#

$calc->stack->clear;
$calc->process_input('av');

ok(
    $calc->stack->peek > 6e23,
    'av constant'
);

#
# constants listing
#

stdout_like(
    sub { $calc->process_input('constants') },
    qr/pi/s,
    'constants output contains pi'
);

stdout_like(
    sub { $calc->process_input('constants') },
    qr/e/s,
    'constants output contains e'
);

done_testing();