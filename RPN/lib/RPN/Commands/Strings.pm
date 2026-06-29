package RPN::Commands::Strings;

use strict;
use warnings;

sub register_commands {
    my ($commands) = @_;

    $commands->register(
        lower => {
            category => 'string',
            help => 'convert string to lowercase',
            code => sub {
                my ($calc) = @_;
                my $s = $calc->stack->pop;
                $calc->stack->push(lc $s);
            },
        }
    );

    $commands->register(
        upper => {
            category => 'string',
            help => 'convert string to uppercase',
            code => sub {
                my ($calc) = @_;
                my $s = $calc->stack->pop;
                $calc->stack->push(uc $s);
            },
        }
    );

    $commands->register(
        trim => {
            category => 'string',
            help => 'remove leading and trailing whitespace',
            code => sub {
                my ($calc) = @_;
                my $s = $calc->stack->pop;
                $s =~ s/^\s+//;
                $s =~ s/\s+$//;
                $calc->stack->push($s);
            },
        }
    );

    $commands->register(
        ltrim => {
            category => 'string',
            help => 'remove leading whitespace',
            code => sub {
                my ($calc) = @_;
                my $s = $calc->stack->pop;
                $s =~ s/^\s+//;
                $calc->stack->push($s);
            },
        }
    );

    $commands->register(
        rtrim => {
            category => 'string',
            help => 'remove trailing whitespace',
            code => sub {
                my ($calc) = @_;
                my $s = $calc->stack->pop;
                $s =~ s/\s+$//;
                $calc->stack->push($s);
            },
        }
    );

    $commands->register(
        split => {
            category => 'string',
            help => 'split string by delimiter: string delimiter split',
            code => sub {
                my ($calc) = @_;
                my $delim = $calc->stack->pop;
                my $s     = $calc->stack->pop;

                my @parts = split(/\Q$delim\E/, $s);
                $calc->stack->push(\@parts);
            },
        }
    );

    $commands->register(
        join => {
            category => 'string',
            help => 'join array/vector elements with delimiter: list delimiter join',
            code => sub {
                my ($calc) = @_;
                my $delim = $calc->stack->pop;
                my $items = $calc->stack->pop;

                die "join requires an array reference\n"
                    unless ref($items) eq 'ARRAY';

                $calc->stack->push(join($delim, @$items));
            },
        }
    );

    $commands->register(
        length => {
            category => 'string',
            help => 'string length',
            code => sub {
                my ($calc) = @_;
                my $s = $calc->stack->pop;
                $calc->stack->push(length($s));
            },
        }
    );

    $commands->register(
        strrev => {
            category => 'string',
            help => 'reverse a string',
            code => sub {
                my ($calc) = @_;
                my $s = $calc->stack->pop;
                $calc->stack->push(scalar reverse $s);
            },
        }
    );

    $commands->register(
        repeat => {
            category => 'string',
            help => 'repeat string N times: string n repeat',
            code => sub {
                my ($calc) = @_;
                my $n = $calc->stack->pop;
                my $s = $calc->stack->pop;
                $calc->stack->push($s x $n);
            },
        }
    );

    $commands->register(
        match => {
            category => 'string',
            help => 'regex match: string pattern match',
            code => sub {
                my ($calc) = @_;
                my $pattern = $calc->stack->pop;
                my $s       = $calc->stack->pop;
                $calc->stack->push($s =~ /$pattern/ ? 1 : 0);
            },
        }
    );

    $commands->register(
        search => {
            category => 'string',
            help => 'return first regex match: string pattern search',
            code => sub {
                my ($calc) = @_;
                my $pattern = $calc->stack->pop;
                my $s       = $calc->stack->pop;

                if ($s =~ /($pattern)/) {
                    $calc->stack->push($1);
                }
                else {
                    $calc->stack->push('');
                }
            },
        }
    );

    $commands->register(
        replace => {
            category => 'string',
            help => 'literal replace first occurrence: string old new replace',
            code => sub {
                my ($calc) = @_;
                my $new = $calc->stack->pop;
                my $old = $calc->stack->pop;
                my $s   = $calc->stack->pop;

                $s =~ s/\Q$old\E/$new/;
                $calc->stack->push($s);
            },
        }
    );

    $commands->register(
        subst => {
            category => 'string',
            help => 'regex replace first match: string pattern replacement subst',
            code => sub {
                my ($calc) = @_;
                my $replacement = $calc->stack->pop;
                my $pattern     = $calc->stack->pop;
                my $s           = $calc->stack->pop;

                $s =~ s/$pattern/$replacement/;
                $calc->stack->push($s);
            },
        }
    );

    return;
}

1;
