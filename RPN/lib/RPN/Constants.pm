package RPN::Constants;

use v5.34;
use strict;
use warnings;

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
        pi  => _record(4 * atan2(1, 1), metadata => {
            units       => 'dimensionless',
            category    => 'Mathematics',
            description => 'Ratio of circumference to diameter',
        }),
        e   => _record(exp(1), metadata => {
            units       => 'dimensionless',
            category    => 'Mathematics',
            description => 'Base of the natural logarithm',
        }),
        phi => _record((1 + sqrt(5)) / 2, metadata => {
            units       => 'dimensionless',
            category    => 'Mathematics',
            description => 'Golden ratio',
        }),

        r2  => _record(sqrt(2), metadata => {
            units       => 'dimensionless',
            category    => 'Mathematics',
            description => 'Square root of 2',
        }),
        r3  => _record(sqrt(3), metadata => {
            units       => 'dimensionless',
            category    => 'Mathematics',
            description => 'Square root of 3',
        }),
        r5  => _record(sqrt(5), metadata => {
            units       => 'dimensionless',
            category    => 'Mathematics',
            description => 'Square root of 5',
        }),
        r7  => _record(sqrt(7), metadata => {
            units       => 'dimensionless',
            category    => 'Mathematics',
            description => 'Square root of 7',
        }),
    };

    return;
}

sub names {
    my ($self) = @_;

    return sort keys %{ $self->all };
}

sub all {
    my ($self) = @_;

    my %all;

    foreach my $name (keys %{ $self->{builtin} }) {
        $all{$name} = $self->{builtin}{$name}{value};
    }

    foreach my $name (keys %{ $self->{user} }) {
        $all{$name} = $self->{user}{$name}{value};
    }

    return \%all;
}

sub all_records {
    my ($self) = @_;

    return {
        %{ $self->{builtin} },
        %{ $self->{user} },
    };
}


sub categories {
    my ($self) = @_;

    my %seen;

    foreach my $record (values %{ $self->all_records }) {
        my $category = $record->{metadata}{category};
        next unless defined $category && length $category;
        $seen{$category} = 1;
    }

    return sort { lc($a) cmp lc($b) } keys %seen;
}

sub names_in_category {
    my ($self, $category) = @_;

    return unless defined $category && length $category;

    my %wanted = (category => $category);
    _normalize_metadata(\%wanted);
    my $normalized = $wanted{category};

    my @names;

    foreach my $name (sort keys %{ $self->all_records }) {
        my $record_category = $self->all_records->{$name}{metadata}{category};
        next unless defined $record_category;
        push @names, $name if lc($record_category) eq lc($normalized);
    }

    return @names;
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

    my $record = $self->record($name);
    return unless $record;

    return $record->{value};
}

sub record {
    my ($self, $name) = @_;

    return $self->{user}{$name}
        if exists $self->{user}{$name};

    return $self->{builtin}{$name}
        if exists $self->{builtin}{$name};

    return;
}

sub metadata {
    my ($self, $name) = @_;

    my $record = $self->record($name);
    return unless $record;

    return %{ $record->{metadata} || {} };
}

sub metadata_value {
    my ($self, $name, $key) = @_;

    my $record = $self->record($name);
    return unless $record;

    $key = lc $key;
    return $record->{metadata}{$key};
}

sub set {
    my ($self, $name, $value, %args) = @_;

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

    my $metadata = $args{metadata} || {};
    $self->{user}{$name} = _record($value + 0, metadata => $metadata);

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

    my %defaults;
    my $continued = '';

    while (my $raw = <$fh>) {
        chomp $raw;

        my $line = _strip_comment($raw);
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        next unless length $line || length $continued;

        if ($line =~ s/\\\s*$//) {
            $continued .= $line . ' ';
            next;
        }

        $line = $continued . $line;
        $continued = '';

        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        next unless length $line;

        if ($line =~ /^metadata\s*:\s*(.+)$/i) {
            my $metadata_spec = $1;
            $metadata_spec =~ s/^\s+//;
            $metadata_spec =~ s/\s+$//;

            if ($metadata_spec =~ /^(?:reset|clear)$/i) {
                %defaults = ();
                next;
            }

            my $metadata = _parse_metadata($metadata_spec);
            unless ($metadata) {
                warn "Ignoring malformed metadata line: $line\n";
                next;
            }

            %defaults = (%defaults, %$metadata);
            next;
        }

        my ($head, @metadata_parts) = _split_metadata_parts($line);
        my ($name, $value);

        if ($head =~ /^([A-Za-z_]\w*)\s*=\s*(.+)$/) {
            ($name, $value) = ($1, $2);
        }
        elsif ($head =~ /^([A-Za-z_]\w*)\s+(.+)$/) {
            ($name, $value) = ($1, $2);
        }
        else {
            warn "Ignoring malformed constant line: $line\n";
            next;
        }

        $value =~ s/^\s+//;
        $value =~ s/\s+$//;

        my $line_metadata = @metadata_parts
            ? _parse_metadata(join ';', @metadata_parts)
            : {};

        unless ($line_metadata) {
            warn "Ignoring malformed constant metadata: $line\n";
            next;
        }

        my %metadata = (%defaults, %$line_metadata);
        $self->set($name, $value, metadata => \%metadata);
    }

    if (length $continued) {
        warn "Ignoring unterminated continued constant line: $continued\n";
    }

    close $fh;

    return 1;
}

sub save_file {
    my ($self, $file) = @_;

    open my $fh, '>', $file
        or warn "Cannot write constants file '$file': $!\n" and return;

    print $fh "# RPN user constants\n";
    print $fh "# name = value ; key=\"value\"\n\n";

    foreach my $name (sort keys %{ $self->{user} }) {
        my $record = $self->{user}{$name};
        print $fh "$name = $record->{value}";

        foreach my $key (sort keys %{ $record->{metadata} || {} }) {
            print $fh ' ; ', $key, '="', _escape_metadata_value($record->{metadata}{$key}), '"';
        }

        print $fh "\n";
    }

    close $fh;

    return 1;
}

sub _record {
    my ($value, %args) = @_;

    my $metadata = $args{metadata} || {};
    my %metadata = map { lc($_) => $metadata->{$_} } keys %$metadata;
    _normalize_metadata(\%metadata);

    return {
        value    => $value,
        metadata => \%metadata,
    };
}

sub _split_metadata_parts {
    my ($line) = @_;

    return _split_unquoted($line, ';');
}

sub _parse_metadata {
    my ($text) = @_;

    my %metadata;

    for my $part (_split_unquoted($text, ';')) {
        $part =~ s/^\s+//;
        $part =~ s/\s+$//;
        next unless length $part;

        unless ($part =~ /^([A-Za-z_]\w*)\s*=\s*"((?:\\.|[^"\\])*)"\s*$/) {
            return;
        }

        my ($key, $value) = (lc $1, $2);
        $metadata{$key} = _unescape_metadata_value($value);
    }

    _normalize_metadata(\%metadata);
    return \%metadata;
}

sub _normalize_metadata {
    my ($metadata) = @_;

    if (exists $metadata->{category}) {
        $metadata->{category} = join ' ',
            map { ucfirst lc }
            split /\s+/, $metadata->{category};
    }

    return;
}

sub _unescape_metadata_value {
    my ($value) = @_;

    $value =~ s/\\(["\\ntr])/
        $1 eq 'n'  ? "\n" :
        $1 eq 't'  ? "\t" :
        $1 eq 'r'  ? "\r" :
        $1
    /gex;

    return $value;
}

sub _escape_metadata_value {
    my ($value) = @_;

    $value =~ s/\\/\\\\/g;
    $value =~ s/"/\\"/g;
    $value =~ s/\n/\\n/g;
    $value =~ s/\t/\\t/g;
    $value =~ s/\r/\\r/g;

    return $value;
}

sub _strip_comment {
    my ($line) = @_;

    my $out = '';
    my $in_quote = 0;
    my $escape = 0;

    for my $char (split //, $line) {
        if ($escape) {
            $out .= $char;
            $escape = 0;
            next;
        }

        if ($char eq '\\') {
            $out .= $char;
            $escape = 1;
            next;
        }

        if ($char eq '"') {
            $in_quote = !$in_quote;
            $out .= $char;
            next;
        }

        last if !$in_quote && $char eq '#';

        $out .= $char;
    }

    return $out;
}

sub _split_unquoted {
    my ($text, $delimiter) = @_;

    my @parts;
    my $part = '';
    my $in_quote = 0;
    my $escape = 0;

    for my $char (split //, $text) {
        if ($escape) {
            $part .= $char;
            $escape = 0;
            next;
        }

        if ($char eq '\\') {
            $part .= $char;
            $escape = 1;
            next;
        }

        if ($char eq '"') {
            $in_quote = !$in_quote;
            $part .= $char;
            next;
        }

        if (!$in_quote && $char eq $delimiter) {
            push @parts, $part;
            $part = '';
            next;
        }

        $part .= $char;
    }

    push @parts, $part;
    return @parts;
}

1;
