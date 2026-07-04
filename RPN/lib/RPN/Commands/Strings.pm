package RPN::Commands::Strings;

use strict;
use warnings;

use RPN::Vector;

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
            help => 'join vector or stack values with delimiter: values delimiter join or vector delimiter join',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1);

                my $delim = $calc->stack->pop;

                if (ref $delim) {
                    $calc->stack->push($delim);
                    warn "join delimiter must be a string\n";
                    return;
                }

                unless (defined $delim) {
                    warn "join delimiter must be a string\n";
                    return;
                }

                return unless $calc->stack->require_depth(1);

                if (RPN::Vector::is_vector($calc->stack->peek)) {
                    my $vector = $calc->stack->pop;
                    $calc->stack->push(join($delim, $vector->values));
                    return;
                }

                my @values = reverse $calc->stack->values;
                $calc->stack->clear;
                $calc->stack->push(join($delim, @values));
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
            category => 'execution',
            help => 'repeat a string or executable value N times: string n repeat or n executable repeat',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2);

                my $top    = $calc->stack->pop;
                my $second = $calc->stack->pop;

                if ($calc->is_executable($top)) {
                    # Preferred executable order:
                    #     count executable repeat
                    my $count = $second;

                    unless (_string_is_nonnegative_integer($calc, $count)) {
                        $calc->stack->push($second);
                        $calc->stack->push($top);
                        warn "repeat requires a non-negative integer count
";
                        return;
                    }

                    for (1 .. int($count)) {
                        $calc->execute($top);
                    }

                    return;
                }

                # Existing string behavior:
                #     string count repeat
                my ($s, $count) = ($second, $top);

                unless (_string_is_nonnegative_integer($calc, $count)) {
                    $calc->stack->push($second);
                    $calc->stack->push($top);
                    warn "repeat requires a non-negative integer count
";
                    return;
                }

                $calc->stack->push($s x int($count));
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


sub _string_is_nonnegative_integer {
    my ($calc, $n) = @_;
    return !ref($n)
        && $calc->isanumber($n)
        && int($n) == $n
        && $n >= 0;
}

1;
