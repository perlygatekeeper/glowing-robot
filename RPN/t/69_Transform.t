use v5.34;
use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN::Transform;
use RPN::Vector;

sub point_is {
    my ($point, $expected, $name) = @_;
    ok(RPN::Vector::is_vector($point), "$name returns a vector");
    my @got = $point->values;
    is(scalar @got, scalar @$expected, "$name preserves point dimension");
    for my $i (0 .. $#$expected) {
        ok(
            abs($got[$i] - $expected->[$i]) < 1e-10,
            "$name component $i",
        ) or diag("got $got[$i], expected $expected->[$i]");
    }
}

my $point = RPN::Vector->new(3, 4);

point_is(
    RPN::Transform->identity(2)->apply($point),
    [3, 4],
    'identity',
);

point_is(
    RPN::Transform->translation2d(5, -2)->apply($point),
    [8, 2],
    'translation',
);

point_is(
    RPN::Transform->rotation2d(atan2(1, 1) * 2)
        ->apply(RPN::Vector->new(1, 0)),
    [0, 1],
    'quarter-turn rotation',
);

point_is(
    RPN::Transform->scaling2d(2, 3)->apply($point),
    [6, 12],
    'nonuniform scaling',
);

point_is(
    RPN::Transform->shearing2d(1, 0)->apply(RPN::Vector->new(2, 3)),
    [5, 3],
    'x shear by y',
);

point_is(
    RPN::Transform->reflection_x2d->apply($point),
    [3, -4],
    'x-axis reflection',
);

point_is(
    RPN::Transform->reflection_y2d->apply($point),
    [-3, 4],
    'y-axis reflection',
);

my $translation = RPN::Transform->translation2d(2, 3);
my $scaling     = RPN::Transform->scaling2d(2, 2);
my $composed    = $translation->then($scaling);

point_is(
    $composed->apply(RPN::Vector->new(1, 1)),
    [6, 8],
    'composition applies first transform then second',
);

point_is(
    $composed->inverse->apply($composed->apply($point)),
    [3, 4],
    'inverse restores transformed point',
);

is($composed->dimension, 2, 'transform reports dimension');
is($composed->matrix->rows, 3, '2D transform exposes 3x3 homogeneous matrix');
like($composed->as_string, qr/^transform2d\[\[/, 'transform has display form');

eval { RPN::Transform->translation2d('bad', 2) };
like($@, qr/parameters must be numbers/, 'factory rejects nonnumeric parameters');

eval { $composed->apply(RPN::Vector->new(1, 2, 3)) };
like($@, qr/point dimension/, 'application rejects wrong point dimension');

done_testing();
