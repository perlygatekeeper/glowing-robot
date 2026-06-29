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


sub load_file {
    my ($self, $file) = @_;

    $file //= $self->{file};
    return unless defined $file && -s $file;

    open my $fh, '<', $file
        or warn "Cannot read code blocks file '$file': $!\n" and return;

    while (my $line = <$fh>) {
        chomp $line;

        $line =~ s/#.*$//;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        next unless length $line;

        my ($name, $source);

        if ($line =~ /^([A-Za-z_]\w*)\s*=\s*(\{.*\})\s*$/) {
            ($name, $source) = ($1, $2);
        }
        elsif ($line =~ /^([A-Za-z_]\w*)\s+(\{.*\})\s*$/) {
            ($name, $source) = ($1, $2);
        }
        else {
            warn "Ignoring malformed code block line: $line\n";
            next;
        }

        my $block = eval { RPN::CodeBlock->new(source => $source) };
        if (!$block) {
            warn "Ignoring invalid code block '$name': $@";
            next;
        }

        $self->define($name, $block);
    }

    close $fh;

    return 1;
}

sub save_file {
    my ($self, $file) = @_;

    $file //= $self->{file};

    open my $fh, '>', $file
        or warn "Cannot write code blocks file '$file': $!\n" and return;

    print $fh "# RPN user code blocks\n";
    print $fh "# name = { code block body }\n\n";

    foreach my $name ($self->names) {
        my $block = $self->get($name);
        print $fh "$name = ", $block->as_string, "\n";
    }

    close $fh;

    return 1;
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
