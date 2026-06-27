package RPN::Variables;

use v5.34;

sub new {
    my ($class, %args) = @_;

    my $self = bless {
        variables => {},
        file      => $args{file} // "$ENV{HOME}/.rpn_variables",
    }, $class;

    return $self;
}

sub load_file {
    my ($self, $file) = @_;
    return unless defined $file && -s $file;
    open my $fh, '<', $file
        or warn "Cannot read variables file '$file': $!\n" and return;
    while (my $line = <$fh>) {
        chomp $line;
        $line =~ s/#.*$//;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        next unless length $line;
        my ($name, $value);
        if ($line =~ /^([A-Za-z_]\w*)\s*=\s*(.*)$/) {
            ($name, $value) = ($1, $2);
        }
        elsif ($line =~ /^([A-Za-z_]\w*)\s+(.+)$/) {
            ($name, $value) = ($1, $2);
        }
        else {
            warn "Ignoring malformed variable line: $line\n";
            next;
        }
        $self->set($name, $value);
    }
    close $fh;
    return 1;
}

sub save_file {
    my ($self, $file) = @_;
    open my $fh, '>', $file
        or warn "Cannot write variables file '$file': $!\n" and return;
    print $fh "# RPN user variables\n";
    print $fh "# name = value\n\n";
    foreach my $name ($self->names) {
        my $value = $self->get($name);
        print $fh "$name = $value\n";
    }
    close $fh;
    return 1;
}

sub exists {
    my ($self, $name) = @_;

    return exists $self->{variables}{$name};
}

sub get {
    my ($self, $name) = @_;

    return $self->{variables}{$name};
}

sub set {
    my ($self, $name, $value) = @_;

    $self->{variables}{$name} = $value;
}

sub delete {
    my ($self, $name) = @_;

    delete $self->{variables}{$name};
}

sub names {
    my ($self) = @_;

    return sort keys %{ $self->{variables} };
}

1;
