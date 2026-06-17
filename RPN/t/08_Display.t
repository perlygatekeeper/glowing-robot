use strict;
use warnings;
use Test::More;
use Test::Output;

use lib 'lib';
use RPN;

my $calc = RPN->new();

$calc->process_input('255');

stdout_is(
    sub { $calc->process_input('peek') },
    "255\n",
    'peek prints top value'
);

stdout_is(
    sub { $calc->process_input('hex') },
    "0xff\n",
    'hex prints top value in hexadecimal'
);

stdout_is(
    sub { $calc->process_input('oct') },
    "0377\n",
    'oct prints top value in octal'
);

stdout_is(
    sub { $calc->process_input('bin') },
    "11111111\n",
    'bin prints top value in binary'
);

stdout_is(
    sub { $calc->process_input('peekf "%7.2f"') },
    " 255.00\n",
    'peekf prints formatted top value'
);

stdout_is(
    sub { $calc->process_input('printf "%7.2f"') },
    " 255.00\n",
    'printf prints formatted top value'
);

is(
    $calc->stack->depth,
    0,
    'printf pops the value'
);

done_testing();