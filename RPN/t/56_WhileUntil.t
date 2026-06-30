use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new(no_readline => 1);

# while with CodeBlock executables: condition-exec body-exec while
$calc->stack->clear;
$calc->process_input('3');
$calc->process_input('{ dup 0 > }');
$calc->process_input('{ decrement }');
$calc->process_input('while');
is($calc->stack->peek, 0, 'while executes body until condition becomes false');

# while skips body when condition is false initially
$calc->stack->clear;
$calc->process_input('0');
$calc->process_input('{ dup 0 > }');
$calc->process_input('{ decrement }');
$calc->process_input('while');
is($calc->stack->peek, 0, 'while skips body when condition is initially false');

# until with CodeBlock executables: condition-exec body-exec until
$calc->stack->clear;
$calc->process_input('0');
$calc->process_input('{ dup 3 >= }');
$calc->process_input('{ increment }');
$calc->process_input('until');
is($calc->stack->peek, 3, 'until executes body until condition becomes true');

# until skips body when condition is true initially
$calc->stack->clear;
$calc->process_input('3');
$calc->process_input('{ dup 3 >= }');
$calc->process_input('{ increment }');
$calc->process_input('until');
is($calc->stack->peek, 3, 'until skips body when condition is initially true');

# while accepts Token String executables
$calc->stack->clear;
$calc->process_input('2');
$calc->stack->push('dup 0 >');
$calc->stack->push('decrement');
$calc->process_input('while');
is($calc->stack->peek, 0, 'while accepts Token String executables');

# until accepts Token String executables
$calc->stack->clear;
$calc->process_input('0');
$calc->stack->push('dup 2 >=');
$calc->stack->push('increment');
$calc->process_input('until');
is($calc->stack->peek, 2, 'until accepts Token String executables');

# invalid executable values preserve stack before execution begins
$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('2');
$calc->process_input('while');
is($calc->stack->depth, 2, 'invalid while preserves stack depth');
is($calc->stack->pop, 2, 'invalid while preserves top value');
is($calc->stack->pop, 1, 'invalid while preserves lower value');

$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('2');
$calc->process_input('until');
is($calc->stack->depth, 2, 'invalid until preserves stack depth');
is($calc->stack->pop, 2, 'invalid until preserves top value');
is($calc->stack->pop, 1, 'invalid until preserves lower value');

# condition executable must leave a condition value
$calc->stack->clear;
$calc->process_input('{ noop }');
$calc->process_input('{ increment }');
$calc->process_input('while');
is($calc->stack->depth, 0, 'while aborts when condition leaves no value');

done_testing();
