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
# define and execute simple function
#

$calc->stack->clear;
$calc->process_input('def sq "duplicate multiply"');

$calc->process_input('3');
$calc->process_input('sq');

is($calc->stack->peek, 9, 'sq function squares value');

#
# function can use aliases
#

$calc->stack->clear;
$calc->process_input('def addtwo "2 add"');

$calc->process_input('40');
$calc->process_input('addtwo');

is($calc->stack->peek, 42, 'function can use numeric literal and command');

#
# function body quoted strings may contain escaped quotes
#

$calc->process_input(q{def quoted_body "4 \"d6\" repeat sort"});
is(
    $calc->functions->get('quoted_body'),
    '4 "d6" repeat sort',
    'define unescapes escaped quotes in quoted function body'
);

#
# functions listing
#

stdout_like(
    sub { $calc->process_input('functions') },
    qr/addtwo.*2 add.*sq.*duplicate multiply/s,
    'functions lists defined functions'
);

#
# cannot shadow command
#

stderr_like(
    sub { $calc->process_input('def add "duplicate multiply"') },
    qr/name already used by a command/,
    'cannot define function using command name'
);

#
# cannot shadow constant
#

stderr_like(
    sub { $calc->process_input('def pi "duplicate multiply"') },
    qr/name already used by a constant/,
    'cannot define function using constant name'
);

#
# cannot shadow variable
#

$calc->stack->clear;
$calc->process_input('123');
$calc->process_input(q{'answer});
$calc->process_input('store');

stderr_like(
    sub { $calc->process_input('def answer "duplicate multiply"') },
    qr/name already used by a variable/,
    'cannot define function using variable name'
);

#
# delete function
#

$calc->process_input(q{'sq});
$calc->process_input('undef');

stderr_like(
    sub { $calc->process_input('sq') },
    qr/Unknown input: sq|unknown input/i,
    'deleted function no longer executes'
);

#
# save/load functions
#

stdout_like(
    sub { $calc->process_input('savefuncs') },
    qr/Saved functions\./,
    'savefuncs prints confirmation'
);

ok(-s $ENV{RPN_FUNCTIONS}, 'savefuncs wrote functions file');

my $calc2 = RPN->new(no_readline => 1);

$calc2->stack->clear;
$calc2->process_input('40');
$calc2->process_input('addtwo');

is($calc2->stack->peek, 42, 'function persisted and reloaded');

#
# loadfuncs
#

stdout_like(
    sub { $calc2->process_input('loadfuncs') },
    qr/Loaded functions\./,
    'loadfuncs prints confirmation'
);

#
# direct recursion is blocked
#

$calc->process_input('def recurse recurse');

stderr_like(
    sub { $calc->process_input('recurse') },
    qr/Recursive function call detected: recurse/,
    'direct recursion is blocked'
);

#
# indirect recursion is blocked
#

$calc->process_input('def a b');
$calc->process_input('def b a');

stderr_like(
    sub { $calc->process_input('a') },
    qr/Recursive function call detected: a/,
    'indirect recursion is blocked'
);

#
# loadfuncs/savefuncs with explicit filename
#

my $extra_funcs_file = "$dir/extra_functions";

open my $ffh, '>', $extra_funcs_file
    or die "Cannot write $extra_funcs_file: $!";

print {$ffh} "triple = 3 multiply\n";
close $ffh;

stdout_like(
    sub { $calc->process_input("loadfuncs $extra_funcs_file") },
    qr/Loaded functions\./,
    'loadfuncs accepts explicit filename'
);

$calc->stack->clear;
$calc->process_input('14');
$calc->process_input('triple');

is($calc->stack->peek, 42, 'loadfuncs loaded explicit file');

my $saved_funcs_file = "$dir/saved_functions";

stdout_like(
    sub { $calc->process_input("savefuncs $saved_funcs_file") },
    qr/Saved functions\./,
    'savefuncs accepts explicit filename'
);

ok(-s $saved_funcs_file, 'savefuncs wrote explicit file');

#
# showfunc displays function source
#

$calc->process_input('def distance "vsub magnitude"');

stdout_like(
    sub { $calc->process_input('showfunc distance') },
    qr/^distance\s*=\s*vsub magnitude/m,
    'showfunc displays function source'
);

#
# showfunc requires an existing function
#

stderr_like(
    sub { $calc->process_input('showfunc nosuchfunc') },
    qr/No such function 'nosuchfunc'|Unknown function 'nosuchfunc'/,
    'showfunc rejects unknown function'
);

#
# help function_name displays user function source
#

stdout_like(
    sub { $calc->process_input('help distance') },
    qr/User-defined function.*distance\s*=\s*vsub magnitude/s,
    'help function_name displays function source'
);

#
# functions listing includes names and bodies
#

stdout_like(
    sub { $calc->process_input('functions') },
    qr/distance\s+vsub magnitude/s,
    'functions listing includes function body'
);

done_testing();
