package RPN::CodeBlocks;

use v5.34;
use strict;
use warnings;

use RPN::CodeBlock;

sub new {
    my ($class, %args) = @_;

    my $self = bless {
        blocks => {},
        file   => $args{file},
    }, $class;

    return $self;
}

sub define {
    my ($self, $name, $block) = @_;

    _validate_name($name);
    die "code block registry requires an RPN::CodeBlock value\n"
        unless RPN::CodeBlock::is_codeblock($block);

    $self->{blocks}{$name} = $block;

    return 1;
}

sub undefine {
    my ($self, $name) = @_;

    return delete $self->{blocks}{$name};
}

sub delete {
    my ($self, $name) = @_;

    return $self->undefine($name);
}

sub exists {
    my ($self, $name) = @_;

    return exists $self->{blocks}{$name};
}

sub get {
    my ($self, $name) = @_;

    return $self->{blocks}{$name};
}

sub names {
    my ($self) = @_;

    return sort keys %{ $self->{blocks} };
}

sub _validate_name {
    my ($name) = @_;

    die "code block name is required\n"
        unless defined $name && length $name;

    die "invalid code block name '$name'\n"
        unless $name =~ /^[A-Za-z_]\w*$/;

    return 1;
}

1;
