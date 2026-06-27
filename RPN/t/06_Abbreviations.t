use strict;
use warnings;
use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new();

# plan skip_all => 'Not implemented yet';

#
# Abbreviations
#
$calc->stack->clear;
$calc->process_input('6');
$calc->process_input('7');
$calc->process_input('ad');
is(
    $calc->stack->peek,
    13,
    '6 7 ad = 13'
);

done_testing();
