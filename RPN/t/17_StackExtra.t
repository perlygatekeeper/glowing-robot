use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new(no_readline => 1);

#
# reverse
#

$calc->stack->clear;
$calc->process_input('1 2 3 4');
$calc->process_input('reverse');

is($calc->stack->pop, 1, 'reverse top');
is($calc->stack->pop, 2, 'reverse second');
is($calc->stack->pop, 3, 'reverse third');
is($calc->stack->pop, 4, 'reverse fourth');

#
# shuffle
#

$calc->process_input('1 2 3 4 5');
$calc->process_input('shuffle');

is($calc->stack->depth, 5, 'shuffle preserves depth');

my @values = sort { $a <=> $b } $calc->stack->values;

is_deeply(
    \@values,
    [1,2,3,4,5],
    'shuffle preserves values'
);


#
# over
#

$calc->stack->clear;
$calc->process_input('1 2');
$calc->process_input('over');

is($calc->stack->pop, 1, 'over copies second item to top');
is($calc->stack->pop, 2, 'over leaves original top in place');
is($calc->stack->pop, 1, 'over leaves original second in place');

$calc->stack->clear;
$calc->process_input('10 20');
$calc->process_input('over');
$calc->process_input('+');

is($calc->stack->pop, 30, 'over composes with arithmetic');
is($calc->stack->pop, 10, 'over preserves original second item');

#
# pick
#

$calc->stack->clear;
$calc->process_input('10 20 30 40');
$calc->process_input('2');
$calc->process_input('pick');

is($calc->stack->peek, 20, 'pick copies depth 2');

#
# pullup
#

$calc->stack->clear;
$calc->process_input('10 20 30 40');
$calc->process_input('2');
$calc->process_input('pullup');

is($calc->stack->pop, 20, 'pullup moved depth 2 to top');
is($calc->stack->pop, 40, 'pullup preserves order');
is($calc->stack->pop, 30, 'pullup preserves order');
is($calc->stack->pop, 10, 'pullup preserves order');

#
# pushdown
#

$calc->stack->clear;
$calc->process_input('10 20 30 40');
$calc->process_input('2');
$calc->process_input('pushdown');

is($calc->stack->pop, 30, 'pushdown top');
is($calc->stack->pop, 20, 'pushdown second');
is($calc->stack->pop, 40, 'pushdown moved top');
is($calc->stack->pop, 10, 'pushdown preserves order');
#
# roll -1
#

$calc->stack->clear;
$calc->process_input('1 2 3 4');
$calc->process_input('-1');
$calc->process_input('roll');

is($calc->stack->pop, 3, 'roll -1 top');
is($calc->stack->pop, 2, 'roll -1 second');
is($calc->stack->pop, 1, 'roll -1 third');
is($calc->stack->pop, 4, 'roll -1 fourth');

#
# roll 1
#

$calc->stack->clear;
$calc->process_input('1 2 3 4');
$calc->process_input('1');
$calc->process_input('roll');

is($calc->stack->pop, 1, 'roll 1 top');
is($calc->stack->pop, 4, 'roll 1 second');
is($calc->stack->pop, 3, 'roll 1 third');
is($calc->stack->pop, 2, 'roll 1 fourth');

#
# roll -2
#

$calc->stack->clear;
$calc->process_input('1 2 3 4');
$calc->process_input('-2');
$calc->process_input('roll');

is($calc->stack->pop, 2, 'roll -2 top');
is($calc->stack->pop, 1, 'roll -2 second');
is($calc->stack->pop, 4, 'roll -2 third');
is($calc->stack->pop, 3, 'roll -2 fourth');

done_testing();
