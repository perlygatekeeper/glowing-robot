#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

use lib 'lib';
use RPN;
use RPN::CodeBlock;
use RPN::Vector;
use RPN::Matrix;

my $dir = tempdir(CLEANUP => 1);
$ENV{RPN_HISTORY}    = "$dir/history";
$ENV{RPN_STACKS}     = "$dir/stacks";
$ENV{RPN_CONSTANTS}  = "$dir/constants";
$ENV{RPN_VARIABLES}  = "$dir/variables";
$ENV{RPN_FUNCTIONS}  = "$dir/functions";
$ENV{RPN_CODEBLOCKS} = "$dir/codeblocks";

my $calc = RPN->new(no_readline => 1);

ok($calc->can('is_executable'), 'calculator can test executable values');
ok($calc->can('execute'),       'calculator can execute executable values');

my $block = RPN::CodeBlock->new(source => '{ dup * }');

ok($calc->is_executable('dup *'), 'token string is executable');
ok($calc->is_executable('  dup *  '), 'trimmed token string is executable');
ok($calc->is_executable($block), 'CodeBlock is executable');

ok(!$calc->is_executable(42), 'number is not executable');
ok(!$calc->is_executable('42'), 'numeric string is not executable');
ok(!$calc->is_executable(''), 'empty string is not executable');
ok(!$calc->is_executable(undef), 'undef is not executable');
ok(!$calc->is_executable(RPN::Vector->new(1, 2, 3)), 'Vector is not executable');
ok(!$calc->is_executable(RPN::Matrix->new([1, 0], [0, 1])), 'Matrix is not executable');
ok(!$calc->is_executable({ source => 'dup *' }), 'plain hash is not executable');

$calc->stack->push(5);
ok($calc->execute('dup *'), 'execute runs a token string');
is($calc->stack->pop, 25, 'token string execution leaves expected result');

$calc->stack->push(6);
ok($calc->execute($block), 'execute runs a CodeBlock');
is($calc->stack->pop, 36, 'CodeBlock execution leaves expected result');

my $ok = eval { $calc->execute(99); 1 };
ok(!$ok, 'non-executable values are rejected by execute');
like($@, qr/execute requires an executable value/, 'execute reports useful error for non-executable values');

$calc->functions->set(square => 'dup *');
$calc->stack->push(7);
ok($calc->execute($calc->functions->get('square')), 'function bodies are executable token strings');
is($calc->stack->pop, 49, 'function body token string executes through common primitive');

done_testing();
