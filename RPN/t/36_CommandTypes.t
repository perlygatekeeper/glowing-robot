use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);

use lib 'lib';

use RPN;

my $dir = tempdir(CLEANUP => 1);

$ENV{RPN_HISTORY}   = "$dir/history";
$ENV{RPN_STACKS}    = "$dir/stacks";
$ENV{RPN_CONSTANTS} = "$dir/constants";
$ENV{RPN_VARIABLES} = "$dir/variables";
$ENV{RPN_FUNCTIONS} = "$dir/functions";

my $calc = RPN->new(no_readline => 1);

my $commands = $calc->{commands}{commands};
my $types    = $calc->{commands}{types};

ok(keys %$commands, 'command registry is not empty');
ok(keys %$types,    'command type registry is not empty');

for my $command (sort keys %$commands) {
    my $entry = $commands->{$command};

    ok(
        exists $entry->{type},
        "$command has a type"
    );

    ok(
        defined $entry->{type} && length $entry->{type},
        "$command type is non-empty"
    );

    ok(
        exists $types->{ $entry->{type} },
        "$command has valid type '$entry->{type}'"
    );

    ok(
        exists $entry->{help},
        "$command has help text"
    );

    ok(
        defined $entry->{help} && length $entry->{help},
        "$command help text is non-empty"
    );

    ok(
        exists $entry->{code} && ref($entry->{code}) eq 'CODE',
        "$command has executable code"
    );
}

done_testing();
