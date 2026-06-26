use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

# use Test::Output;
use lib 't/lib';
use RPN::TestOutput;

use lib 'lib';
use RPN;

sub close_enough {
    my ($got, $expected, $name) = @_;

    ok(
        defined($got) && abs($got - $expected) < 1e-10,
        $name
    ) or diag("got " . (defined($got) ? $got : '<undef>') . " expected $expected");
}

my $dir = tempdir(CLEANUP => 1);
$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";

my $calc = RPN->new(no_readline => 1);

#
# Built-in mathematical constants can be entered directly.
#

$calc->stack->clear;
$calc->process_input('pi');

close_enough(
    $calc->stack->peek,
    atan2(1,1) * 4,
    'pi'
);

$calc->stack->clear;
$calc->process_input('e');

close_enough(
    $calc->stack->peek,
    exp(1),
    'e'
);

$calc->stack->clear;
$calc->process_input('phi');

close_enough(
    $calc->stack->peek,
    (1 + sqrt(5)) / 2,
    'phi'
);

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
# Constants command can push by name.
#

$calc->stack->clear;
$calc->process_input('const pi');

close_enough(
    $calc->stack->peek,
    atan2(1,1) * 4,
    'const pi pushes pi'
);

#
# User constants.
#

$calc->stack->clear;
$calc->process_input('const answer 42');
$calc->process_input('answer');

is(
    $calc->stack->peek,
    42,
    'user constant can be entered directly'
);

$calc->stack->clear;
$calc->process_input('const gravity 9.80665');
$calc->process_input('const gravity');

close_enough(
    $calc->stack->peek,
    9.80665,
    'const gravity pushes user constant'
);

#
# Built-ins are protected.
#

stderr_like(
    sub { $calc->process_input('const pi 3') },
    qr/Cannot redefine built-in constant 'pi'/,
    'cannot redefine built-in pi'
);

stderr_like(
    sub { $calc->process_input('delconst pi') },
    qr/Cannot delete built-in constant 'pi'/,
    'cannot delete built-in pi'
);

#
# Delete user constant.
#

$calc->process_input('const temporary 123');
ok($calc->constants->exists('temporary'), 'temporary constant exists');

$calc->process_input('delconst temporary');
ok(!$calc->constants->exists('temporary'), 'temporary constant deleted');

#
# Constants listing.
#

stdout_like(
    sub { $calc->process_input('constants') },
    qr/pi\s+builtin/s,
    'constants output contains builtin pi'
);

stdout_like(
    sub { $calc->process_input('constants') },
    qr/gravity\s+user/s,
    'constants output contains user gravity'
);

done_testing();
