use strict;
use warnings;

use Test::More;
use Test::Output;
use File::Temp qw(tempdir);

use lib 'lib';

use RPN;

my $dir = tempdir(CLEANUP => 1);

$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";
$ENV{RPN_VARIABLES} = "$dir/variables";
$ENV{RPN_FUNCTIONS} = "$dir/functions";

my $calc = RPN->new(no_readline => 1);

my @tutorials = qw(
    quickstart
    constants
    financial
    functions
    number_theory
    matrices
    variables
    vectors
);

for my $tutorial (@tutorials) {

    my $output = stdout_from(
        sub { $calc->process_input("tutorial $tutorial") }
    );

    ok(
        length($output) > 0,
        "tutorial '$tutorial' produced output"
    );

    unlike(
        $output,
        qr/Tutorial not found/i,
        "tutorial '$tutorial' exists"
    );
}

done_testing();
