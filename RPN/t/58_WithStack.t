use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new(no_readline => 1);

$calc->stack->clear_all;
$calc->stack->push(10);
$calc->stack->switch('work');
$calc->stack->push(20);
$calc->stack->switch('default');

$calc->stack->push('work');
$calc->process_input('{ 2 * }');
$calc->process_input('withstack');

is($calc->stack->current_name, 'default', 'withstack restores original stack');
is($calc->stack->pop, 40, 'withstack returns top result to original stack');
is($calc->stack->pop, 10, 'withstack preserves original stack contents below result');

$calc->stack->switch('work');
is($calc->stack->current_name, 'work', 'can switch back to target stack');
is($calc->stack->depth, 0, 'withstack pops returned result from target stack');
$calc->stack->switch('default');

$calc->stack->clear_all;
$calc->stack->push('scratch');
$calc->process_input('{ 6 7 * }');
$calc->process_input('withstack');
is($calc->stack->current_name, 'default', 'withstack restores original stack after creating target');
is($calc->stack->pop, 42, 'withstack can use a newly-created stack');

$calc->stack->clear_all;
$calc->stack->push('bad');
$calc->stack->push(123);
$calc->process_input('withstack');
is($calc->stack->depth, 2, 'withstack invalid executable preserves stack');
is($calc->stack->pop, 123, 'withstack preserves invalid executable');
is($calc->stack->pop, 'bad', 'withstack preserves stack name on invalid executable');

done_testing();
