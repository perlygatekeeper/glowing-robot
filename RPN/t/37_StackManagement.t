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
    $calc->stack->push(@values);
    $calc->stack->switch('default');

    return;
}

sub stack_values {
    my ($name) = @_;
    return [ @{ $calc->stack->get_stack($name) } ];
}

make_stack('A', 1, 2, 3);
make_stack('B', 8, 9);

#
# stackexists
#

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

is($calc->stack->depth_of('C'), 3, 'copystack created destination');

is_deeply(
    stack_values('C'),
    stack_values('A'),
    'copystack preserves order'
);

#
# renamestack / movestack alias
#

$calc->process_input('renamestack C D');

ok(!$calc->stack->stack_exists('C'), 'renamestack removed old name');
ok( $calc->stack->stack_exists('D'), 'renamestack created new name');

$calc->process_input('movestack D E');

ok(!$calc->stack->stack_exists('D'), 'movestack removed old name');
ok( $calc->stack->stack_exists('E'), 'movestack created new name');

#
# clearstack
#

$calc->process_input('clearstack E');

is($calc->stack->depth_of('E'), 0, 'clearstack empties stack');

#
# mergestacks
#

$calc->process_input('mergestacks A B');

is($calc->stack->depth_of('A'), 3, 'mergestacks leaves source unchanged');
is($calc->stack->depth_of('B'), 5, 'mergestacks appends to destination');

#
# pour
#

make_stack('P', 1, 2, 3);
make_stack('Q', 8, 9);

$calc->process_input('pour P Q');

is($calc->stack->depth_of('P'), 0, 'pour empties source');
is($calc->stack->depth_of('Q'), 5, 'pour adds all source values to destination');

$calc->stack->switch('Q');

is($calc->stack->pop, 1, 'pour result top is original bottom of source');
is($calc->stack->pop, 2, 'pour result next is middle of source');
is($calc->stack->pop, 3, 'pour result next is original top of source');
is($calc->stack->pop, 9, 'pour then reveals original destination top');
is($calc->stack->pop, 8, 'pour then reveals original destination bottom');

$calc->stack->switch('default');

#
# stackinfo
#

stdout_like(
    sub { $calc->process_input('stackinfo') },
    qr/^Stack\s+Depth\s+Current/m,
    'stackinfo prints header'
);

#
# deletestack / dropstack alias
#

make_stack('DELETE_ME', 1, 2, 3);

ok(
    $calc->stack->stack_exists('DELETE_ME'),
    'test stack exists before delete'
);

$calc->process_input('deletestack DELETE_ME');

ok(
    !$calc->stack->stack_exists('DELETE_ME'),
    'deletestack removes named stack'
);

make_stack('DROP_ME', 4, 5, 6);

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

make_stack('CURRENT_TEST', 7, 8, 9);
$calc->stack->switch('CURRENT_TEST');

$calc->process_input('deletestack CURRENT_TEST');

ok(
    $calc->stack->stack_exists('CURRENT_TEST'),
    'deletestack refuses to delete current stack'
);

$calc->stack->switch('default');

done_testing();
