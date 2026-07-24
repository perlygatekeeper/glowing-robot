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

my $calc = RPN->new(
    install_dir => '.',
    no_readline => 1,
);

ok(
    $calc->functions->load_file(
        $calc->examples_dir . '/02_dice_and_games/advantage_disadvantage.txt'
    ),
    'load advantage and disadvantage example',
);

my $seed = 31415;
srand($seed);
my @d20 = map { 1 + int(rand(20)) } 1 .. 2;
srand($seed);
$calc->process_input('advantage');
is($calc->stack->pop, _maximum(@d20), 'advantage keeps the higher d20');

srand($seed);
@d20 = map { 1 + int(rand(20)) } 1 .. 2;
srand($seed);
$calc->process_input('disadvantage');
is($calc->stack->pop, _minimum(@d20), 'disadvantage keeps the lower d20');

ok(
    $calc->functions->load_file(
        $calc->examples_dir . '/02_dice_and_games/four_d6_drop_lowest.txt'
    ),
    'load four d6 example',
);

srand($seed);
my @d6 = map { 1 + int(rand(6)) } 1 .. 4;
my $expected_score = 0;
$expected_score += $_ for (sort { $a <=> $b } @d6)[1 .. 3];

$calc->stack->push('preserved');
srand($seed);
$calc->process_input('ability_score');

is($calc->stack->pop, $expected_score, 'ability score sums the highest three d6');
is($calc->stack->pop, 'preserved', 'ability score preserves the caller stack');

my @sorted_d6 = sort { $a <=> $b } @d6;
my $expected_string = sprintf(
    '%d + %d + %d + [%d] = %2d',
    reverse(@sorted_d6[1 .. 3]),
    $sorted_d6[0],
    $expected_score,
);

$calc->stack->push('still preserved');
srand($seed);
$calc->process_input('ability_score_as_string');

is(
    $calc->stack->pop,
    $expected_string,
    'formatted ability score shows kept dice, dropped die, and total',
);
is(
    $calc->stack->pop,
    'still preserved',
    'formatted ability score preserves the caller stack',
);

done_testing();

sub _maximum {
    my (@values) = @_;
    return (sort { $b <=> $a } @values)[0];
}

sub _minimum {
    my (@values) = @_;
    return (sort { $a <=> $b } @values)[0];
}
