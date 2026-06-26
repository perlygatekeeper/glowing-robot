use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

# use Test::Output;
use lib 't/lib';
use RPN::TestOutput;

use lib 'lib';
use RPN;

sub matrix_string {
    my ($m) = @_;

    ok(RPN::Matrix::is_matrix($m), 'value is a matrix');

    return $m->as_string;
}

my $dir = tempdir(CLEANUP => 1);

$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";
$ENV{RPN_VARIABLES} = "$dir/variables";
$ENV{RPN_FUNCTIONS} = "$dir/functions";

my $calc = RPN->new(no_readline => 1);

#
# matrix by rows
#

$calc->stack->clear;
$calc->stack->push(RPN::Vector->new(1, 2));
$calc->stack->push(RPN::Vector->new(3, 4));
$calc->process_input('2');
$calc->process_input('matrix');

is(
    matrix_string($calc->stack->peek),
    '[[1,2],[3,4]]',
    'matrix creates matrix from row vectors'
);

#
# matrix by columns
#

$calc->stack->clear;
$calc->stack->push(RPN::Vector->new(1, 3));
$calc->stack->push(RPN::Vector->new(2, 4));
$calc->process_input('2');
$calc->process_input('matcols');

is(
    matrix_string($calc->stack->peek),
    '[[1,2],[3,4]]',
    'matcols creates matrix from column vectors'
);

#
# matparse
#

$calc->stack->clear;
$calc->process_input("'[[1,2],[3,4]]");
$calc->process_input('matparse');

is(
    matrix_string($calc->stack->peek),
    '[[1,2],[3,4]]',
    'matparse parses matrix literal'
);

#
# loadmatrix from row file
#

my $matrix_file = "$dir/matrix.txt";

open my $mfh, '>', $matrix_file
    or die "Cannot write $matrix_file: $!";

print {$mfh} "1 2\n";
print {$mfh} "3 4\n";

close $mfh;

$calc->stack->clear;
$calc->process_input("loadmatrix $matrix_file");

is(
    matrix_string($calc->stack->peek),
    '[[1,2],[3,4]]',
    'loadmatrix loads row file'
);

#
# loadmatrix from literal file
#

my $literal_file = "$dir/matrix_literal.txt";

open my $lfh, '>', $literal_file
    or die "Cannot write $literal_file: $!";

print {$lfh} "[[5,6],[7,8]]\n";

close $lfh;

$calc->stack->clear;
$calc->process_input("loadmatrix $literal_file");

is(
    matrix_string($calc->stack->peek),
    '[[5,6],[7,8]]',
    'loadmatrix loads literal file'
);

#
# rows / cols
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2, 3], [4, 5, 6]));
$calc->process_input('rows');

is($calc->stack->peek, 2, 'rows returns row count');

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2, 3], [4, 5, 6]));
$calc->process_input('cols');

is($calc->stack->peek, 3, 'cols returns column count');

#
# madd
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2], [3, 4]));
$calc->stack->push(RPN::Matrix->new([5, 6], [7, 8]));
$calc->process_input('madd');

is(
    matrix_string($calc->stack->peek),
    '[[6,8],[10,12]]',
    'madd adds matrices'
);

#
# msub
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([5, 6], [7, 8]));
$calc->stack->push(RPN::Matrix->new([1, 2], [3, 4]));
$calc->process_input('msub');

is(
    matrix_string($calc->stack->peek),
    '[[4,4],[4,4]]',
    'msub subtracts matrices'
);

#
# mmul
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2], [3, 4]));
$calc->stack->push(RPN::Matrix->new([5, 6], [7, 8]));
$calc->process_input('mmul');

is(
    matrix_string($calc->stack->peek),
    '[[19,22],[43,50]]',
    'mmul multiplies matrices'
);

#
# transpose
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2, 3], [4, 5, 6]));
$calc->process_input('transpose');

is(
    matrix_string($calc->stack->peek),
    '[[1,4],[2,5],[3,6]]',
    'transpose transposes matrix'
);

#
# display formatting
#

my $m = RPN::Matrix->new([1, 2], [3, 4]);

is(
    $calc->format_value($m),
    '[[1,2],[3,4]]',
    'format_value formats matrix'
);

#
# invalid matrix input preserves stack
#

$calc->stack->clear;
$calc->stack->push(RPN::Vector->new(1, 2));
$calc->process_input("'hello");
$calc->process_input('2');

stderr_like(
    sub { $calc->process_input('matrix') },
    qr/matrix requires row vectors/,
    'matrix rejects non-vector row'
);

is($calc->stack->depth, 3, 'matrix bad row preserves stack depth');
is($calc->stack->peek, 2, 'matrix bad row preserves row count');

#
# madd dimension mismatch preserves stack
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2], [3, 4]));
$calc->stack->push(RPN::Matrix->new([1, 2, 3], [4, 5, 6]));

stderr_like(
    sub { $calc->process_input('madd') },
    qr/same dimensions/,
    'madd rejects dimension mismatch'
);

is($calc->stack->depth, 2, 'madd mismatch preserves stack depth');
is(
    $calc->format_value($calc->stack->peek),
    '[[1,2,3],[4,5,6]]',
    'madd mismatch preserves top'
);

#
# mmul dimension mismatch preserves stack
#

$calc->stack->clear;
$calc->stack->push(RPN::Matrix->new([1, 2, 3], [4, 5, 6]));
$calc->stack->push(RPN::Matrix->new([1, 2, 3], [4, 5, 6]));

stderr_like(
    sub { $calc->process_input('mmul') },
    qr/left columns to equal right rows/,
    'mmul rejects invalid dimensions'
);

is($calc->stack->depth, 2, 'mmul mismatch preserves stack depth');

done_testing();
