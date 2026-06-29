#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use Test::More;
use File::Temp qw(tempfile);

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

ok($registry->can('define'), 'registry can define named blocks');
ok($registry->can('save_file'), 'registry can save named blocks');
ok($registry->can('load_file'), 'registry can load named blocks');

my ($fh, $file) = tempfile();
close $fh;

my $persistent = RPN::CodeBlocks->new(file => $file);
$persistent->define(square => RPN::CodeBlock->new(source => '{ dup * }'));
$persistent->define(cube   => RPN::CodeBlock->new(source => '{ dup dup * * }'));
ok($persistent->save_file, 'save_file uses default file from constructor');

open my $saved_fh, '<', $file or die "Cannot read saved code blocks file: $!";
my $saved = do { local $/; <$saved_fh> };
close $saved_fh;
like($saved, qr/^# RPN user code blocks/m, 'save_file writes header');
like($saved, qr/^cube = \{ dup dup \* \* \}$/m, 'save_file writes cube block');
like($saved, qr/^square = \{ dup \* \}$/m, 'save_file writes square block');

my $loaded = RPN::CodeBlocks->new(file => $file);
ok($loaded->load_file, 'load_file uses default file from constructor');
is_deeply([ $loaded->names ], [qw(cube square)], 'load_file restores block names');
ok(RPN::CodeBlock::is_codeblock($loaded->get('square')), 'loaded value is a CodeBlock');
is($loaded->get('square')->as_string, '{ dup * }', 'loaded block preserves source');
is($loaded->get('cube')->body, 'dup dup * *', 'loaded block preserves body');

my ($manual_fh, $manual_file) = tempfile();
print {$manual_fh} <<'BLOCKS';
# comments and blank lines are ignored

triple = { 3 * }
quadruple { 4 * }
malformed line
bad = not_a_block
BLOCKS
close $manual_fh;

my $manual = RPN::CodeBlocks->new;
ok($manual->load_file($manual_file), 'load_file accepts explicit file');
is_deeply([ $manual->names ], [qw(quadruple triple)], 'load_file accepts equals and whitespace formats and skips malformed entries');
is($manual->get('triple')->as_string, '{ 3 * }', 'equals format loads correctly');
is($manual->get('quadruple')->as_string, '{ 4 * }', 'whitespace format loads correctly');


done_testing();
