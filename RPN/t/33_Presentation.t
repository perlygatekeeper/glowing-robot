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

$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";
$ENV{RPN_VARIABLES} = "$dir/variables";
$ENV{RPN_FUNCTIONS} = "$dir/functions";

my $calc = RPN->new(no_readline => 1);

#
# constants presentation
#

my $constants_output = stdout_from(
    sub { $calc->process_input('constants') }
);

like(
    $constants_output,
    qr/^Name\s+Source\s+Value\n/m,
    'constants output has header line'
);

like(
    $constants_output,
    qr/^-{12}\s+-{12}\s+-{30}\n/m,
    'constants output has separator line'
);

like(
    $constants_output,
    qr/^pi\s+builtin\s+/m,
    'constants output lists builtin pi on its own line'
);

#
# functions empty presentation
#

my $funcs_output = stdout_from(
    sub { $calc->process_input('funcs') }
);

like(
    $funcs_output,
    qr/No user functions are currently defined\./,
    'funcs reports no user functions'
);

like(
    $funcs_output,
    qr/define\s+double\s+2\s+\*/,
    'funcs empty message suggests define example, double'
);

#
# help presentation
#

my $help_types_output = stdout_from(
    sub { $calc->process_input('help types') }
);

like(
    $help_types_output,
    qr/\S/,
    'help types produces output'
);

like(
    $help_types_output,
    qr/\n/,
    'help types output contains newlines'
);

#
# tutorials presentation
#

my $tutorial_dir = 'docs/tutorials';

SKIP: {
    skip "docs/tutorials directory not present", 2
        unless -d $tutorial_dir;

    my $tutorials_output = stdout_from(
        sub { $calc->process_input('tutorials') }
    );

    like(
        $tutorials_output,
        qr/^Available Tutorials\n\n/m,
        'tutorials output has title and blank line'
    );

    like(
        $tutorials_output,
        qr/^\s+\S+/m,
        'tutorials output lists at least one tutorial'
    );
}

#
# variables empty-ish presentation
#
# This is deliberately mild because vars/variables output may evolve.
#

my $vars_output = stdout_from(
    sub { $calc->process_input('vars') }
);

like(
    $vars_output,
    qr/\S/,
    'vars produces output'
);

like(
    $vars_output,
    qr/\n/,
    'vars output contains newlines'
);

done_testing();
