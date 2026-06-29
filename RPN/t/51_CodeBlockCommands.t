#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

use lib 't/lib';
use RPN::TestOutput;

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

ok($calc->codeblocks, 'calculator owns a CodeBlocks registry');
ok($calc->commands->registered_command('codeblocks'), 'codeblocks command is registered');
ok($calc->commands->registered_command('showblock'), 'showblock command is registered');
ok($calc->commands->registered_command('iscodeblock'), 'iscodeblock command is registered');

stdout_like(
    sub { $calc->process_input('codeblocks') },
    qr/No code blocks defined\./,
    'codeblocks reports an empty registry'
);

$calc->codeblocks->define(square => RPN::CodeBlock->new(source => '{ dup * }'));
$calc->codeblocks->define(cube   => RPN::CodeBlock->new(source => '{ dup dup * * }'));

my $listing = stdout_from { $calc->process_input('codeblocks') };
like($listing, qr/Name\s+Source/, 'codeblocks prints table header');
like($listing, qr/^cube\s+\{ dup dup \* \* \}$/m, 'codeblocks lists cube');
like($listing, qr/^square\s+\{ dup \* \}$/m, 'codeblocks lists square');

stdout_like(
    sub { $calc->process_input('showblock square') },
    qr/^square = \{ dup \* \}$/,
    'showblock displays the named code block'
);

stderr_like(
    sub { $calc->process_input('showblock') },
    qr/usage: showblock NAME/,
    'showblock without a name reports usage'
);

stderr_like(
    sub { $calc->process_input('showblock nosuch') },
    qr/No such code block 'nosuch'/,
    'showblock reports missing blocks'
);

$calc->stack->clear;
$calc->stack->push(RPN::CodeBlock->new(source => '{ 2 * }'));
$calc->process_input('iscodeblock');
is($calc->stack->pop, 1, 'iscodeblock pushes true for a CodeBlock');
ok(RPN::CodeBlock::is_codeblock($calc->stack->peek), 'iscodeblock preserves original CodeBlock');

$calc->stack->clear;
$calc->stack->push(42);
$calc->process_input('iscodeblock');
is($calc->stack->pop, 0, 'iscodeblock pushes false for non-CodeBlock values');
is($calc->stack->peek, 42, 'iscodeblock preserves original non-CodeBlock value');

$calc->save_all;
ok(-s $ENV{RPN_CODEBLOCKS}, 'save_all writes codeblocks persistence file');

my $calc2 = RPN->new(no_readline => 1);
ok($calc2->codeblocks->exists('square'), 'new calculator loads persisted codeblock');
is($calc2->codeblocks->get('square')->as_string, '{ dup * }', 'loaded codeblock has expected source');

done_testing();
