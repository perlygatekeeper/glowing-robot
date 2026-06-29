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
        abs($got - $expected) < 1e-9,
        $name
    ) or diag("got $got expected $expected");
}

my $dir = tempdir(CLEANUP => 1);

$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";
$ENV{RPN_VARIABLES} = "$dir/variables";
$ENV{RPN_FUNCTIONS} = "$dir/functions";

my $calc = RPN->new(no_readline => 1);

$calc->stack->clear;
$calc->process_input('5');
$calc->process_input('factorial');
is($calc->stack->peek, 120, '5 factorial = 120');

$calc->stack->clear;
$calc->process_input('0');
$calc->process_input('factorial');
is($calc->stack->peek, 1, '0 factorial = 1');

$calc->stack->clear;
$calc->process_input('4');
$calc->process_input('2');
$calc->process_input('combinations');
is($calc->stack->peek, 6, '4 choose 2 combinations = 6');

$calc->stack->clear;
$calc->process_input('4');
$calc->process_input('2');
$calc->process_input('binom');
is($calc->stack->peek, 6, 'binom alias works');

$calc->stack->clear;
$calc->process_input('4');
$calc->process_input('2');
$calc->process_input('ncr');
is($calc->stack->peek, 6, 'ncr compatibility alias works');

$calc->stack->clear;
$calc->process_input('4');
$calc->process_input('2');
$calc->process_input('permutations');
is($calc->stack->peek, 12, '4 permute 2 permutations = 12');

$calc->stack->clear;
$calc->process_input('4');
$calc->process_input('2');
$calc->process_input('npr');
is($calc->stack->peek, 12, 'npr compatibility alias works');

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('3');
$calc->process_input('0.5');
$calc->process_input('binompdf');

close_enough(
    $calc->stack->peek,
    0.1171875,
    'binompdf 10 3 0.5'
);

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('3');
$calc->process_input('0.5');
$calc->process_input('binomcdf');

close_enough(
    $calc->stack->peek,
    0.171875,
    'binomcdf 10 3 0.5'
);

#
# invalid factorial preserves stack
#

$calc->stack->clear;
$calc->process_input("'hello");

stderr_like(
    sub { $calc->process_input('factorial') },
    qr/factorial requires a non-negative integer/,
    'factorial rejects non-number'
);

is($calc->stack->peek, 'hello', 'factorial preserves bad operand');

#
# invalid combinations preserves stack
#

$calc->stack->clear;
$calc->process_input('4');
$calc->process_input("'two");

stderr_like(
    sub { $calc->process_input('combinations') },
    qr/combinations requires non-negative integer operands/,
    'combinations rejects bad operand'
);

is($calc->stack->depth, 2, 'combinations preserves stack depth');
is($calc->stack->peek, 'two', 'combinations preserves top operand');

#
# invalid probability preserves stack
#

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('3');
$calc->process_input('2');

stderr_like(
    sub { $calc->process_input('binompdf') },
    qr/binompdf requires/,
    'binompdf rejects probability outside range'
);

is($calc->stack->depth, 3, 'binompdf preserves stack depth');
is($calc->stack->peek, 2, 'binompdf preserves top operand');

done_testing();
