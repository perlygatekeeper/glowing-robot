use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new();

#
# count
#

$calc->stack->clear;
$calc->process_input('10 20 30');
$calc->process_input('count');

is($calc->stack->peek, 3, 'count pushes stack depth');

#
# sum
#

$calc->stack->clear;
$calc->process_input('1 2 3 4 5');
$calc->process_input('sum');

is($calc->stack->peek, 15, 'sum of 1..5 = 15');
is($calc->stack->depth, 1, 'sum replaces entire stack');

#
# average
#

$calc->stack->clear;
$calc->process_input('2 4 6 8');
$calc->process_input('average');

is($calc->stack->peek, 5, 'average of 2 4 6 8 = 5');

#
# avg alias
#

$calc->stack->clear;
$calc->process_input('10 20 30');
$calc->process_input('avg');

is($calc->stack->peek, 20, 'avg alias works');

#
# minimum
#

$calc->stack->clear;
$calc->process_input('9 4 7 2 8');
$calc->process_input('minimum');

is($calc->stack->peek, 2, 'minimum = 2');

#
# maximum
#

$calc->stack->clear;
$calc->process_input('9 4 7 2 8');
$calc->process_input('maximum');

is($calc->stack->peek, 9, 'maximum = 9');

#
# aliases
#

$calc->stack->clear;
$calc->process_input('5 3 8');
$calc->process_input('min');

is($calc->stack->peek, 3, 'min alias works');

$calc->stack->clear;
$calc->process_input('5 3 8');
$calc->process_input('max');

is($calc->stack->peek, 8, 'max alias works');

done_testing();