use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new(no_readline => 1);

# Existing string repeat behavior remains: string count repeat
$calc->stack->clear;
$calc->stack->push('*');
$calc->stack->push(5);
$calc->process_input('repeat');
is($calc->stack->peek, '*****', 'repeat preserves string repetition behavior');

# Token String executable, preferred order: count executable repeat
$calc->stack->clear;
$calc->process_input('0');
$calc->process_input('3');
$calc->process_input('"increment"');
$calc->process_input('repeat');
is($calc->stack->peek, 3, 'repeat executes token string count times');

# CodeBlock executable, preferred order: count executable repeat
$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('4');
$calc->process_input('{ 2 * }');
$calc->process_input('repeat');
is($calc->stack->peek, 16, 'repeat executes CodeBlock count times');

# Zero repetitions do nothing beyond consuming count and executable
$calc->stack->clear;
$calc->process_input('7');
$calc->process_input('0');
$calc->process_input('{ increment }');
$calc->process_input('repeat');
is($calc->stack->peek, 7, 'repeat with zero count does not execute body');

# Invalid executable count preserves stack
$calc->stack->clear;
$calc->stack->push('not_a_count');
$calc->process_input('{ increment }');
$calc->process_input('repeat');
is($calc->stack->depth, 2, 'repeat invalid executable count preserves stack depth');
isa_ok($calc->stack->pop, 'RPN::CodeBlock', 'repeat preserves executable on invalid count');
is($calc->stack->pop, 'not_a_count', 'repeat preserves invalid count');

# Invalid string count preserves stack
$calc->stack->clear;
$calc->stack->push('x');
$calc->stack->push('not_a_count');
$calc->process_input('repeat');
is($calc->stack->depth, 2, 'repeat invalid string count preserves stack depth');
is($calc->stack->pop, 'not_a_count', 'repeat preserves invalid string count');
is($calc->stack->pop, 'x', 'repeat preserves string on invalid count');

done_testing();
