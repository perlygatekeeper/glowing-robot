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

nearly(stack_result_for(1, 'j0'), 0.765197686557967, 'j0(1)');
nearly(stack_result_for(1, 'j1'), 0.440050585744933, 'j1(1)');
nearly(stack_result_for(1, 2, 'jn'), 0.1149034849319, 'j2(1) using x n jn');

nearly(stack_result_for(1, 'y0'), 0.088256964215677, 'y0(1)');
nearly(stack_result_for(1, 'y1'), -0.781212821300289, 'y1(1)');
nearly(stack_result_for(1, 2, 'yn'), -1.65068260681625, 'y2(1) using x n yn');

$calc->stack->clear;
$calc->process_input(1);
$calc->process_input(2.5);
stderr_like(
    sub { $calc->process_input('jn') },
    qr/jn requires an integer order/,
    'jn warns for non-integer order'
);
is_deeply(
    [$calc->stack->values],
    [2.5, 1],
    'jn non-integer order leaves stack unchanged'
);

$calc->stack->clear;
$calc->process_input(0);
stderr_like(
    sub { $calc->process_input('y0') },
    qr/y0 requires a positive value/,
    'y0 warns at domain boundary'
);
is($calc->stack->peek, 0, 'y0 domain error leaves stack unchanged');

$calc->stack->clear;
$calc->process_input(-1);
stderr_like(
    sub { $calc->process_input('y1') },
    qr/y1 requires a positive value/,
    'y1 warns below domain'
);
is($calc->stack->peek, -1, 'y1 domain error leaves stack unchanged');

$calc->stack->clear;
$calc->process_input(0);
$calc->process_input(2);
stderr_like(
    sub { $calc->process_input('yn') },
    qr/yn requires a positive x value/,
    'yn warns at x domain boundary'
);
is_deeply(
    [$calc->stack->values],
    [2, 0],
    'yn domain error leaves stack unchanged'
);

for my $command (qw(j0 j1 jn y0 y1 yn)) {
    ok(
        exists $calc->{commands}{commands}{$command},
        "$command is registered"
    );

    is(
        $calc->{commands}{commands}{$command}{type},
        'numeric',
        "$command is a numeric command"
    );
}

done_testing();
