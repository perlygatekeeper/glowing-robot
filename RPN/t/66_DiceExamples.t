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
my $chapter = $calc->examples_dir . '/02_dice_and_games';

for my $file (
    qw(
        roll_d20.txt
        roll_ndm.txt
        percentile_dice.txt
        dice_pool_successes.txt
        ability_scores.txt
        exploding_dice.txt
    )
) {
    ok($calc->functions->load_file("$chapter/$file"), "load $file");
}

my $seed = 2718;

srand($seed);
my @expected_ndm = map { 1 + int(rand(6)) } 1 .. 3;
srand($seed);
$calc->process_input('3 6');
$calc->process_input('roll_ndm');
is_deeply(
    [reverse $calc->stack->values],
    \@expected_ndm,
    'NdM example rolls the requested number of dice',
);

$calc->stack->clear;
srand($seed);
my @pool = map { 1 + int(rand(6)) } 1 .. 10;
my $successes = grep { $_ >= 5 } @pool;
srand($seed);
$calc->process_input('ten_d6_successes');
is($calc->stack->pop, $successes, 'dice-pool example counts successes');

srand($seed);
my @scores;
for (1 .. 6) {
    my @rolls = sort { $a <=> $b } map { 1 + int(rand(6)) } 1 .. 4;
    push @scores, $rolls[1] + $rolls[2] + $rolls[3];
}
srand($seed);
$calc->process_input('six_ability_scores');
is_deeply(
    [reverse $calc->stack->values],
    \@scores,
    'ability-score example produces six highest-three totals',
);

$calc->stack->clear;
srand($seed);
my @explosions;
do {
    push @explosions, 1 + int(rand(6));
} while ($explosions[-1] == 6);
my $exploding_total = 0;
$exploding_total += $_ for @explosions;
srand($seed);
$calc->process_input('exploding_d6');
is($calc->stack->pop, $exploding_total, 'exploding-die example repeats maximum rolls');

done_testing();
