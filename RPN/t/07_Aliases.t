use strict;
use warnings;
use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new();

# plan skip_all => 'Not implemented yet';

#
# Aliases
#
$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('10');
$calc->process_input('+');
is(
    $calc->stack->peek,
    11,
    '1 10 + = 11'
);

done_testing();
