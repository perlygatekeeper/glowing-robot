use strict;
use warnings;

use Test::More;
use Test::Output;
use File::Temp qw(tempdir);

use lib 'lib';

use RPN;

my $dir = tempdir(CLEANUP => 1);

$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";
$ENV{RPN_VARIABLES} = "$dir/variables";
$ENV{RPN_FUNCTIONS} = "$dir/functions";

my $calc = RPN->new(no_readline => 1);

sub make_stack {
    my ($name, @values) = @_;

    $calc->stack->switch($name);
    $calc->stack->clear;

    for my $value (@values) {
        $calc->stack->push($value);
    }

    $calc->stack->switch('default');

    return;
}

sub expect_stack_pop_order {
    my ($name, @expected) = @_;

    $calc->stack->switch($name);

    for my $expected (@expected) {
        is(
            $calc->stack->pop,
            $expected,
            "$name pop gives $expected"
        );
    }

    is(
        $calc->stack->depth,
        0,
        "$name is empty after expected pops"
    );

    $calc->stack->switch('default');

    return;
}

#
# stackexists
#

make_stack('A', 'A - bottom', 'A - middle', 'A - top');
make_stack('B', 'B - bottom', 'B - top');

$calc->stack->push('A');
$calc->process_input('stackexists');
is($calc->stack->pop, 1, 'stackexists true');

$calc->stack->push('NOPE');
$calc->process_input('stackexists');
is($calc->stack->pop, 0, 'stackexists false');

#
# stacksize
#

$calc->stack->push('A');
$calc->process_input('stacksize');
is($calc->stack->pop, 3, 'stacksize A is 3');

#
# copystack
#

$calc->process_input('copystack A C');

is($calc->stack->depth_of('A'), 3, 'copystack leaves source unchanged');
is($calc->stack->depth_of('C'), 3, 'copystack creates destination');

expect_stack_pop_order(
    'C',
    'A - top',
    'A - middle',
    'A - bottom',
);

#
# renamestack / movestack alias
#

$calc->process_input('renamestack C D');

ok(!$calc->stack->stack_exists('C'), 'renamestack removes old name');
ok( $calc->stack->stack_exists('D'), 'renamestack creates new name');

$calc->process_input('movestack D E');

ok(!$calc->stack->stack_exists('D'), 'movestack removes old name');
ok( $calc->stack->stack_exists('E'), 'movestack creates new name');

#
# clearstack
#

$calc->process_input('clearstack E');

is($calc->stack->depth_of('E'), 0, 'clearstack empties stack');

#
# deletestack / dropstack alias
#

make_stack('DELETE_ME', 'delete bottom', 'delete top');

ok(
    $calc->stack->stack_exists('DELETE_ME'),
    'test stack exists before delete'
);

$calc->process_input('deletestack DELETE_ME');

ok(
    !$calc->stack->stack_exists('DELETE_ME'),
    'deletestack removes named stack'
);

make_stack('DROP_ME', 'drop bottom', 'drop top');

$calc->process_input('dropstack DROP_ME');

ok(
    !$calc->stack->stack_exists('DROP_ME'),
    'dropstack alias removes named stack'
);

#
# deletestack protects default and current stack
#

$calc->process_input('deletestack default');

ok(
    $calc->stack->stack_exists('default'),
    'deletestack refuses to delete default stack'
);

make_stack('CURRENT_TEST', 'current bottom', 'current top');
$calc->stack->switch('CURRENT_TEST');

$calc->process_input('deletestack CURRENT_TEST');

ok(
    $calc->stack->stack_exists('CURRENT_TEST'),
    'deletestack refuses to delete current stack'
);

$calc->stack->switch('default');

#
# mergestacks
#

make_stack('M_SRC', 'M_SRC - bottom', 'M_SRC - middle', 'M_SRC - top');
make_stack('M_DST', 'M_DST - bottom', 'M_DST - top');

$calc->process_input('mergestacks M_SRC M_DST');

is($calc->stack->depth_of('M_SRC'), 3, 'mergestacks leaves source unchanged');
is($calc->stack->depth_of('M_DST'), 5, 'mergestacks appends to destination');

expect_stack_pop_order(
    'M_DST',
    'M_SRC - top',
    'M_SRC - middle',
    'M_SRC - bottom',
    'M_DST - top',
    'M_DST - bottom',
);

#
# pour
#

make_stack('P', 'P - bottom', 'P - middle', 'P - top');
make_stack('Q', 'Q - bottom', 'Q - middle', 'Q - top');

$calc->process_input('pour P Q');

is($calc->stack->depth_of('P'), 0, 'pour empties source');
is($calc->stack->depth_of('Q'), 6, 'pour adds all source values to destination');

expect_stack_pop_order(
    'Q',
    'P - bottom',
    'P - middle',
    'P - top',
    'Q - top',
    'Q - middle',
    'Q - bottom',
);

#
# stackinfo
#

stdout_like(
    sub { $calc->process_input('stackinfo') },
    qr/^Stack\s+Depth\s+Current/m,
    'stackinfo prints header'
);

done_testing();
