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
        version    => '3.0',
        debug      => 0,
        angle_mode => 'radians',
        stack      => RPN::Stack->new(),
        commands   => undef,
        term       => Term::ReadLine->new('Reverse Polish Notation Calculator'),
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

sub process_input {
    my ($self, $input) = @_;

    $input =~ s/^\s+//;
    $input =~ s/\s+$//;

    return unless length $input;

    #
    # Quoted string input.
    # Accepts:
    #   "hello
    #   "hello"
    #   'hello
    #   'hello'
    #

    if ($input =~ /^(['"])(.*)$/) {
        my $quote = $1;
        my $value = $2;

        $value =~ s/\Q$quote\E$//
            if length($value);

        $self->stack->push($value);
        return;
    }

    #
    # Numeric list input.
    # Accepts:
    #   12 14 18 20 16
    #   12,14,18,20,16
    #   12, 14, 18, 20, 16
    #   12;14;18
    #

    if ($self->is_number_list($input)) {
        my @tokens = grep { length } split /[\s,;]+/, $input;

        foreach my $token (@tokens) {
            $self->push_number($token);
        }

        return;
    }

    #
    # Single number input.
    #

    if ($self->isanumber($input)) {
        $self->push_number($input);
        return;
    }

    #
    # Command input.
    #

    unless ($self->commands->execute($self, $input)) {
        warn "Unknown input: $input\n";
    }

    return;
}

sub version {
    my ($self) = @_;
    return $self->{version};
}

sub history {
    my ($self) = @_;

    return $self->{term}->GetHistory();
}

sub nearly_zero {
    my ($self, $value) = @_;

    return abs($value) < 1e-12;
}

sub is_number_list {
    my ($self, $input) = @_;

    my @tokens = grep { length } split /[\s,;]+/, $input;

    return unless @tokens > 1;

    foreach my $token (@tokens) {
        return unless $self->isanumber($token);
    }

    return 1;
}

sub push_number {
    my ($self, $token) = @_;

    my $type = $self->isanumber($token)
        or return;

    if ($type eq 'hex' || $type eq 'oct' || $type eq 'bin') {
        $self->stack->push(oct($token));
    }
    else {
        $self->stack->push($token);
    }

    return 1;
}

sub isanumber {
    my ($self, $query) = @_;

    return 'bin'
        if $query =~ /^\s*[-+]?0b[01]+\b/i;

    return 'hex'
        if $query =~ /^\s*[-+]?0x[0-9a-f]+\b/i;

    return 'oct'
        if $query =~ /^\s*[-+]?0[0-7]+\b/;

    return 'dec'
        if $query =~ /^\s*[-+]?(?:
                    (?:\d+(?:\.\d*)?) |
                    (?:\.\d+)
                  )
                  (?:[eE][-+]?\d+)?
                  \s*$/x;

    return;
}

sub angle_mode {
    my ($self, $mode) = @_;

    if (defined $mode) {
        die "unknown angle mode '$mode'\n"
            unless $mode eq 'radians' || $mode eq 'degrees';

        $self->{angle_mode} = $mode;
    }

    return $self->{angle_mode};
}

sub angle_to_radians {
    my ($self, $value) = @_;

    return $value if $self->angle_mode eq 'radians';

    return $value * atan2(1, 1) / 45;
}

1;
