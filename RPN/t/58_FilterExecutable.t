#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

use lib 'lib';
use RPN;
use RPN::CodeBlock;

my $dir = tempdir(CLEANUP => 1);
$ENV{RPN_HISTORY}    = "$dir/history";
$ENV{RPN_STACKS}     = "$dir/stacks";
$ENV{RPN_CONSTANTS}  = "$dir/constants";
$ENV{RPN_VARIABLES}  = "$dir/variables";
$ENV{RPN_FUNCTIONS}  = "$dir/functions";
$ENV{RPN_CODEBLOCKS} = "$dir/codeblocks";

my $calc = RPN->new(no_readline => 1);

# CodeBlock predicate: keep even values. Predicate consumes one item and
# leaves one truth value; filter preserves/discards the original item.
$calc->process_input('1 2 3 4 5');
$calc->process_input('{ 2 % 0 == }');
$calc->process_input('filter');
is_deeply([$calc->stack->values], [4, 2], 'filter keeps values whose CodeBlock predicate returns true');

# Token String predicate.
$calc->stack->clear;
$calc->process_input('1 2 3 4 5');
$calc->stack->push('3 >');
$calc->process_input('filter');
is_deeply([$calc->stack->values], [5, 4], 'filter accepts Token String predicates');

# All kept.
$calc->stack->clear;
$calc->process_input('1 2 3');
$calc->process_input('{ drop 1 }');
$calc->process_input('filter');
is_deeply([$calc->stack->values], [3, 2, 1], 'filter can keep every item');

# None kept.
$calc->stack->clear;
$calc->process_input('1 2 3');
$calc->process_input('{ drop 0 }');
$calc->process_input('filter');
is($calc->stack->depth, 0, 'filter can discard every item');

# Empty data stack is allowed when only executable is present.
$calc->stack->clear;
$calc->process_input('{ drop 1 }');
$calc->process_input('filter');
is($calc->stack->depth, 0, 'filter over an empty stack leaves an empty stack');

# Non-executable operand is rejected and stack is preserved.
$calc->stack->clear;
$calc->process_input('1 2 3 4');
{
    local $SIG{__WARN__} = sub { };
    $calc->process_input('filter');
}
is_deeply([$calc->stack->values], [4, 3, 2, 1], 'filter rejects non-executable top value and preserves stack');

# Predicate must have net 1-in, 1-out behavior for each item. If it leaves
# an extra value, filter aborts and restores the original stack.
$calc->stack->clear;
$calc->process_input('1 2 3');
$calc->process_input('{ dup }');
{
    local $SIG{__WARN__} = sub { };
    $calc->process_input('filter');
}
is($calc->stack->depth, 4, 'filter restores full stack when predicate leaves an extra value');
isa_ok($calc->stack->peek, 'RPN::CodeBlock', 'filter restores executable on contract failure');

# A dropping predicate also violates the contract and restores the stack.
$calc->stack->clear;
$calc->process_input('1 2 3');
$calc->process_input('{ drop }');
{
    local $SIG{__WARN__} = sub { };
    $calc->process_input('filter');
}
is($calc->stack->depth, 4, 'filter restores full stack when predicate leaves no truth value');
isa_ok($calc->stack->peek, 'RPN::CodeBlock', 'filter restores executable after missing truth value');

# filter itself is registered and discoverable.
ok($calc->commands->commands->{filter}, 'filter command is registered');
is($calc->commands->commands->{filter}{category}, 'execution', 'filter is an execution command');


done_testing();
