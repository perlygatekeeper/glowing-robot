use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN;

my $calc = RPN->new(no_readline => 1);

$calc->stack->clear;
$calc->process_input('17');
$calc->process_input('isprime');
is($calc->stack->peek, 1, '17 is prime');

$calc->stack->clear;
$calc->process_input('18');
$calc->process_input('isprime');
is($calc->stack->peek, 0, '18 is not prime');

$calc->stack->clear;
$calc->process_input('100');
$calc->process_input('nextprime');
is($calc->stack->peek, 101, 'nextprime 100 = 101');

$calc->stack->clear;
$calc->process_input('100');
$calc->process_input('prevprime');
is($calc->stack->peek, 97, 'prevprime 100 = 97');

$calc->stack->clear;
$calc->process_input('360');
$calc->process_input('factor');

is_deeply(
    [ reverse map { $calc->stack->pop } 1 .. $calc->stack->depth ],
    [2, 2, 2, 3, 3, 5],
    'factor 360'
);

$calc->stack->clear;
$calc->process_input('28');
$calc->process_input('divisors');

is_deeply(
    [ reverse map { $calc->stack->pop } 1 .. $calc->stack->depth ],
    [1, 2, 4, 7, 14, 28],
    'divisors 28'
);

$calc->stack->clear;
$calc->process_input('24');
$calc->process_input('18');
$calc->process_input('gcd');
is($calc->stack->peek, 6, 'gcd 24 18 = 6');

$calc->stack->clear;
$calc->process_input('24');
$calc->process_input('18');
$calc->process_input('lcm');
is($calc->stack->peek, 72, 'lcm 24 18 = 72');

$calc->stack->clear;
$calc->process_input('36');
$calc->process_input('totient');
is($calc->stack->peek, 12, 'phi 36 = 12');

done_testing();
