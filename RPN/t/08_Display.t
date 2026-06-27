use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

# use Test::Output;
use lib 't/lib';
use RPN::TestOutput;

use lib 'lib';
use RPN;

my $dir = tempdir(CLEANUP => 1);

$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";
$ENV{RPN_VARIABLES} = "$dir/variables";

my $calc = RPN->new(no_readline => 1);

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
