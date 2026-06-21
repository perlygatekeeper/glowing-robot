use strict;
use warnings;

use Test::More;
use Test::Output;
use File::Temp qw(tempdir);

use lib 'lib';
use RPN;

my $dir = tempdir(CLEANUP => 1);

$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";
$ENV{RPN_VARIABLES} = "$dir/variables";

my $calc = RPN->new(no_readline => 1);

#
# store / recall numeric
#

$calc->stack->clear;
$calc->process_input('42');
$calc->process_input('store answer');

is($calc->stack->peek, 42, 'store leaves value on stack');

$calc->stack->clear;
$calc->process_input('recall answer');

is($calc->stack->peek, 42, 'recall pushes variable');

#
# bare-word variable lookup
#

$calc->stack->clear;
$calc->process_input('answer');

is($calc->stack->peek, 42, 'bare variable name pushes value');

#
# overwrite variable
#

$calc->stack->clear;
$calc->process_input('43');
$calc->process_input('store answer');

$calc->stack->clear;
$calc->process_input('answer');

is($calc->stack->peek, 43, 'store overwrites existing variable');

#
# string variable
#

$calc->stack->clear;
$calc->process_input("'Steve");
$calc->process_input('store name');

$calc->stack->clear;
$calc->process_input('name');

is($calc->stack->peek, 'Steve', 'string variable works');

#
# variables listing
#

stdout_like(
    sub { $calc->process_input('variables') },
    qr/answer.*43.*name.*Steve/s,
    'variables lists stored variables'
);

#
# cannot shadow constant
#

$calc->stack->clear;
$calc->process_input('3');

stderr_like(
    sub { $calc->process_input('store pi') },
    qr/name already used by a constant|Cannot store variable 'pi'/,
    'cannot store variable using constant name'
);

#
# cannot shadow command
#

$calc->stack->clear;
$calc->process_input('3');

stderr_like(
    sub { $calc->process_input('store add') },
    qr/name already used by a command|Cannot store variable 'add'/,
    'cannot store variable using command name'
);

#
# delete variable
#

$calc->process_input('delvar answer');

stderr_like(
    sub { $calc->process_input('answer') },
    qr/Unknown input: answer|unknown input/i,
    'deleted variable no longer resolves'
);

#
# save / load variables
#

$calc->process_input('savevars');

ok(-s $ENV{RPN_VARIABLES}, 'savevars wrote variables file');

my $calc2 = RPN->new(no_readline => 1);

$calc2->stack->clear;
$calc2->process_input('name');

is($calc2->stack->peek, 'Steve', 'variable persisted and reloaded');

#
# loadvars/savevars with explicit filename
#

my $extra_vars_file = "$dir/extra_variables";

open my $vfh, '>', $extra_vars_file
    or die "Cannot write $extra_vars_file: $!";

print {$vfh} "loaded_var = 8675309\n";
close $vfh;

stdout_like(
    sub { $calc->process_input("loadvars $extra_vars_file") },
    qr/Loaded variables\./,
    'loadvars accepts explicit filename'
);

$calc->stack->clear;
$calc->process_input('loaded_var');

is($calc->stack->peek, 8675309, 'loadvars loaded explicit file');

my $saved_vars_file = "$dir/saved_variables";

stdout_like(
    sub { $calc->process_input("savevars $saved_vars_file") },
    qr/Saved variables\./,
    'savevars accepts explicit filename'
);

ok(-s $saved_vars_file, 'savevars wrote explicit file');

done_testing();
