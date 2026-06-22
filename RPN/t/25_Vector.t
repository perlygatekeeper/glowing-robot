use strict;
use warnings;

use Test::More;
use Test::Output;
use File::Temp qw(tempdir);

use lib 'lib';
use RPN;
use RPN::Vector;

sub close_enough {
    my ($got, $expected, $name) = @_;

    ok(
        abs($got - $expected) < 1e-6,
        $name
    ) or diag("got $got expected $expected");
}

sub vector_values {
    my ($v) = @_;

    ok(RPN::Vector::is_vector($v), 'value is a vector');

    return [ $v->values ];
}

my $dir = tempdir(CLEANUP => 1);

$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";
$ENV{RPN_VARIABLES} = "$dir/variables";
$ENV{RPN_FUNCTIONS} = "$dir/functions";

my $calc = RPN->new(no_readline => 1);

#
# vector creation
#

$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('2');
$calc->process_input('2');
$calc->process_input('vector');

is_deeply(
    vector_values($calc->stack->peek),
    [1, 2],
    'vector creates 2D vector'
);

#
# vec2
#

$calc->stack->clear;
$calc->process_input('3');
$calc->process_input('4');
$calc->process_input('vec2');

is_deeply(
    vector_values($calc->stack->peek),
    [3, 4],
    'vec2 creates vector'
);

#
# vec3
#

$calc->stack->clear;
$calc->process_input('1');
$calc->process_input('2');
$calc->process_input('3');
$calc->process_input('vec3');

is_deeply(
    vector_values($calc->stack->peek),
    [1, 2, 3],
    'vec3 creates vector'
);

#
# dim
#

$calc->process_input('dim');

is($calc->stack->peek, 3, 'dim returns vector dimension');

#
# display formatting
#

my $v = RPN::Vector->new(5, 6, 7);

is($calc->format_value($v), '<5,6,7>', 'format_value formats vector');

#
# vadd
#

$calc->stack->clear;
$calc->stack->push(RPN::Vector->new(1, 2));
$calc->stack->push(RPN::Vector->new(3, 4));
$calc->process_input('vadd');

is_deeply(
    vector_values($calc->stack->peek),
    [4, 6],
    'vadd adds vectors'
);

#
# vsub
#

$calc->stack->clear;
$calc->stack->push(RPN::Vector->new(5, 7));
$calc->stack->push(RPN::Vector->new(2, 3));
$calc->process_input('vsub');

is_deeply(
    vector_values($calc->stack->peek),
    [3, 4],
    'vsub subtracts vectors'
);

#
# vscale
#

$calc->stack->clear;
$calc->stack->push(RPN::Vector->new(3, 4));
$calc->process_input('2');
$calc->process_input('vscale');

is_deeply(
    vector_values($calc->stack->peek),
    [6, 8],
    'vscale scales vector'
);

#
# dot
#

$calc->stack->clear;
$calc->stack->push(RPN::Vector->new(1, 2, 3));
$calc->stack->push(RPN::Vector->new(4, 5, 6));
$calc->process_input('dot');

is($calc->stack->peek, 32, 'dot product');

#
# cross
#

$calc->stack->clear;
$calc->stack->push(RPN::Vector->new(1, 0, 0));
$calc->stack->push(RPN::Vector->new(0, 1, 0));
$calc->process_input('cross');

is_deeply(
    vector_values($calc->stack->peek),
    [0, 0, 1],
    'cross product'
);

#
# magnitude
#

$calc->stack->clear;
$calc->stack->push(RPN::Vector->new(3, 4));
$calc->process_input('magnitude');

close_enough(
    $calc->stack->peek,
    5,
    'magnitude'
);

#
# normalize
#

$calc->stack->clear;
$calc->stack->push(RPN::Vector->new(3, 4));
$calc->process_input('normalize');

my @unit = $calc->stack->peek->values;

close_enough($unit[0], 0.6, 'normalize x');
close_enough($unit[1], 0.8, 'normalize y');

#
# bad dimension preserves stack
#

$calc->stack->clear;
$calc->stack->push(RPN::Vector->new(1, 2));
$calc->stack->push(RPN::Vector->new(1, 2, 3));

stderr_like(
    sub { $calc->process_input('vadd') },
    qr/same dimension/,
    'vadd rejects dimension mismatch'
);

is($calc->stack->depth, 2, 'vadd mismatch preserves stack depth');
is($calc->format_value($calc->stack->peek), '<1,2,3>', 'vadd mismatch preserves top');

#
# bad type preserves stack
#

$calc->stack->clear;
$calc->stack->push(RPN::Vector->new(1, 2));
$calc->process_input("'hello");

stderr_like(
    sub { $calc->process_input('vadd') },
    qr/requires two vectors/,
    'vadd rejects non-vector'
);

is($calc->stack->depth, 2, 'vadd bad type preserves stack depth');
is($calc->stack->peek, 'hello', 'vadd bad type preserves top');

#
# normalize zero vector preserves stack
#

$calc->stack->clear;
$calc->stack->push(RPN::Vector->new(0, 0));

stderr_like(
    sub { $calc->process_input('normalize') },
    qr/cannot normalize zero vector/,
    'normalize rejects zero vector'
);

is($calc->stack->depth, 1, 'normalize zero preserves stack depth');
is($calc->format_value($calc->stack->peek), '<0,0>', 'normalize zero preserves vector');

done_testing();