package RPN::Commands::Examples;

use v5.34;
use strict;
use warnings;

use File::Basename qw(basename);
use File::Find qw(find);

sub register_commands {
    my ($commands) = @_;

    $commands->register(
        examples => {
            category => 'documentation',
            help => 'list examples, optionally limited to a category',
            code => sub {
                my ($calc, $arg_str) = @_;
                my @examples = _discover_examples($calc->examples_dir);
                my $wanted = _normalize($arg_str);

                if (length $wanted) {
                    @examples = grep {
                        _category_key($_->{category}) eq _category_key($arg_str)
                    } @examples;

                    unless (@examples) {
                        warn "Unknown or empty example category '$arg_str'\n";
                        warn "Use 'examples' to list available categories\n";
                        return;
                    }
                }

                _print_index(@examples);
                return;
            },
        },
    );

    $commands->register(
        example => {
            category => 'documentation',
            help => 'display an example: example <name>',
            code => sub {
                my ($calc, $arg_str) = @_;
                my $wanted = _normalize($arg_str);

                unless (length $wanted) {
                    warn "usage: example <name>\n";
                    return;
                }

                my @matches = grep {
                    _normalize($_->{name}) eq $wanted
                        || _normalize($_->{key}) eq $wanted
                } _discover_examples($calc->examples_dir);

                unless (@matches) {
                    warn "Unknown example '$arg_str'\n";
                    warn "Use 'examples' to list available examples\n";
                    return;
                }

                if (@matches > 1) {
                    warn "Multiple examples match '$arg_str'; use one of:\n";
                    warn "  $_->{key}\n" for @matches;
                    return;
                }

                open my $fh, '<', $matches[0]{file}
                    or do {
                        warn "Cannot read example '$matches[0]{name}': $!\n";
                        return;
                    };

                print while <$fh>;
                close $fh;
                return;
            },
        },
    );

    return;
}

sub _discover_examples {
    my ($root) = @_;
    return unless defined $root && -d $root;

    my @files;
    find(
        {
            no_chdir => 1,
            wanted => sub {
                return unless -f $_ && /\.txt\z/i;
                return if basename($_) eq 'README.txt';
                push @files, $File::Find::name;
            },
        },
        $root,
    );

    my @examples;
    for my $file (sort @files) {
        my $metadata = _read_metadata($file);
        next unless $metadata->{name};

        my $relative = $file;
        $relative =~ s{^\Q$root\E/?}{};
        $relative =~ s{\.txt\z}{};

        push @examples, {
            %{$metadata},
            file => $file,
            key  => $relative,
        };
    }

    return sort {
           lc($a->{category}) cmp lc($b->{category})
        || lc($a->{name}) cmp lc($b->{name})
    } @examples;
}

sub _read_metadata {
    my ($file) = @_;

    open my $fh, '<', $file or return {};

    my %metadata;
    my $field;
    while (my $line = <$fh>) {
        last if $line !~ /^\s*#/;
        $line =~ s/^\s*#\s?//;
        $line =~ s/^\s+|\s+$//g;

        if ($line =~ /^Example:\s*(.+)$/i) {
            $metadata{name} = $1;
            $field = undef;
        }
        elsif ($line =~ /^(Category|Purpose):\s*(.*)$/i) {
            $field = lc($1) eq 'purpose' ? 'description' : lc($1);
            $metadata{$field} = $2 if length $2;
        }
        elsif (defined $field && length $line && $line !~ /^[A-Za-z ]+:\s*$/) {
            $metadata{$field} = $line unless length($metadata{$field} // '');
        }
    }
    close $fh;

    $metadata{category} //= 'Uncategorized';
    $metadata{description} //= '';
    return \%metadata;
}

sub _print_index {
    my (@examples) = @_;

    print "Available Examples\n";
    my $category = '';
    for my $example (@examples) {
        if ($example->{category} ne $category) {
            $category = $example->{category};
            print "\n$category\n";
        }
        printf "  %-32s %s\n", $example->{key}, $example->{description};
    }
    return;
}

sub _normalize {
    my ($value) = @_;
    $value = lc($value // '');
    $value =~ s/&/ and /g;
    $value =~ s/^\s+|\s+$//g;
    $value =~ s{[^\pL\pN]+}{}g;
    return $value;
}

sub _category_key {
    my ($value) = @_;
    $value //= '';
    $value =~ s/^\s*\d+\s*//;
    return _normalize($value);
}

1;
