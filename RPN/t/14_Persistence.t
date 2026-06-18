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

my $calc = RPN->new(no_readline => 1);

#
# Stack persistence
#

$calc->process_input('1 2 3');
$calc->save_stacks;

ok(-s $ENV{RPN_STACKS}, 'stack save file was created');

my $calc2 = RPN->new(no_readline => 1);

is($calc2->stack->depth, 3, 'loaded saved stack depth');
is($calc2->stack->peek, 3, 'loaded saved stack top');

#
# Named stacks persist too
#

$calc2->process_input('stack work');
$calc2->process_input('99');
$calc2->save_stacks;

my $calc3 = RPN->new(no_readline => 1);

$calc3->process_input('stack work');
is($calc3->stack->peek, 99, 'loaded named stack top');

$calc3->process_input('stack s');
is($calc3->stack->peek, 3, 'loaded default stack top');

#
# History persistence
#

$calc3->add_history('2');
$calc3->add_history('3');
$calc3->add_history('add');
$calc3->save_history;

ok(-s $ENV{RPN_HISTORY}, 'history save file was created');

my $calc4 = RPN->new(no_readline => 1);

stdout_like(
    sub { $calc4->process_input('history') },
    qr/2.*3.*add/s,
    'loaded command history'
);

#
# save command
#

stdout_like(
    sub { $calc4->process_input('save') },
    qr/Saved history and stacks\./,
    'save command reports success'
);

done_testing();
