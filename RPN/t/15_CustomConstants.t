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

my $calc = RPN->new(no_readline => 1);

#
# define custom constant
#

$calc->process_input('const answer 42');
$calc->process_input('answer');

is($calc->stack->peek, 42, 'custom constant answer = 42');

#
# const name pushes existing constant
#

$calc->stack->clear;
$calc->process_input('const answer');

is($calc->stack->peek, 42, 'const answer pushes custom constant');

#
# cannot redefine builtin
#

stderr_like(
    sub { $calc->process_input('const pi 3') },
    qr/Cannot redefine built-in constant 'pi'/,
    'cannot redefine builtin pi'
);

#
# delete custom constant
#

$calc->process_input('delconst answer');

stderr_like(
    sub { $calc->process_input('answer') },
    qr/Unknown input: answer/,
    'deleted constant no longer resolves'
);

#
# cannot delete builtin
#

stderr_like(
    sub { $calc->process_input('delconst pi') },
    qr/Cannot delete built-in constant 'pi'/,
    'cannot delete builtin pi'
);

#
# load constants file with comments
#

my $const_file = "$dir/custom_constants.txt";

open my $fh, '>', $const_file or die $!;
print $fh "# custom constants\n";
print $fh "gravity = 9.80665     # m/s^2\n";
print $fh "tax_rate 0.0825       # space syntax also works\n";
print $fh "\n";
close $fh;

$calc->process_input("loadconst $const_file");

$calc->stack->clear;
$calc->process_input('gravity');

ok(
    abs($calc->stack->peek - 9.80665) < 1e-10,
    'loaded gravity constant'
);

$calc->stack->clear;
$calc->process_input('tax_rate');

ok(
    abs($calc->stack->peek - 0.0825) < 1e-10,
    'loaded tax_rate constant'
);

#
# save constants
#

stdout_like(
    sub { $calc->process_input('saveconst') },
    qr/Saved constants\./,
    'saveconst prints confirmation'
);

ok(-s $ENV{RPN_CONSTANTS}, 'saveconst wrote constants file');

#
# loadconst/saveconst with explicit filename
#

my $extra_const_file = "$dir/extra_constants";

open my $cfh, '>', $extra_const_file
    or die "Cannot write $extra_const_file: $!";

print {$cfh} "bonus = 12345\n";
close $cfh;

$calc->process_input("loadconst $extra_const_file");
$calc->process_input('bonus');

is($calc->stack->peek, 12345, 'loadconst accepts explicit filename');

my $saved_const_file = "$dir/saved_constants";

stdout_like(
    sub { $calc->process_input("saveconst $saved_const_file") },
    qr/Saved constants\./,
    'saveconst accepts explicit filename'
);

ok(-s $saved_const_file, 'saveconst wrote explicit file');

done_testing();
