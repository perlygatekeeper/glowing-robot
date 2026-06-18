use strict;
use warnings;

use Test::More;
use Test::Output;

use lib 'lib';
use RPN;

my $calc = RPN->new();

#
# noop
#

$calc->process_input('123');

is(
    $calc->stack->peek,
    123,
    'stack starts with 123'
);

$calc->process_input('noop');

is(
    $calc->stack->peek,
    123,
    'noop leaves stack unchanged'
);

#
# version
#

stdout_like(
    sub { $calc->process_input('version') },
    qr/^RPN version /,
    'version command prints version string'
);

#
# aliases
#

stdout_like(
    sub { $calc->process_input('aliases') },
    qr/Command\s+Aliases/s,
    'aliases command prints header'
);

stdout_like(
    sub { $calc->process_input('aliases') },
    qr/add/s,
    'aliases output contains add command'
);

#
# abbreviations
#

stdout_like(
    sub { $calc->process_input('abbreviations') },
    qr/Command\s+Shortest/s,
    'abbreviations command prints header'
);

stdout_like(
    sub { $calc->process_input('abbreviations') },
    qr/add/s,
    'abbreviations output contains add command'
);

done_testing();