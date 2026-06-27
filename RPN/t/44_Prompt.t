#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;

sub new_calc {
    return RPN->new(no_readline => 1, @_);
}

my $calc = new_calc();
is($calc->prompt, 'RPN> ', 'default prompt is RPN>');
is($calc->current_prompt, 'RPN> ', 'current_prompt returns default prompt');

$calc = new_calc(prompt => 'Input [%TOS%] ');
is($calc->prompt, 'Input [-EMPTY-] ', 'empty stack expands TOS to -EMPTY-');

$calc->stack->push(42);
is($calc->prompt, 'Input [42] ', 'numeric top of stack expands into prompt');

$calc = new_calc(prompt => 'RPN[%DEPTH%]> ');
is($calc->prompt, 'RPN[0]> ', 'DEPTH expands for empty stack');
$calc->stack->push(1, 2, 3);
is($calc->prompt, 'RPN[3]> ', 'DEPTH expands for populated stack');

$calc = new_calc(prompt => '%StackName%> ');
my $initial_stack_name = $calc->stack->current_name;
is($calc->prompt, "$initial_stack_name> ", 'StackName expands to current stack name');
$calc->stack->switch('scratch');
is($calc->prompt, 'scratch> ', 'StackName expands to current named stack');

$calc = new_calc(prompt => '%StackName% [%DEPTH%] %TOS% > ');
$initial_stack_name = $calc->stack->current_name;
is($calc->prompt, "$initial_stack_name [0] -EMPTY- > ", 'multiple prompt substitutions expand together');
$calc->stack->push('hello');
is($calc->prompt, "$initial_stack_name [1] hello > ", 'multiple prompt substitutions reflect stack state');

$calc = new_calc(prompt => 'RPN %UNKNOWN% %DEPTH%> ');
is($calc->prompt, 'RPN %UNKNOWN% 0> ', 'unknown prompt substitutions are left unchanged');

$calc = new_calc(prompt => 'Calc> ');
is($calc->prompt, 'Calc> ', 'literal custom prompt is allowed');

$calc = new_calc(prompt => '%TOS% %TOS% ');
$calc->stack->push(7);
is($calc->prompt, '7 7 ', 'same prompt substitution can appear more than once');

done_testing();
