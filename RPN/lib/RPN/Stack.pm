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

sub require_depth {
    my ($self, $needed) = @_;
    if ($needed and $self->depth < $needed ) {
      warn "stack underflow: need $needed values\n";
      return 0;
    } else {
      return $needed;
    }

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
    if ($self->require_depth(2)) {
      return (
          $self->pop,
          $self->pop,
      );
    } else {
      return undef;
    }
}

sub peek {
    my ($self) = @_;
    return $self->current_stack->[0];
}

sub peek_at {
    my ($self, $index) = @_;
    $index ||= 0;
    return $self->current_stack->[$index];
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
