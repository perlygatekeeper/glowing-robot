use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

use lib 'lib';
use RPN;
use RPN::Vector;

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

$calc->process_input(q{"abc \"def"});
is(top(), 'abc "def', 'double-quoted string unescapes escaped double quote');

$calc->process_input(q{"4 \"d6\" repeat sort"});
is(top(), '4 "d6" repeat sort', 'double-quoted string can contain escaped quotes for token strings');

$calc->process_input(q{"\\d+"});
is(top(), '\\d+', 'string input preserves non-string-syntax backslash escapes');

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

$calc->stack->push(RPN::Vector->new(qw(one two three)));
$calc->stack->push(',');
$calc->process_input('join');
is(top(), 'one,two,three', 'join vector');

$calc->stack->clear;
$calc->stack->push('one');
$calc->stack->push('two');
$calc->stack->push('three');
$calc->stack->push(',');
$calc->process_input('join');
is(top(), 'one,two,three', 'join stack');

$calc->stack->clear;
$calc->stack->push('red');
$calc->stack->push('green');
$calc->stack->push('blue');
$calc->stack->push(' | ');
$calc->process_input('join');
is(top(), 'red | green | blue', 'join stack with multi-character delimiter');

$calc->stack->clear;
$calc->stack->push(qw(one two));
$calc->stack->push(RPN::Vector->new(1, 2));
$calc->process_input('join');
isa_ok($calc->stack->pop, 'RPN::Vector', 'join preserves non-string delimiter');
is($calc->stack->depth, 2, 'join non-string delimiter leaves original values');
$calc->stack->clear;

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

$calc->stack->clear_all;
$calc->stack->push('[%d]', 1);
$calc->process_input('sprintf');
is(
    $calc->stack->pop,
    '[1]',
    'sprintf formats one value and pushes the result'
);

$calc->stack->clear_all;
$calc->stack->push('%d + %d = %d', 5, 3, 2);
$calc->process_input('sprintf');
is(
    $calc->stack->pop,
    '2 + 3 = 5',
    'sprintf formats multiple values in stack order'
);

$calc->stack->clear_all;
$calc->stack->push('%02d:%02d', 5, 9, 99);
$calc->process_input('sprintf');
is(
    $calc->stack->pop,
    '09:05',
    'sprintf preserves stack values below the formatted result'
);
is(
    $calc->stack->pop,
    99,
    'sprintf leaves lower stack values in place'
);

done_testing();
