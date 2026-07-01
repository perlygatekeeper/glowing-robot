use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new(no_readline => 1);

#
# rand
#

$calc->stack->clear;
$calc->process_input('rand');

my $r = $calc->stack->peek;

ok($r >= 0, 'rand >= 0');
ok($r < 1,  'rand < 1');

#
# randint low high from stack
#

$calc->stack->clear;
$calc->execute('50 100 randint');

my $j = $calc->stack->peek;

ok($j >= 50, 'randint range lower');
ok($j <= 100, 'randint range upper');

#
# randint preserves range if entered high low
#

$calc->stack->clear;
$calc->execute('100 50 randint');

my $k = $calc->stack->peek;

ok($k >= 50, 'randint reversed range lower');
ok($k <= 100, 'randint reversed range upper');

#
# dieroll SIDES from stack
#

$calc->stack->clear;
$calc->execute('20 dieroll');

my $i = $calc->stack->peek;

ok($i >= 1,  'dieroll lower bound');
ok($i <= 20, 'dieroll upper bound');

#
# randint works from CodeBlocks
#

$calc->stack->clear;
$calc->process_input('{ 1 6 randint }');
$calc->process_input('call');

my $cb_roll = $calc->stack->peek;

ok($cb_roll >= 1, 'CodeBlock randint lower bound');
ok($cb_roll <= 6, 'CodeBlock randint upper bound');

#
# seed reproducibility
#

$calc->stack->clear;

$calc->process_input('12345');
$calc->process_input('seed');
$calc->process_input('rand');

my $a = $calc->stack->pop;

$calc->process_input('12345');
$calc->process_input('seed');
$calc->process_input('rand');

my $b = $calc->stack->pop;

ok(abs($a - $b) < 1e-12, 'seed produces repeatable sequence');

done_testing();