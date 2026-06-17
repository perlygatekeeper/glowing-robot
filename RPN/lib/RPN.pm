package RPN;

use v5.34;
use strict;
use warnings;

use RPN::Stack;
use RPN::Commands;
use Term::ReadLine;

sub new {
    my ($class) = @_;

    my $self = {
        version  => '3.0',
        debug    => 0,
        stack    => RPN::Stack->new(),
        commands => undef,
        term     => Term::ReadLine->new('Reverse Polish Notation Calculator'),
    };

    bless $self, $class;

    $self->{commands} = RPN::Commands->new($self);

    return $self;
}

sub run {
    my ($self) = @_;

    my $term = $self->{term};

    while (defined(my $input = $term->readline($self->prompt))) {
        next unless $input =~ /\S/;
        $self->process_input($input);
    }

    return;
}

sub stack {
    my ($self) = @_;
    return $self->{stack};
}

sub commands {
    my ($self) = @_;
    return $self->{commands};
}

sub prompt {
    my ($self) = @_;

    my $top = $self->stack->peek;
    $top = '-EMPTY-' unless defined $top;

    return "Input [$top] ";
}

sub isanumber {
    my ($self, $query) = @_;
    # 0xff    - hexadecimal
    # 0b1010  - binary
    # 0123    - octal
    # 1.23e5  - exponetial/scientific notation

    if        ($query =~ /^\s*[-+]?0b[01]+\b/) {
        return 'bin';
    } elsif   ($query =~ /^\s*[-+]?0[0-7]+\b/) {
        return 'oct';
    } elsif   ($query =~ /^\s*[-+]?0[xX][0-9a-fA-F]+\b/) {
        return 'hex';
    } elsif   ($query =~ /^\s*[-+]?[0-9]*\.[0-9]*[eE][-+]?[0-9]+\b/) {
        return 'exp';
    } elsif   ($query =~ /^\s*[-+]?[0-9]+\.?[0-9]*\b/) {
        return 'dec';
    }

    return;
}

sub process_input {
    my ($self, $input) = @_;

    $input =~ s/^\s+//;
    $input =~ s/\s+$//;

    return unless length $input;

    # check if the input is, in fact, a number
    my $type = $self->isanumber($input);

    if ($type) {
        if      ($type eq 'hex') {
            $self->stack->push(hex($input));
        } elsif ($type eq 'oct') {
            $self->stack->push(oct($input));
        } elsif ($type eq 'bin') {
            $self->stack->push(oct($input));   # Perl understands 0b...
        } else {
            $self->stack->push($input);
        }
        return;
    }

    unless ($self->commands->execute($self, $input)) {
        warn "Unknown input: $input\n";
    }

    return;
}

1;
