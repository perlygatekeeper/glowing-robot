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
        abs($got - $expected) < 1e-10,
        $desc
    );
}

nearly(stack_result_for(1, 'sinh'), 1.17520119364380, 'sinh(1)');
nearly(stack_result_for(1, 'cosh'), 1.54308063481524, 'cosh(1)');
nearly(stack_result_for(1, 'tanh'), 0.761594155955765, 'tanh(1)');
nearly(stack_result_for(0, 'asinh'), 0, 'asinh(0)');
nearly(stack_result_for(1, 'asinh'), 0.881373587019543, 'asinh(1)');
nearly(stack_result_for(1, 'acosh'), 0, 'acosh(1)');
nearly(stack_result_for(2, 'acosh'), 1.31695789692482, 'acosh(2)');
nearly(stack_result_for(0, 'atanh'), 0, 'atanh(0)');
nearly(stack_result_for(0.5, 'atanh'), 0.549306144334055, 'atanh(0.5)');

$calc->stack->clear;
$calc->process_input(0.5);
stderr_like(
    sub { $calc->process_input('acosh') },
    qr/acosh requires a value greater than or equal to 1/,
    'acosh warns below domain'
);
is($calc->stack->peek, 0.5, 'acosh domain error leaves stack unchanged');

$calc->stack->clear;
$calc->process_input(1);
stderr_like(
    sub { $calc->process_input('atanh') },
    qr/atanh requires a value greater than -1 and less than 1/,
    'atanh warns at upper domain boundary'
);
is($calc->stack->peek, 1, 'atanh upper domain error leaves stack unchanged');

$calc->stack->clear;
$calc->process_input(-1);
stderr_like(
    sub { $calc->process_input('atanh') },
    qr/atanh requires a value greater than -1 and less than 1/,
    'atanh warns at lower domain boundary'
);
is($calc->stack->peek, -1, 'atanh lower domain error leaves stack unchanged');

for my $command (qw(sinh cosh tanh asinh acosh atanh)) {
    ok(
        exists $calc->{commands}{commands}{$command},
        "$command is registered"
    );

    is(
        $calc->{commands}{commands}{$command}{category},
        'trig',
        "$command is a trig command"
    );
}

done_testing();
