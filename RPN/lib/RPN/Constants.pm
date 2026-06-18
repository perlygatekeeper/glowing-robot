package RPN::Constants;

use v5.34;
use strict;
use warnings;

use Data::Dumper;

sub new {
    my ($class, %args) = @_;

    my $self = bless {
        builtin => {},
        user    => {},
        file    => $args{file},
    }, $class;

    $self->_initialize_builtin_constants;

    return $self;
}

sub _initialize_builtin_constants {
    my ($self) = @_;

    $self->{builtin} = {
        pi  => 4 * atan2(1, 1),
        e   => exp(1),
        phi => (1 + sqrt(5)) / 2,

        r2  => sqrt(2),
        r3  => sqrt(3),
        r5  => sqrt(5),
        r7  => sqrt(7),
    };

    return;
}

sub names {
    my ($self) = @_;

    return sort keys %{ $self->all };
}

sub all {
    my ($self) = @_;

    return {
        %{ $self->{builtin} },
        %{ $self->{user} },
    };
}

sub exists {
    my ($self, $name) = @_;

    return exists $self->{builtin}{$name}
        || exists $self->{user}{$name};
}

sub is_builtin {
    my ($self, $name) = @_;

    return exists $self->{builtin}{$name};
}

sub get {
    my ($self, $name) = @_;

    return $self->{user}{$name}
        if exists $self->{user}{$name};

    return $self->{builtin}{$name}
        if exists $self->{builtin}{$name};

    return;
}

sub set {
    my ($self, $name, $value) = @_;

    if ($self->is_builtin($name)) {
        warn "Cannot redefine built-in constant '$name'\n";
        return;
    }

    unless (defined $name && $name =~ /^[A-Za-z_]\w*$/) {
        warn "Invalid constant name '$name'\n";
        return;
    }

    unless (defined $value && $value =~ /^[-+]?(?:(?:\d+(?:\.\d*)?)|(?:\.\d+))(?:[eE][-+]?\d+)?$/) {
        warn "Invalid constant value '$value'\n";
        return;
    }

    $self->{user}{$name} = $value + 0;

    return 1;
}

sub delete {
    my ($self, $name) = @_;

    if ($self->is_builtin($name)) {
        warn "Cannot delete built-in constant '$name'\n";
        return;
    }

    return delete $self->{user}{$name};
}

sub load_file {
    my ($self, $file) = @_;

    open my $fh, '<', $file
        or warn "Cannot read constants file '$file': $!\n" and return;

    while (my $line = <$fh>) {
        chomp $line;

        $line =~ s/#.*$//;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        next unless length $line;

        my ($name, $value);

        if ($line =~ /^([A-Za-z_]\w*)\s*=\s*(.+)$/) {
            ($name, $value) = ($1, $2);
        }
        elsif ($line =~ /^([A-Za-z_]\w*)\s+(.+)$/) {
            ($name, $value) = ($1, $2);
        }
        else {
            warn "Ignoring malformed constant line: $line\n";
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
        or warn "Cannot write constants file '$file': $!\n" and return;

    print $fh "# RPN user constants\n";
    print $fh "# name = value\n\n";

    foreach my $name (sort keys %{ $self->{user} }) {
        print $fh "$name = $self->{user}{$name}\n";
    }

    close $fh;

    return 1;
}

1;