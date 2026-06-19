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
# randint N
#

$calc->stack->clear;
$calc->process_input('randint 10');

my $i = $calc->stack->peek;

ok($i >= 1, 'randint lower bound');
ok($i <= 10, 'randint upper bound');

#
# randint low high
#

$calc->stack->clear;
$calc->process_input('randint 50 100');

my $j = $calc->stack->peek;

ok($j >= 50, 'randint range lower');
ok($j <= 100, 'randint range upper');

#
# seed reproducibility
#

$calc->stack->clear;

$calc->process_input('seed 12345');
$calc->process_input('rand');

my $a = $calc->stack->pop;

$calc->process_input('seed 12345');
$calc->process_input('rand');

my $b = $calc->stack->pop;

ok(abs($a - $b) < 1e-12, 'seed produces repeatable sequence');

done_testing();