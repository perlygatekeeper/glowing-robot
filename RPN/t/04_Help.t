use strict;
use warnings;

use Test::More;
# use Test::Output;
use lib 't/lib';
use RPN::TestOutput;

use lib 'lib';
use RPN;

my $calc = RPN->new();

stdout_like(
    sub { $calc->process_input('help') },
    qr/Command\s+Type\s+Help/s,
    'help prints table header'
);

stdout_like(
    sub { $calc->process_input('help add') },
    qr/add\s+numeric\s+pops two numbers/s,
    'help add prints add help'
);

stdout_like(
    sub { $calc->process_input('help +') },
    qr/add\s+numeric\s+pops two numbers/s,
    'help + resolves alias to add'
);

stdout_like(
    sub { $calc->process_input('help type numeric') },
    qr/add\s+numeric.*multiply\s+numeric.*subtract\s+numeric/s,
    'help type numeric lists numeric commands'
);

stderr_like(
    sub { $calc->process_input('help nosuchcommand') },
    qr/No command 'nosuchcommand' was found/,
    'help unknown command warns'
);

stdout_like(
    sub { $calc->process_input('help types') },
    qr/Type\s+Description.*numeric.*stack/s,
    'help types lists command types'
);

done_testing();
