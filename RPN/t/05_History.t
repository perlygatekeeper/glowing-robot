use strict;
use warnings;

use Test::More;
use Test::Output;
use File::Temp qw(tempdir);

use lib 'lib';
use RPN;

my $dir = tempdir(CLEANUP => 1);
$ENV{RPN_HISTORY} = "$dir/history";
$ENV{RPN_STACKS}  = "$dir/stacks";

my $calc = RPN->new();

eval {
    $calc->{term}->SetHistory('2', '3', 'add', 'peek');
    1;
} or plan skip_all => 'Term::ReadLine backend does not support SetHistory';

stdout_like(
    sub { $calc->process_input('history') },
    qr/0:\s+2.*1:\s+3.*2:\s+add.*3:\s+peek/s,
    'history prints readline history'
);

done_testing();