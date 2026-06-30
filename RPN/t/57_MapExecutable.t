#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;
use RPN::CodeBlock;

my $calc = RPN->new(no_readline => 1);

# CodeBlock executable: map over every current stack item.
$calc->process_input('1 2 3');
$calc->process_input('{ dup * }');
$calc->process_input('map');
is_deeply([$calc->stack->values], [9, 4, 1], 'map applies CodeBlock to each stack item and preserves stack order');

# Token String executable.
$calc->stack->clear;
$calc->process_input('2 3 4');
$calc->stack->push('2 *');
$calc->process_input('map');
is_deeply([$calc->stack->values], [8, 6, 4], 'map applies Token String executable to each stack item');

# Empty data stack is allowed when only executable is present.
$calc->stack->clear;
$calc->process_input('{ dup * }');
$calc->process_input('map');
is($calc->stack->depth, 0, 'map over an empty stack leaves an empty stack');

# Non-executable operand is rejected and stack is preserved.
$calc->stack->clear;
$calc->process_input('1 2 3 4');
$calc->process_input('map');
is_deeply([$calc->stack->values], [4, 3, 2, 1], 'map rejects non-executable top value and preserves stack');

# Executable must have net 1-in, 1-out stack behavior for each item.
$calc->stack->clear;
$calc->process_input('1 2 3');
$calc->process_input('{ dup }');
$calc->process_input('map');
is_deeply([$calc->stack->values], [RPN::CodeBlock->new(source => '{ dup }'), 3, 2, 1], 'map aborts and restores stack when executable leaves extra value');

# A dropping executable also violates the contract and restores the stack.
$calc->stack->clear;
$calc->process_input('1 2 3');
$calc->process_input('{ drop }');
$calc->process_input('map');
is($calc->stack->depth, 4, 'map restores full stack when executable removes value');
isa_ok($calc->stack->peek, 'RPN::CodeBlock', 'map restores executable on contract failure');

# map itself is registered and discoverable.
ok($calc->commands->commands->{map}, 'map command is registered');
is($calc->commands->commands->{map}{category}, 'execution', 'map is an execution command');


done_testing();
