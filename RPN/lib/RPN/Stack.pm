package RPN::Stack;

use v5.34;

sub new {
    my ($class) = @_;
    my $self = bless {
        stacks       => { s => [] },
        current_name => 's',
    }, $class;

    return $self;
}

sub current_name {
    my ($self) = @_;
    return $self->{current_name};
}

sub current_stack {
    my ($self) = @_;
    return $self->{stacks}{ $self->{current_name} };
}

sub push {
    my ($self, @values) = @_;
    unshift @{ $self->current_stack }, @values;
}

sub pop {
    my ($self) = @_;
    return shift @{ $self->current_stack };
}

sub pop2 {
    my ($self) = @_;
    return (
        $self->pop,
        $self->pop,
    );
}

sub peek {
    my ($self) = @_;
    return $self->current_stack->[0];
}

sub depth {
    my ($self) = @_;
    return scalar @{ $self->current_stack };
}

sub clear {
    my ($self) = @_;
    @{ $self->current_stack } = ();
}

sub switch {
    my ($self, $name) = @_;
    $self->{stacks}{$name} //= [];
    $self->{current_name} = $name;
    return $self->{stacks}{$name};
}

sub stack_names {
    my ($self) = @_;
    return sort keys %{ $self->{stacks} };
}

sub get_stack {
    my ($self, $name) = @_;
    return $self->{stacks}{$name};
}

1;
