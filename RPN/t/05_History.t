use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);
# use Test::Output;
use lib 't/lib';
use RPN::TestOutput;

use lib 'lib';
use RPN;

my $dir = tempdir(CLEANUP => 1);
$ENV{RPN_HISTORY} = "$dir/history";
$ENV{RPN_STACKS}  = "$dir/stacks";

my $calc = RPN->new(no_readline => 1);

$calc->add_history('2');
$calc->add_history('3');
$calc->add_history('add');
$calc->add_history('peek');

stdout_like(
    sub { $calc->process_input('history') },
    qr/0:\s+2.*1:\s+3.*2:\s+add.*3:\s+peek/s,
    'history prints command history'
);

done_testing();
