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
    qr/Category:\s+Numeric.*arithmetic functions.*Commands.*add\s+Numeric.*multiply\s+Numeric.*subtract\s+Numeric.*See also:.*commands Numeric.*categories/s,
    'help category numeric prints category guide and lists numeric commands'
);


stdout_like(
    sub { $calc->process_input('help type numeric') },
    qr/Category:\s+Numeric.*Commands.*add\s+Numeric/s,
    'help type numeric remains a compatibility spelling'
);


stdout_like(
    sub { $calc->process_input('help stacks') },
    qr/Multiple matches found for 'stacks':.*Category\s+Stack\s+Use: help category Stack.*Tutorial\s+Stacks\s+Use: tutorial Stacks.*Command\s+stackinfo\s+Use: help stackinfo.*Command\s+stacksize\s+Use: help stacksize/s,
    'help ambiguous term prints non-interactive suggestions'
);

stdout_like(
    sub { $calc->process_input('help stack') },
    qr/stack\s+Stack\s+\(stack NAME\) switches stacks/s,
    'help exact command still wins over ambiguous suggestions'
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
