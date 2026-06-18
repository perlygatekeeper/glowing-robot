use strict;
use warnings;
use Test::More;
use Test::Output;

use lib 'lib';
use RPN;

my $calc = RPN->new();

#
# duplicate / dup
#

$calc->stack->clear;
$calc->process_input('42');
$calc->process_input('duplicate');

is($calc->stack->depth, 2, 'duplicate increases depth');
is($calc->stack->peek, 42, 'duplicate leaves copy on top');

#
# exchange / x
#

$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('2');
$calc->process_input('exchange');

is($calc->stack->peek, 1, 'exchange swaps top two values');

#
# depth
#

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('20');
$calc->process_input('depth');

is($calc->stack->peek, 2, 'depth pushes stack depth before depth command');

#
# pop
#

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('20');
$calc->process_input('pop');

is($calc->stack->peek, 10, 'pop removes top value');

#
# clear / clr
#

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('20');
$calc->process_input('clear');

is($calc->stack->depth, 0, 'clear empties stack');

#
# stack command reports current stack
#

stdout_like(
    sub { $calc->process_input('stack') },
    qr/Stack 's' is in use and has 0 elements\./,
    'stack reports current stack'
);

#
# stack command switches stacks
#

stdout_like(
    sub { $calc->process_input('stack work') },
    qr/Switched to stack 'work' \(0 deep\)/,
    'stack work switches to work stack'
);

is($calc->stack->current_name, 'work', 'current stack is work');

$calc->process_input('99');
is($calc->stack->peek, 99, 'work stack can receive values');

$calc->process_input('stack s');
is($calc->stack->current_name, 's', 'switched back to s');
is($calc->stack->depth, 0, 's stack still empty');

$calc->process_input('stack work');
is($calc->stack->peek, 99, 'work stack preserved its value');

#
# stack * lists stacks
#

stdout_like(
    sub { $calc->process_input('stack *') },
    qr/Stack\s+Depth.*s\s+0.*work\s+1/s,
    'stack * lists stack names and depths'
);

done_testing();