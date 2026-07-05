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
                return unless $calc->stack->require_depth(1,'join');

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

                return unless $calc->stack->require_depth(1,'join 2nd');

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
        sprintf => {
            category => 'string',
            help => 'format values using a printf format string on top of the stack and push the result: 1 "[%d]" sprintf; 2 3 5 "%d + %d = %d" sprintf',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1,'sprintf');

                my $format = $calc->stack->pop;

                if (ref $format || !defined $format) {
                    $calc->stack->push($format);
                    warn "sprintf format must be a string\n";
                    return;
                }

                my $arg_count = _sprintf_arg_count($format);

                unless (defined $arg_count) {
                    $calc->stack->push($format);
                    warn "sprintf invalid format string\n";
                    return;
                }

                unless ($calc->stack->require_depth($arg_count,'sprintf 2nd')) {
                    $calc->stack->push($format);
                    return;
                }

                my @args = reverse map { $calc->stack->pop } 1 .. $arg_count;

                my $result = eval { sprintf($format, @args) };
                if ($@) {
                    $calc->stack->push($format, reverse @args);
                    warn "sprintf failed: $@";
                    return;
                }

                $calc->stack->push($result);
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
                return unless $calc->stack->require_depth(2,'repeat');

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

sub _sprintf_arg_count {
    my ($format) = @_;

    my $count = 0;
    my $saw_conversion = 0;

    while ($format =~ /%(%|(?:\d+\$)?([-+ 0#]*)(\*|\d+)?(?:\.(\*|\d+))?(?:[hljztLqv]+)?[bcdeEufFgGosxXopsiDUO])/g) {
        next if $1 eq '%';
        $saw_conversion = 1;
        $count++;
        $count++ if defined($3) && $3 eq '*';
        $count++ if defined($4) && $4 eq '*';
    }

    return 0 if !$saw_conversion && $format !~ /%/;
    return $count if $saw_conversion;
    return;
}

1;
