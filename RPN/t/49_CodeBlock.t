#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN::CodeBlock;

my $block = RPN::CodeBlock->new(source => '{ dup * }');

ok(RPN::CodeBlock::is_codeblock($block), 'created object is a CodeBlock');
is($block->source, '{ dup * }', 'source is normalized and preserved');
is($block->body, 'dup *', 'body excludes outer braces');
is($block->as_string, '{ dup * }', 'as_string returns source form');

my @steps = $block->steps;
is(scalar @steps, 2, 'two steps parsed');
is_deeply(
    \@steps,
    [
        { kind => 'command', token => 'dup' },
        { kind => 'command', token => '*'   },
    ],
    'command steps are classified'
);

my $body_block = RPN::CodeBlock->new(body => '  42 "hello" +  ');
is($body_block->source, '{ 42 "hello" + }', 'body constructor builds canonical source');
is($body_block->body, '42 "hello" +', 'body constructor trims body');

my @typed_steps = $body_block->steps;
is_deeply(
    \@typed_steps,
    [
        { kind => 'number',  token => '42',      value => 42 },
        { kind => 'string',  token => '"hello"', value => 'hello' },
        { kind => 'command', token => '+' },
    ],
    'basic step classification recognizes numbers and quoted strings'
);

my $empty = RPN::CodeBlock->new(source => '{   }');
is($empty->source, '{ }', 'empty block has canonical source');
is($empty->body, '', 'empty block has empty body');
is(scalar $empty->steps, 0, 'empty block has no steps');

my @copied_steps = $block->steps;
$copied_steps[0]{token} = 'drop';
my @fresh_steps = $block->steps;
is($fresh_steps[0]{token}, 'dup', 'steps returns copies, not internal hashes');

my $error = eval { RPN::CodeBlock->new(source => 'dup *'); 1 };
ok(!$error, 'source without braces dies');
like($@, qr/begin with \{ and end with \}/, 'invalid source reports brace requirement');

$error = eval { RPN::CodeBlock->new(); 1 };
ok(!$error, 'missing source/body dies');
like($@, qr/requires source or body/, 'missing source/body reports requirement');

ok(!RPN::CodeBlock::is_codeblock({}), 'plain hash is not a CodeBlock');

# Phase 1 is object-only: CodeBlocks are values, not executable yet.
ok($block->can('as_string'), 'CodeBlock provides display support');
ok(!$block->can('execute'), 'CodeBlock execution is intentionally deferred');

done_testing();
