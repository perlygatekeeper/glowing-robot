use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

use lib 'lib';

use RPN;

my $dir = tempdir(CLEANUP => 1);

$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";
$ENV{RPN_VARIABLES} = "$dir/variables";
$ENV{RPN_FUNCTIONS} = "$dir/functions";

my $calc = RPN->new(no_readline => 1);

sub top {
    return $calc->stack->pop;
}

$calc->stack->push('Hello World');
$calc->process_input('lower');
is(top(), 'hello world', 'lower');

$calc->stack->push('Hello World');
$calc->process_input('upper');
is(top(), 'HELLO WORLD', 'upper');

$calc->stack->push('   hello   ');
$calc->process_input('trim');
is(top(), 'hello', 'trim');

$calc->stack->push('   hello   ');
$calc->process_input('ltrim');
is(top(), 'hello   ', 'ltrim');

$calc->stack->push('   hello   ');
$calc->process_input('rtrim');
is(top(), '   hello', 'rtrim');

$calc->stack->push('one,two,three');
$calc->stack->push(',');
$calc->process_input('split');

my $parts = top();
is_deeply($parts, [qw(one two three)], 'split');

$calc->stack->push([qw(one two three)]);
$calc->stack->push(',');
$calc->process_input('join');
is(top(), 'one,two,three', 'join');

$calc->stack->push('hello');
$calc->process_input('length');
is(top(), 5, 'length');

$calc->stack->push('desserts');
$calc->process_input('strrev');
is(top(), 'stressed', 'strrev');

$calc->stack->push('*');
$calc->stack->push(5);
$calc->process_input('repeat');
is(top(), '*****', 'repeat');

$calc->stack->push('Steve Parker');
$calc->stack->push('^Steve');
$calc->process_input('match');
is(top(), 1, 'match true');

$calc->stack->push('Steve Parker');
$calc->stack->push('^Terry');
$calc->process_input('match');
is(top(), 0, 'match false');

$calc->stack->push('abc123xyz');
$calc->stack->push('\\d+');
$calc->process_input('search');
is(top(), '123', 'search');

$calc->stack->push('one two three');
$calc->stack->push('two');
$calc->stack->push('TWO');
$calc->process_input('replace');
is(top(), 'one TWO three', 'replace');

$calc->stack->push('abc123xyz');
$calc->stack->push('\\d+');
$calc->stack->push('NUMBER');
$calc->process_input('subst');
is(top(), 'abcNUMBERxyz', 'subst');

done_testing();
