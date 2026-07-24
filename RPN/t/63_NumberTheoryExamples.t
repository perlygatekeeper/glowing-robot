use v5.34;
use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

use lib 'lib';
use RPN;

my $dir = tempdir(CLEANUP => 1);

local $ENV{RPN_HISTORY}    = "$dir/history";
local $ENV{RPN_STACKS}     = "$dir/stacks";
local $ENV{RPN_CONSTANTS}  = "$dir/constants";
local $ENV{RPN_VARIABLES}  = "$dir/variables";
local $ENV{RPN_FUNCTIONS}  = "$dir/functions";
local $ENV{RPN_CODEBLOCKS} = "$dir/codeblocks";

my $calc = RPN->new(install_dir => '.', no_readline => 1);
my $chapter = $calc->examples_dir . '/05_number_theory';

ok(
    $calc->functions->load_file("$chapter/sieve.txt"),
    'load sieve example',
);
ok(
    $calc->functions->load_file("$chapter/fibonacci_sequence.txt"),
    'load Fibonacci example',
);

$calc->process_input('20');
$calc->process_input('primes_through');
is_deeply(
    [reverse $calc->stack->values],
    [2, 3, 5, 7, 11, 13, 17, 19],
    'sieve example keeps primes through n',
);

$calc->stack->clear;
$calc->process_input('fibonacci_10');
is_deeply(
    [reverse $calc->stack->values],
    [0, 1, 1, 2, 3, 5, 8, 13, 21, 34],
    'Fibonacci example builds ten terms',
);

$calc->stack->clear;
$calc->process_input('360');
$calc->process_input('factor');
is_deeply(
    [sort { $a <=> $b } $calc->stack->values],
    [2, 2, 2, 3, 3, 5],
    'prime-factorization recipe has the documented result',
);

$calc->stack->clear;
$calc->process_input('36');
$calc->process_input('totient');
is($calc->stack->pop, 12, 'totient recipe has the documented result');

$calc->process_input('7 4');
$calc->process_input('exponentiate');
$calc->process_input('13');
$calc->process_input('modulo');
is($calc->stack->pop, 9, 'modular-exponentiation recipe has the documented result');

$calc->process_input('28');
$calc->process_input('divisors');
$calc->process_input('pop');
$calc->process_input('sum');
$calc->process_input('28');
$calc->process_input('==');
is($calc->stack->pop, 1, 'perfect-number recipe recognizes 28');

done_testing();
