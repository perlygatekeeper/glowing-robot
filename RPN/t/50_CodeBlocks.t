#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN::CodeBlock;
use RPN::CodeBlocks;

my $registry = RPN::CodeBlocks->new;

is_deeply([ $registry->names ], [], 'new registry has no names');
ok(!$registry->exists('square'), 'missing block does not exist');
is($registry->get('square'), undef, 'missing block returns undef');

my $square = RPN::CodeBlock->new(source => '{ dup * }');
ok($registry->define(square => $square), 'define stores a CodeBlock');
ok($registry->exists('square'), 'defined block exists');
is($registry->get('square'), $square, 'get returns the stored CodeBlock object');
is_deeply([ $registry->names ], ['square'], 'names returns stored block names');

my $cube = RPN::CodeBlock->new(source => '{ dup dup * * }');
$registry->define(cube => $cube);
is_deeply([ $registry->names ], [qw(cube square)], 'names are sorted');

my $replacement = RPN::CodeBlock->new(source => '{ 2 * }');
$registry->define(square => $replacement);
is($registry->get('square'), $replacement, 'define replaces an existing block');

my $deleted = $registry->undefine('square');
is($deleted, $replacement, 'undefine returns deleted block');
ok(!$registry->exists('square'), 'undefine removes block');
is($registry->get('square'), undef, 'removed block returns undef');

$registry->define(square => $square);
$deleted = $registry->delete('square');
is($deleted, $square, 'delete is an alias for undefine');
ok(!$registry->exists('square'), 'delete removes block');

my $ok = eval { $registry->define('bad-name', $cube); 1 };
ok(!$ok, 'invalid names are rejected');
like($@, qr/invalid code block name/, 'invalid name reports useful error');

$ok = eval { $registry->define('', $cube); 1 };
ok(!$ok, 'empty names are rejected');
like($@, qr/name is required/, 'empty name reports useful error');

$ok = eval { $registry->define(notablock => '{ dup * }'); 1 };
ok(!$ok, 'non-CodeBlock values are rejected');
like($@, qr/requires an RPN::CodeBlock value/, 'non-CodeBlock reports useful error');

# Phase 2 is registry-only: persistence and commands arrive later.
ok($registry->can('define'), 'registry can define named blocks');
ok(!$registry->can('save_file'), 'persistence is intentionally deferred');


done_testing();
