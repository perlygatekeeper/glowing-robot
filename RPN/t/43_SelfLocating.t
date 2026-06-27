#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);
use File::Path qw(make_path);
use Cwd qw(abs_path getcwd);

use lib 'lib';
use RPN;

my $tmp = tempdir(CLEANUP => 1);

my $install_dir = "$tmp/install";
make_path("$install_dir/docs/tutorials");
make_path("$install_dir/examples");
make_path("$install_dir/constants");

my $expected_install_dir = abs_path($install_dir);

my $calc = RPN->new(
    install_dir => $install_dir,
);

is($calc->install_dir,   $expected_install_dir,                    'install_dir accessor uses constructor value');
is($calc->docs_dir,      "$expected_install_dir/docs",             'docs_dir is derived from install_dir');
is($calc->tutorials_dir, "$expected_install_dir/docs/tutorials",   'tutorials_dir is derived from install_dir');
is($calc->examples_dir,  "$expected_install_dir/examples",         'examples_dir is derived from install_dir');
is($calc->constants_dir, "$expected_install_dir/constants",        'constants_dir is derived from install_dir');

my $cwd = getcwd();

chdir $tmp or die "Cannot chdir to temp dir: $!";

isnt(getcwd(), $expected_install_dir, 'test is running from outside install_dir');

is($calc->tutorials_dir,
   "$expected_install_dir/docs/tutorials",
   'tutorials_dir remains based on install_dir when cwd changes');

is($calc->examples_dir,
   "$expected_install_dir/examples",
   'examples_dir remains based on install_dir when cwd changes');

chdir $cwd or die "Cannot restore cwd: $!";

done_testing();