package RPN::Stack;

use v5.34;
use strict;
use warnings;

use Data::Dumper;

sub new {
    my ($class) = @_;
    my $self = bless {
        stacks       => { 'default' => [] },
        current_name => 'default',
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
    $self->{current_name} = $data->{current_name} || 'default';

    $self->{stacks}{ $self->{current_name} } ||= [];

    return 1;
}


sub save_file {
    my ($self, $file) = @_;

    open my $fh, '>', $file
        or do {
            warn "Cannot write stack file '$file': $!\n";
            return;
        };

    local $Data::Dumper::Terse  = 1;
    local $Data::Dumper::Purity = 1;

    print {$fh} Data::Dumper->Dump([ $self->as_hash ]);
    print {$fh} "\n";

    close $fh;

    return 1;
}

sub load_file {
    my ($self, $file) = @_;

    return unless defined $file && -s $file;

    my $data = do $file;

    if ($@) {
        warn "Cannot parse stack file '$file': $@\n";
        return;
    }

    unless (defined $data) {
        warn "Cannot read stack file '$file': $!\n" if $!;
        return;
    }

    return $self->load_hash($data);
}

sub set_values {
    my ($self, @values) = @_;
    @{ $self->current_stack } = @values;
    return;
}

sub clear_all {
    my ($self) = @_;

    $self->{stacks} = { default => [] };
    $self->{current_name} = 'default';

    return;
}

sub delete_stack {
    my ($self, $name) = @_;

    unless (defined $name && length $name) {
        warn "Stack name required\n";
        return;
    }

    unless ($self->stack_exists($name)) {
        warn "Unknown stack '$name'\n";
        return;
    }

    if ($name eq 'default') {
        warn "Cannot delete the default stack\n";
        return;
    }

    if ($name eq $self->current_name) {
        warn "Cannot delete the current stack\n";
        return;
    }

    delete $self->{stacks}{$name};

    return 1;
}

sub stack_exists {
    my ($self, $name) = @_;
    return defined $name && exists $self->{stacks}{$name};
}

sub stack_size {
    my ($self, $name) = @_;

    return $self->depth
        unless defined $name && length $name;

    return unless $self->stack_exists($name);

    return scalar @{ $self->{stacks}{$name} };
}

sub copy_stack {
    my ($self, $src, $dst) = @_;

    unless ($self->stack_exists($src)) {
        warn "Unknown source stack '$src'\n";
        return;
    }

    unless (defined $dst && length $dst) {
        warn "Destination stack name required\n";
        return;
    }

    @{ $self->{stacks}{$dst} } = @{ $self->{stacks}{$src} };

    return 1;
}

sub dup_stack {
    my ($self, $dst) = @_;

    unless (defined $dst && length $dst) {
        warn "Destination stack name required\n";
        return;
    }

    return $self->copy_stack($self->current_name, $dst);
}

sub rename_stack {
    my ($self, $old, $new) = @_;

    unless ($self->stack_exists($old)) {
        warn "Unknown stack '$old'\n";
        return;
    }

    unless (defined $new && length $new) {
        warn "New stack name required\n";
        return;
    }

    if ($self->stack_exists($new)) {
        warn "Stack '$new' already exists\n";
        return;
    }

    $self->{stacks}{$new} = delete $self->{stacks}{$old};

    if ($self->{current_name} eq $old) {
        $self->{current_name} = $new;
    }

    return 1;
}

sub clear_named_stack {
    my ($self, $name) = @_;

    unless ($self->stack_exists($name)) {
        warn "Unknown stack '$name'\n";
        return;
    }

    @{ $self->{stacks}{$name} } = ();

    return 1;
}

sub merge_stacks {
    my ($self, $src, $dst) = @_;

    unless ($self->stack_exists($src)) {
        warn "Unknown source stack '$src'\n";
        return;
    }

    unless ($self->stack_exists($dst)) {
        warn "Unknown destination stack '$dst'\n";
        return;
    }

    CORE::unshift @{ $self->{stacks}{$dst} }, @{ $self->{stacks}{$src} };

    return 1;
}

sub pour_stack {
    my ($self, $src, $dst) = @_;

    unless ($self->stack_exists($src)) {
        warn "Unknown source stack '$src'\n";
        return;
    }

    unless ($self->stack_exists($dst)) {
        warn "Unknown destination stack '$dst'\n";
        return;
    }

    my $current = $self->current_name;

    while (@{ $self->{stacks}{$src} }) {
        $self->switch($src);
        my $value = $self->pop;

        $self->switch($dst);
        $self->push($value);
    }

    $self->switch($current);

    return 1;
}

1;
