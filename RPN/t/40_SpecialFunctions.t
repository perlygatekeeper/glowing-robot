use strict;
use warnings;

use Test::More;
use lib 't/lib';
use RPN::TestOutput;

use lib 'lib';
use RPN;

my $calc = RPN->new(no_readline => 1);

sub stack_result_for {
    my (@tokens) = @_;
    $calc->stack->clear;
    $calc->process_input($_) for @tokens;
    return $calc->stack->peek;
}

sub nearly {
    my ($got, $expected, $desc) = @_;
    ok(
        abs($got - $expected) < 1e-12,
        $desc
    ) or diag("got $got expected $expected");
}

nearly(stack_result_for(0, 'erf'),  0,                 'erf(0)');
nearly(stack_result_for(1, 'erf'),  0.842700792949715, 'erf(1)');
nearly(stack_result_for(0, 'erfc'), 1,                 'erfc(0)');
nearly(stack_result_for(1, 'erfc'), 0.157299207050285, 'erfc(1)');

nearly(stack_result_for(1, 'gamma'), 1,                'gamma(1)');
nearly(stack_result_for(5, 'gamma'), 24,               'gamma(5)');
nearly(stack_result_for(0.5, 'gamma'), 1.77245385090552, 'gamma(1/2)');

nearly(stack_result_for(1, 'lgamma'), 0,               'lgamma(1)');
nearly(stack_result_for(5, 'lgamma'), 3.17805383034795, 'lgamma(5)');
nearly(stack_result_for(0.5, 'lgamma'), 0.5723649429247, 'lgamma(1/2)');

nearly(stack_result_for(1, 1, 'beta'), 1,              'beta(1,1)');
nearly(stack_result_for(2, 3, 'beta'), 1 / 12,         'beta(2,3)');
nearly(stack_result_for(0.5, 0.5, 'beta'), 3.14159265358979, 'beta(1/2,1/2)');

$calc->stack->clear;
$calc->process_input(0);
stderr_like(
    sub { $calc->process_input('gamma') },
    qr/gamma undefined for zero and negative integers/,
    'gamma warns at zero pole'
);
is($calc->stack->peek, 0, 'gamma pole leaves stack unchanged');

$calc->stack->clear;
$calc->process_input(-2);
stderr_like(
    sub { $calc->process_input('gamma') },
    qr/gamma undefined for zero and negative integers/,
    'gamma warns at negative integer pole'
);
is($calc->stack->peek, -2, 'gamma negative integer pole leaves stack unchanged');

$calc->stack->clear;
$calc->process_input(0);
stderr_like(
    sub { $calc->process_input('lgamma') },
    qr/lgamma requires a positive value/,
    'lgamma warns at zero'
);
is($calc->stack->peek, 0, 'lgamma domain error leaves stack unchanged');

$calc->stack->clear;
$calc->process_input(2);
$calc->process_input(0);
stderr_like(
    sub { $calc->process_input('beta') },
    qr/beta requires positive values/,
    'beta warns for nonpositive operand'
);
is_deeply(
    [$calc->stack->values],
    [0, 2],
    'beta domain error leaves stack unchanged'
);

for my $command (qw(erf erfc gamma lgamma beta)) {
    ok(
        exists $calc->{commands}{commands}{$command},
        "$command is registered"
    );

    is(
        $calc->{commands}{commands}{$command}{category},
        'numeric',
        "$command is a numeric command"
    );
}

done_testing();
