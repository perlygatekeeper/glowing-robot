#!/usr/bin/env perl
use v5.34;
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
$ENV{RPN_VARIABLES} = "$dir/variables";
$ENV{RPN_FUNCTIONS} = "$dir/functions";

my $calc = RPN->new(no_readline => 1);

stdout_like(
    sub { $calc->process_input('commands') },
    qr/Command\s+Abbrev\s+Aliases\s+Category\s+Description.*\n.*add\s+\S*\s+\+\s+Numeric\s+pops two numbers/s,
    'commands prints combined command catalog'
);

stdout_like(
    sub { $calc->process_input('commands numeric') },
    qr/add\s+\S*\s+\+\s+Numeric\s+pops two numbers/s,
    'commands numeric lists numeric commands'
);

my $numeric_output = stdout_from { $calc->process_input('commands numeric') };
like($numeric_output, qr/^add\s+/m, 'numeric catalog includes add');
unlike($numeric_output, qr/^madd\s+/m, 'numeric catalog excludes matrix command madd');

stdout_like(
    sub { $calc->process_input('commands categories') },
    qr/Category\s+Description.*Numeric\s+arithmetic functions.*Stack\s+stack manipulation/s,
    'commands categories lists command categories'
);

my $aliases_output = stdout_from { $calc->process_input('commands aliases') };
like($aliases_output, qr/^add\s+\S*\s+\+\s+Numeric\s+pops two numbers/m, 'commands aliases includes add alias');
unlike($aliases_output, qr/^abs\s+/m, 'commands aliases excludes commands without aliases');

my $abbrevs_output = stdout_from { $calc->process_input('commands abbreviations') };
like($abbrevs_output, qr/^add\s+\S+\s+\+\s+Numeric\s+pops two numbers/m, 'commands abbreviations includes commands with abbreviations');
stderr_like(
    sub { $calc->process_input('commands nosuchcategory') },
    qr/No such command category 'nosuchcategory'/,
    'commands unknown category warns'
);

done_testing();
