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

sub depth {
    my ($self) = @_;
    return scalar @{ $self->current_stack };
}

sub depth_of {
    my ($self, $name) = @_;
    return unless exists $self->{stacks}{$name};
    return scalar @{ $self->{stacks}{$name} };
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
      return;
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

sub values {
    my ($self) = @_;
    return @{ $self->current_stack };
}

sub as_hash {
    my ($self) = @_;

    return {
        current_name => $self->{current_name},
        stacks       => $self->{stacks},
    };
}

sub load_hash {
    my ($self, $data) = @_;

    return unless ref $data eq 'HASH';
    return unless ref $data->{stacks} eq 'HASH';

    $self->{stacks}       = $data->{stacks};
    $self->{current_name} = $data->{current_name} || 's';

    $self->{stacks}{ $self->{current_name} } ||= [];

    return 1;
}

1;
