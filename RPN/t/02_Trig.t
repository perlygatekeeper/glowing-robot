use strict;
use warnings;

use Test::More;
# use Test::Output;
use lib 't/lib';
use RPN::TestOutput;

use lib 'lib';
use RPN;

my $calc = RPN->new();

#
# Degrees mode
#

$calc->stack->clear;
$calc->process_input('degrees');

$calc->process_input('90');
$calc->process_input('sine');

ok(
    abs($calc->stack->peek - 1.0) < 1e-10,
    'sin(90 degrees) == 1'
);

$calc->stack->clear;

$calc->process_input('degrees');
$calc->process_input('0');
$calc->process_input('cosine');

ok(
    abs($calc->stack->peek - 1.0) < 1e-10,
    'cos(0 degrees) == 1'
);

#
# Radians mode
#

$calc->stack->clear;

$calc->process_input('radians');
$calc->process_input('1.5707963267948966');
$calc->process_input('sine');

ok(
    abs($calc->stack->peek - 1.0) < 1e-10,
    'sin(pi/2 radians) == 1'
);

#
# Tangent valid
#

$calc->stack->clear;

$calc->process_input('degrees');
$calc->process_input('45');
$calc->process_input('tangent');

ok(
    abs($calc->stack->peek - 1.0) < 1e-10,
    'tan(45 degrees) == 1'
);

#
# Tangent undefined (degrees)
#

$calc->stack->clear;

$calc->process_input('degrees');
$calc->process_input('90');

stderr_like(
    sub { $calc->process_input('tangent') },
    qr/tangent undefined at 90/,
    'tan(90 degrees) warns'
);

is(
    $calc->stack->peek,
    90,
    'tan(90 degrees) leaves stack unchanged'
);

#
# Tangent undefined (radians)
#

$calc->stack->clear;

my $half_pi = 1.5707963267948966;

$calc->process_input('radians');
$calc->process_input($half_pi);

stderr_like(
    sub { $calc->process_input('tangent') },
    qr/tangent undefined/,
    'tan(pi\/2) warns'
);

ok(
    abs($calc->stack->peek - $half_pi) < 1e-12,
    'tan(pi/2) leaves stack unchanged'
);

done_testing();
