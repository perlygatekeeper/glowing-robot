use strict;
use warnings;
use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new();

plan skip_all => 'Not implemented yet';

#
# Command
#
# $calc->stack->clear;
# $calc->process_input('2');
# $calc->process_input('3');
# $calc->process_input('add');
# is(
#     $calc->stack->peek,
#     5,
#     '2 3 add = 5'
# );

done_testing();
