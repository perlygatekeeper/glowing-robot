use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new(no_readline => 1);

#
# now
#

$calc->stack->clear;
$calc->process_input('now');

my $epoch = $calc->stack->peek;

ok($epoch > 1700000000, 'now returns plausible epoch');

#
# today
#

$calc->stack->clear;
$calc->process_input('today');

like(
    $calc->stack->peek,
    qr/^\d{4}-\d{2}-\d{2}$/,
    'today format'
);

#
# time
#

$calc->stack->clear;
$calc->process_input('time');

like(
    $calc->stack->peek,
    qr/^\d{2}:\d{2}:\d{2}$/,
    'time format'
);

#
# datetime
#

$calc->stack->clear;
$calc->process_input('datetime');

like(
    $calc->stack->peek,
    qr/^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}$/,
    'datetime format'
);

done_testing();