#!/usr/bin/env perl
use v5.34;
use strict;
use warnings;

use Test::More;

use lib 'lib';
use RPN::Commands;

my $registry = RPN::Commands->new(undef);

sub dies_like(&$$) {
    my ($code, $regex, $name) = @_;
    my $error;
    {
        local $@;
        eval { $code->(); 1 } or $error = $@;
    }
    like($error || '', $regex, $name);
}

$registry->register(
    testvalid => {
        category => 'debug',
        help     => 'test command registration validation',
        code     => sub { },
    }
);
ok($registry->commands->{testvalid}, 'valid command registration succeeds');

$registry->register(
    testtypecompat => {
        type => 'debug',
        help => 'test backward-compatible type registration',
        code => sub { },
    }
);
is($registry->commands->{testtypecompat}{category}, 'debug', 'type key is accepted as compatibility input');
ok(!exists $registry->commands->{testtypecompat}{type}, 'type key is not retained internally');

dies_like {
    $registry->register('', { category => 'debug', help => 'bad', code => sub { } });
} qr/missing required field 'name'/, 'missing name dies';

dies_like {
    $registry->register(testbaddef => undef);
} qr/definition must be a hash reference/, 'non-hash definition dies';

dies_like {
    $registry->register(testnocategory => { help => 'bad', code => sub { } });
} qr/missing required field 'category'/, 'missing category dies';

dies_like {
    $registry->register(testnohelp => { category => 'debug', code => sub { } });
} qr/missing required field 'help'/, 'missing help dies';

dies_like {
    $registry->register(testemptyhelp => { category => 'debug', help => '', code => sub { } });
} qr/missing required field 'help'/, 'empty help dies';

dies_like {
    $registry->register(testnocode => { category => 'debug', help => 'bad' });
} qr/missing required field 'code'/, 'missing code dies';

dies_like {
    $registry->register(testbadcode => { category => 'debug', help => 'bad', code => 'not code' });
} qr/code must be a CODE reference/, 'non-code code dies';

dies_like {
    $registry->register(testvalid => { category => 'debug', help => 'duplicate', code => sub { } });
} qr/duplicate command name/, 'duplicate canonical command dies';

dies_like {
    $registry->register(testbadaliases => { category => 'debug', help => 'bad', aliases => 'alias', code => sub { } });
} qr/aliases must be an array reference/, 'non-array aliases dies';

dies_like {
    $registry->register(testemptyalias => { category => 'debug', help => 'bad', aliases => [''], code => sub { } });
} qr/alias must be non-empty/, 'empty alias dies';

dies_like {
    $registry->register(testdupalias => { category => 'debug', help => 'bad', aliases => ['same', 'same'], code => sub { } });
} qr/duplicate alias 'same'/, 'duplicate alias in one command dies';

dies_like {
    $registry->register(testselfalias => { category => 'debug', help => 'bad', aliases => ['testselfalias'], code => sub { } });
} qr/alias 'testselfalias' duplicates command name/, 'self alias dies';

dies_like {
    $registry->register(testaliascommand => { category => 'debug', help => 'bad', aliases => ['add'], code => sub { } });
} qr/alias 'add' conflicts with existing command/, 'alias conflicting with existing command dies';

$registry->register(
    testaliasowner => {
        category => 'debug',
        help     => 'own test alias',
        aliases  => ['testsharedalias'],
        code     => sub { },
    }
);

dies_like {
    $registry->register(testaliasconflict => { category => 'debug', help => 'bad', aliases => ['testsharedalias'], code => sub { } });
} qr/alias 'testsharedalias' conflicts with alias for 'testaliasowner'/, 'alias conflicting with existing alias dies';

done_testing();
