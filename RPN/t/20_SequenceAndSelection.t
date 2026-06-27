use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new(no_readline => 1);

#
# sequence ascending
#

$calc->stack->clear;
$calc->process_input('0');
$calc->process_input('3');
$calc->process_input('sequence');

is($calc->stack->depth, 4, 'sequence ascending depth');
is($calc->stack->pop, 3, 'sequence ascending top');
is($calc->stack->pop, 2, 'sequence ascending');
is($calc->stack->pop, 1, 'sequence ascending');
is($calc->stack->pop, 0, 'sequence ascending');

#
# sequence descending
#

$calc->stack->clear;
$calc->process_input('3');
$calc->process_input('0');
$calc->process_input('sequence');

is($calc->stack->depth, 4, 'sequence descending depth');
is($calc->stack->pop, 0, 'sequence descending top');
is($calc->stack->pop, 1, 'sequence descending');
is($calc->stack->pop, 2, 'sequence descending');
is($calc->stack->pop, 3, 'sequence descending');

#
# string sequence
#

$calc->stack->clear;
$calc->process_input("'a");
$calc->process_input("'f");
$calc->process_input('..');

is($calc->stack->depth, 6, 'string sequence depth');
is($calc->stack->pop, 'f', 'string sequence top');
is($calc->stack->pop, 'e', 'string sequence e');
is($calc->stack->pop, 'd', 'string sequence d');
is($calc->stack->pop, 'c', 'string sequence c');
is($calc->stack->pop, 'b', 'string sequence b');
is($calc->stack->pop, 'a', 'string sequence a');

#
# sequenceby
#

$calc->stack->clear;
$calc->process_input('0');
$calc->process_input('10');
$calc->process_input('2');
$calc->process_input('sequenceby');

is($calc->stack->depth, 6, 'sequenceby depth');
is($calc->stack->pop, 10, 'sequenceby top');
is($calc->stack->pop, 8, 'sequenceby');
is($calc->stack->pop, 6, 'sequenceby');
is($calc->stack->pop, 4, 'sequenceby');
is($calc->stack->pop, 2, 'sequenceby');
is($calc->stack->pop, 0, 'sequenceby');

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

$calc->process_input('sort -1');

my @reverse_sorted_values = map { $calc->stack->pop } 1 .. 4;

is_deeply(
    \@reverse_sorted_values,
    [9,5,2,1],
    'sort descending'
);

done_testing();