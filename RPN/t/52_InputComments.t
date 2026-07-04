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

is($calc->strip_input_comment('42 # push answer'), '42 ', 'strip comment after input');
is($calc->strip_input_comment('# full-line comment'), '', 'strip full-line comment');
is($calc->strip_input_comment('"# not a comment"'), '"# not a comment"', 'preserve hash inside double quotes');
is($calc->strip_input_comment("'# not a comment'"), "'# not a comment'", 'preserve hash inside single quotes');
is($calc->strip_input_comment('"abc \\" # still string" # comment'), '"abc \\" # still string" ', 'escaped quote does not end string');

$calc->process_input('42 # this is ignored');
is($calc->stack->pop, 42, 'process_input ignores trailing comment');

$calc->process_input('# nothing happens');
is($calc->stack->depth, 0, 'comment-only input does nothing');

$calc->process_input('"hello # world" # trailing comment');
is($calc->stack->pop, 'hello # world', 'quoted string keeps hash content');

$calc->process_input('{ dup * } # square top stack item');
my $block = $calc->stack->pop;
ok(RPN::CodeBlock::is_codeblock($block), 'codeblock literal may have trailing comment');
is($block->as_string, '{ dup * }', 'comment is not part of codeblock source');

$calc->process_input('1 2 3 # numeric list comment');
is($calc->stack->pop, 3, 'numeric list ignores trailing comment: third value on top');
is($calc->stack->pop, 2, 'numeric list ignores trailing comment: second value next');
is($calc->stack->pop, 1, 'numeric list ignores trailing comment: first value last');

my $before = $calc->stack->depth;
$calc->process_input('unknown_command # comment');
is($calc->stack->depth, $before, 'unknown token with trailing comment still behaves as unknown token');

done_testing();
