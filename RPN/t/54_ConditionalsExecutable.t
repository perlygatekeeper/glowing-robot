use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new(no_readline => 1);

# if with token string executable, preferred order: condition executable if
$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('1');
$calc->process_input('"increment"');
$calc->process_input('if');
is($calc->stack->peek, 11, 'if executes token string when condition is true');

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('0');
$calc->process_input('"increment"');
$calc->process_input('if');
is($calc->stack->peek, 10, 'if does not execute token string when condition is false');

# if with CodeBlock executable
$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('1');
$calc->process_input('{ increment }');
$calc->process_input('if');
is($calc->stack->peek, 11, 'if executes CodeBlock when condition is true');

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('0');
$calc->process_input('{ increment }');
$calc->process_input('if');
is($calc->stack->peek, 10, 'if does not execute CodeBlock when condition is false');

# ifelse with token string executables, preferred order: condition true false ifelse
$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('1');
$calc->process_input('"increment"');
$calc->process_input('"decrement"');
$calc->process_input('ifelse');
is($calc->stack->peek, 11, 'ifelse executes true token string when condition is true');

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('0');
$calc->process_input('"increment"');
$calc->process_input('"decrement"');
$calc->process_input('ifelse');
is($calc->stack->peek, 9, 'ifelse executes false token string when condition is false');

# ifelse with CodeBlock executables
$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('1');
$calc->process_input('{ increment }');
$calc->process_input('{ decrement }');
$calc->process_input('ifelse');
is($calc->stack->peek, 11, 'ifelse executes true CodeBlock when condition is true');

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('0');
$calc->process_input('{ increment }');
$calc->process_input('{ decrement }');
$calc->process_input('ifelse');
is($calc->stack->peek, 9, 'ifelse executes false CodeBlock when condition is false');

# legacy order remains accepted for compatibility
$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('"increment"');
$calc->process_input('1');
$calc->process_input('if');
is($calc->stack->peek, 11, 'if still accepts legacy executable condition order');

$calc->stack->clear;
$calc->process_input('10');
$calc->process_input('"decrement"');
$calc->process_input('"increment"');
$calc->process_input('1');
$calc->process_input('ifelse');
is($calc->stack->peek, 11, 'ifelse still accepts legacy false true condition order');

# invalid executable preserves stack
$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('2');
$calc->process_input('if');
is($calc->stack->depth, 2, 'invalid if preserves stack depth');
is($calc->stack->pop, 2, 'invalid if preserves top value');
is($calc->stack->pop, 1, 'invalid if preserves lower value');

done_testing();
