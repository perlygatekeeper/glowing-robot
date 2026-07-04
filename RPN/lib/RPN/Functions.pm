package RPN::Functions;

use v5.34;
use strict;
use warnings;

sub new {
    my ($class) = @_;

    my $self = bless {
        functions => {},
    }, $class;

    return $self;
}

sub get {
    my ($self, $name) = @_;

    return $self->{functions}{$name};
}

sub names {
    my ($self) = @_;

    return sort keys %{ $self->{functions} };
}

sub exists {
    my ($self, $name) = @_;

    return exists $self->{functions}{$name};
}

sub set {
    my ($self, $name, $body) = @_;

    $self->{functions}{$name} = $body;

    return 1;
}

sub delete {
    my ($self, $name) = @_;

    return delete $self->{functions}{$name};
}

sub load_file {
    my ($self, $file) = @_;

    return unless defined $file && -s $file;

    open my $fh, '<', $file
        or warn "Cannot read functions file '$file': $!\n" and return;

    while (my $line = <$fh>) {
        chomp $line;

        $line =~ s/#.*$//;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        next unless length $line;

        my ($name, $body);

        if ($line =~ /^([A-Za-z_0-9]\w*)\s*=\s*(.+)$/) {
            ($name, $body) = ($1, $2);
        }
        elsif ($line =~ /^([A-Za-z_0-9]\w*)\s+(.+)$/) {
            ($name, $body) = ($1, $2);
        }
        else {
            warn "Ignoring malformed function line: $line\n";
            next;
        }

        $self->set($name, $body);
    }

    close $fh;

    return 1;
}

sub save_file {
    my ($self, $file) = @_;

    open my $fh, '>', $file
        or warn "Cannot write functions file '$file': $!\n" and return;

    print $fh "# RPN user functions\n";
    print $fh "# name = function body\n\n";

    foreach my $name ($self->names) {
        my $body = $self->get($name);
        print $fh "$name = $body\n";
    }

    close $fh;

    return 1;
}

1;
