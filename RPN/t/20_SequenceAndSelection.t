use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new(no_readline => 1);

#
# range ascending
#

$calc->stack->clear;
$calc->process_input('0');
$calc->process_input('3');
$calc->process_input('range');

is($calc->stack->depth, 4, 'range ascending depth');
is($calc->stack->pop, 3, 'range ascending top');
is($calc->stack->pop, 2, 'range ascending');
is($calc->stack->pop, 1, 'range ascending');
is($calc->stack->pop, 0, 'range ascending');

#
# range descending
#

$calc->stack->clear;
$calc->process_input('3');
$calc->process_input('0');
$calc->process_input('range');

is($calc->stack->depth, 4, 'range descending depth');
is($calc->stack->pop, 0, 'range descending top');
is($calc->stack->pop, 1, 'range descending');
is($calc->stack->pop, 2, 'range descending');
is($calc->stack->pop, 3, 'range descending');

#
# string range
#

$calc->stack->clear;
$calc->process_input("'a");
$calc->process_input("'f");
$calc->process_input('..');

is($calc->stack->depth, 6, 'string range depth');
is($calc->stack->pop, 'f', 'string range top');
is($calc->stack->pop, 'e', 'string range e');
is($calc->stack->pop, 'd', 'string range d');
is($calc->stack->pop, 'c', 'string range c');
is($calc->stack->pop, 'b', 'string range b');
is($calc->stack->pop, 'a', 'string range a');

#
# rangeby
#

$calc->stack->clear;
$calc->process_input('0');
$calc->process_input('10');
$calc->process_input('2');
$calc->process_input('rangeby');

is($calc->stack->depth, 6, 'rangeby depth');
is($calc->stack->pop, 10, 'rangeby top');
is($calc->stack->pop, 8, 'rangeby');
is($calc->stack->pop, 6, 'rangeby');
is($calc->stack->pop, 4, 'rangeby');
is($calc->stack->pop, 2, 'rangeby');
is($calc->stack->pop, 0, 'rangeby');

#
# choose
#

$calc->stack->clear;
$calc->process_input('1 2 3 4 5');

my $depth_before = $calc->stack->depth;

$calc->process_input('choose');

is(
    $calc->stack->depth,
    $depth_before + 1,
    'choose adds one element'
);

#
# unique
#

$calc->stack->clear;
$calc->process_input('1 2 3 2 1 4');

$calc->process_input('unique');

is($calc->stack->depth, 4, 'unique depth');

my @unique_values = map { $calc->stack->pop } 1 .. 4;

is_deeply(
    \@unique_values,
    [4,1,2,3],
    'unique preserves first occurrence from top of stack'
);

#
# sort ascending
#

$calc->stack->clear;
$calc->process_input('5 1 9 2');

$calc->process_input('sort');

my @sorted_values = map { $calc->stack->pop } 1 .. 4;

is_deeply(
    \@sorted_values,
    [1,2,5,9],
    'sort ascending'
);

#
# sort descending
#

$calc->stack->clear;
$calc->process_input('5 1 9 2');

$calc->process_input('sortr');

my @reverse_sorted_values = map { $calc->stack->pop } 1 .. 4;

is_deeply(
    \@reverse_sorted_values,
    [9,5,2,1],
    'sortr descending'
);



# sequence remains alias for range
$calc->stack->clear;
$calc->process_input('0');
$calc->process_input('3');
$calc->process_input('sequence');
is($calc->stack->depth, 4, 'sequence alias depth');
is($calc->stack->pop, 3, 'sequence alias top');
is($calc->stack->pop, 2, 'sequence alias');
is($calc->stack->pop, 1, 'sequence alias');
is($calc->stack->pop, 0, 'sequence alias');

# sequenceby remains alias for rangeby
$calc->stack->clear;
$calc->process_input('0');
$calc->process_input('10');
$calc->process_input('2');
$calc->process_input('sequenceby');
is($calc->stack->depth, 6, 'sequenceby alias depth');
is($calc->stack->pop, 10, 'sequenceby alias top');
is($calc->stack->pop, 8, 'sequenceby alias');
is($calc->stack->pop, 6, 'sequenceby alias');
is($calc->stack->pop, 4, 'sequenceby alias');
is($calc->stack->pop, 2, 'sequenceby alias');
is($calc->stack->pop, 0, 'sequenceby alias');


done_testing();