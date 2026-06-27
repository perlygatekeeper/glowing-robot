use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

use lib 't/lib';
use RPN::TestOutput;

use lib 'lib';
use RPN;

my $dir = tempdir(CLEANUP => 1);
$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";

my $calc = RPN->new(no_readline => 1);

my $const_file = "$dir/constants.txt";
open my $fh, '>', $const_file or die $!;
print {$fh} <<'CONSTANTS';
metadata: category="Physics" ; source="CODATA 2022"

c = 299792458 ; units="m/s" ; description="Speed of light in vacuum"
g0 = 9.80665 ; units="m/s^2" ; description="Standard acceleration due to gravity"

metadata: reset
metadata: category="Chemistry"

Na = 6.02214076e23 ; units="1/mol" ; description="Avogadro constant"
CONSTANTS
close $fh;

$calc->process_input("loadconst $const_file");

stdout_like(
    sub { $calc->process_input('constants') },
    qr/^Name\s+Source\s+Value\n/ms,
    'constants uses compact table header'
);

stdout_like(
    sub { $calc->process_input('constants') },
    qr/^c\s+user\s+299792458\b/ms,
    'constants compact table includes user constant'
);

stdout_like(
    sub { $calc->process_input('constants all') },
    qr/^Name\s+Source\s+Value\s+Units\s+Category\s*\n/ms,
    'constants all includes metadata columns'
);

stdout_like(
    sub { $calc->process_input('constants all') },
    qr/^c\s+user\s+299792458\s+m\/s\s+Physics\b/ms,
    'constants all displays units and category'
);

stdout_like(
    sub { $calc->process_input('constants categories') },
    qr/Available Categories.*Chemistry.*Mathematics.*Physics/s,
    'constants categories lists defined categories'
);

stdout_like(
    sub { $calc->process_input('constants Physics') },
    qr/^c\s+user\s+299792458\s+m\/s\s+Physics\b/ms,
    'constants category filter includes matching constant'
);

stdout_like(
    sub { $calc->process_input('constants Physics') },
    qr/^g0\s+user\s+9\.80665\s+m\/s\^2\s+Physics\b/ms,
    'constants category filter includes second matching constant'
);

stdout_like(
    sub { $calc->process_input('constants Physics') },
    qr/^(?!Na\s+)/ms,
    'constants category filter omits non-matching category'
);

stdout_like(
    sub { $calc->process_input('constants chemistry') },
    qr/^Na\s+user\s+6\.02214076e\+?23\s+1\/mol\s+Chemistry\b/ms,
    'constants category filter is case-insensitive'
);

stdout_like(
    sub { $calc->process_input('constinfo c') },
    qr/Name\s+c\nSource\s+user\nValue\s+299792458\nCategory\s+Physics\nDescription\s+Speed of light in vacuum\nSource\s+CODATA 2022\nUnits\s+m\/s/s,
    'constinfo shows value and metadata'
);

stderr_like(
    sub { $calc->process_input('constinfo missing') },
    qr/No constant 'missing' was found\./,
    'constinfo warns for missing constant'
);

stderr_like(
    sub { $calc->process_input('constants UnknownCategory') },
    qr/No constant or category 'UnknownCategory' was found\./,
    'constants category warns when no constant or category matches'
);

$calc->stack->clear;
$calc->process_input('const c');
is($calc->stack->peek, 299792458, 'const name still pushes constant');

$calc->stack->clear;
$calc->process_input('c');
is($calc->stack->peek, 299792458, 'direct constant input still pushes value');

done_testing();
