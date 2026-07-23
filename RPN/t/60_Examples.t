use v5.34;
use strict;
use warnings;

use Test::More;
use File::Path qw(make_path);
use File::Temp qw(tempdir);

use lib 't/lib';
use RPN::TestOutput;

use lib 'lib';
use RPN;

my $install_dir = tempdir(CLEANUP => 1);
make_path("$install_dir/examples/01_basics");
make_path("$install_dir/examples/02_games");

_write_example(
    "$install_dir/examples/01_basics/add_two.txt",
    'Add Two Numbers',
    'Basics',
    'Adds two values.',
    '2 3 add',
);
_write_example(
    "$install_dir/examples/02_games/roll_die.txt",
    'Roll a Die',
    'Dice & Games',
    'Rolls one six-sided die.',
    '6 dieroll',
);

my $calc = RPN->new(
    install_dir => $install_dir,
    no_readline => 1,
);

stdout_like(
    sub { $calc->process_input('examples') },
    qr/Available Examples.*Basics.*01_basics\/add_two.*Adds two values.*Dice & Games.*02_games\/roll_die/s,
    'examples lists metadata grouped by category',
);

stdout_like(
    sub { $calc->process_input('examples dice and games') },
    qr/Dice & Games.*roll_die/s,
    'examples accepts a normalized multiword category',
);

stdout_like(
    sub { $calc->process_input('example add two numbers') },
    qr/Example: Add Two Numbers.*2 3 add/s,
    'example displays a selected example by metadata name',
);

stdout_like(
    sub { $calc->process_input('example 01_basics/add_two') },
    qr/Example: Add Two Numbers.*2 3 add/s,
    'example displays a selected example by path key',
);

stderr_like(
    sub { $calc->process_input('example missing') },
    qr/Unknown example 'missing'/,
    'unknown example reports a useful error',
);

done_testing();

sub _write_example {
    my ($file, $name, $category, $description, $body) = @_;
    open my $fh, '>', $file or die "Cannot write '$file': $!";
    print {$fh} <<"EXAMPLE";
#------------------------------------------------------------
# Example: $name
#
# Category:
#     $category
#
# Purpose:
#     $description
#------------------------------------------------------------

$body
EXAMPLE
    close $fh;
}
