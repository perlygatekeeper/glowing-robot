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
    qr/Welcome to the RPN Calculator.*Learning.*tutorials.*Browsing.*categories.*commands.*Getting Details.*help <command>.*help category <category>.*Reference.*aliases.*abbreviations/s,
    'help prints navigation guide'
);

stdout_like(
    sub { $calc->process_input('help add') },
    qr/add\s+Numeric\s+pops two numbers/s,
    'help add prints add help'
);

stdout_like(
    sub { $calc->process_input('help +') },
    qr/add\s+Numeric\s+pops two numbers/s,
    'help + resolves alias to add'
);

stdout_like(
    sub { $calc->process_input('help category numeric') },
    qr/add\s+Numeric.*multiply\s+Numeric.*subtract\s+Numeric/s,
    'help category numeric lists numeric commands'
);

stderr_like(
    sub { $calc->process_input('help nosuchcommand') },
    qr/No command 'nosuchcommand' was found/,
    'help unknown command warns'
);

stdout_like(
    sub { $calc->process_input('help categories') },
    qr/Category\s+Description.*Numeric.*Stack/s,
    'help categories lists command categories'
);

done_testing();
