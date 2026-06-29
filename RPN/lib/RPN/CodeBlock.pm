package RPN::CodeBlock;

use v5.34;
use strict;
use warnings;

use Scalar::Util qw(blessed);

sub new {
    my ($class, %args) = @_;

    my ($source, $body) = _normalize_source_body(%args);

    my $self = bless {
        source => $source,
        body   => $body,
        steps  => [ map { _classify_token($_) } _tokenize_body($body) ],
    }, $class;

    return $self;
}

sub is_codeblock {
    my ($thing) = @_;

    return blessed($thing) && $thing->isa(__PACKAGE__);
}

sub source {
    my ($self) = @_;

    return $self->{source};
}

sub body {
    my ($self) = @_;

    return $self->{body};
}

sub steps {
    my ($self) = @_;

    return map { { %$_ } } @{ $self->{steps} };
}

sub as_string {
    my ($self) = @_;

    return $self->{source};
}

sub _normalize_source_body {
    my (%args) = @_;

    die "code block requires source or body\n"
        unless exists $args{source} || exists $args{body};

    my $body;

    if (exists $args{body}) {
        $body = _trim($args{body});
    }
    else {
        my $source = _trim($args{source});

        die "code block source must begin with { and end with }\n"
            unless $source =~ /^\{(.*)\}$/s;

        $body = _trim($1);
    }

    my $source = $body eq '' ? '{ }' : "{ $body }";

    return ($source, $body);
}

sub _tokenize_body {
    my ($body) = @_;

    return () if !defined($body) || $body eq '';

    return split /\s+/, $body;
}

sub _classify_token {
    my ($token) = @_;

    if ($token =~ /^[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?$/) {
        return {
            kind  => 'number',
            token => $token,
            value => 0 + $token,
        };
    }

    if ($token =~ /^"(.*)"$/s || $token =~ /^'(.*)'$/s) {
        return {
            kind  => 'string',
            token => $token,
            value => $1,
        };
    }

    return {
        kind  => 'command',
        token => $token,
    };
}

sub _trim {
    my ($value) = @_;

    $value = '' unless defined $value;
    $value =~ s/^\s+//;
    $value =~ s/\s+$//;

    return $value;
}

1;
