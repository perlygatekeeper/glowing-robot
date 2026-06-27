#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;
use lib 'lib';

use RPN;

# A reverse polish notation calculator.
# See lib/RPN.pm, lib/RPN/Stack.pm, lib/RPN/Commands.pm for implementation.
# usage: rpn.pl [--version]

our $VERSION = '3.8.5.1';
my $AUTHOR        = 'Dr. Steven Parker';
my $LAST_MOD_DATE = 'Fri, Jun 26, 2026';

if (@ARGV && $ARGV[0] =~ /^--v(ersion)?/i) {
    printf "rpn.pl written by %s, version %s, last modified %s.\n",
        $AUTHOR, $VERSION, $LAST_MOD_DATE;
    exit 0;
}

my $calc = RPN->new();
$calc->run();
