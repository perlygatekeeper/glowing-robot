package RPN;

use v5.34;
use strict;
use warnings;

use RPN::Stack;
use RPN::Commands;
use RPN::Constants;
use RPN::Variables;
use Term::ReadLine;
use Data::Dumper;

sub new {
    my ($class, %args) = @_;

    my $self = {
        version    => '3.4.0',
        debug      => 0,
        angle_mode => 'radians',
        commands   => undef,
        term       => undef,
        constants  => RPN::Constants->new(),
        variables  => RPN::Variables->new(),
        stack      => RPN::Stack->new(),
        history    => [],
        io => 'file input and output',
    };

    bless $self, $class;

    $self->{term} = $args{no_readline}
        ? undef
        : Term::ReadLine->new('Reverse Polish Notation Calculator');

    $self->load_history;
    $self->load_stacks;
    $self->load_constants;
    $self->load_variables;

    $self->{commands} = RPN::Commands->new($self);

    return $self;
}

sub variables_file {
    my ($self) = @_;
    return $ENV{RPN_VARIABLES} || "$ENV{HOME}/.rpn_variables";
}

sub history_file {
    my ($self) = @_;
    return $ENV{RPN_HISTORY} || "$ENV{HOME}/.rpn_history";
}

sub stacks_file {
    my ($self) = @_;
    return $ENV{RPN_STACKS} || "$ENV{HOME}/.rpn_stacks";
}

sub constants_file {
    my ($self) = @_;
    return $ENV{RPN_CONSTANTS} || "$ENV{HOME}/.rpn_constants";
}

sub add_history {
    my ($self, $input) = @_;
    return unless defined $input && $input =~ /\S/;
    push @{ $self->{history} }, $input;
    return unless $self->{term};
    if ($self->{term}->can('addhistory')) {
        $self->{term}->addhistory($input);
    }
    elsif ($self->{term}->can('AddHistory')) {
        $self->{term}->AddHistory($input);
    }
    return;
}

sub load_history {
    my ($self) = @_;
    my $file = $self->history_file;
    return unless defined $file && -s $file;
    open my $fh, '<', $file
        or do {
            warn "Cannot read $file: $!\n";
            return;
        };
    my @history = grep { defined && /\S/ } map { chomp; $_ } <$fh>;
    close $fh;
    $self->{history} = [ @history ];
    if (@history && $self->{term} && $self->{term}->can('SetHistory')) {
        $self->{term}->SetHistory(@history);
    }
    return;
}

sub save_history {
    my ($self) = @_;
    my $file = $self->history_file;
    my @history = $self->history;
    @history = grep { defined && /\S/ } @history;
    open my $fh, '>', $file
        or do {
            warn "Cannot write $file: $!\n";
            return;
        };
    foreach my $line (@history) {
        chomp $line;
        print {$fh} "$line\n";
    }
    close $fh;
    return;
}

sub load_stacks {
    my ($self) = @_;
    $self->stack->load_file($self->stacks_file);
    return;
}

sub save_stacks {
    my ($self) = @_;
    $self->stack->save_file($self->stacks_file);
    return;
}

sub load_constants {
    my ($self) = @_;
    my $file = $self->constants_file;
    return unless defined $file && -s $file;
    $self->constants->load_file($file);
    return;
}

sub save_constants {
    my ($self) = @_;
    $self->constants->save_file($self->constants_file);
    return;
}

sub load_variables {
    my ($self) = @_;
    return $self->variables->load_file($self->variables_file);
}

sub save_variables {
    my ($self) = @_;
    return $self->variables->save_file($self->variables_file);
}

sub constants {
    my ($self) = @_;
    return $self->{constants};
}

sub variables {
    my ($self) = @_;
    return $self->{variables};
}

sub nearly_zero {
    my ($self, $value) = @_;
    return abs($value) < 1e-12;
}

sub run {
    my ($self) = @_;

    die "Cannot run interactively without Term::ReadLine\n"
        unless $self->{term};

    my $term = $self->{term};

    while (defined(my $input = $term->readline($self->prompt))) {
        next unless $input =~ /\S/;
        $self->add_history($input);
        $self->process_input($input);
    }

    $self->save_history;
    $self->save_stacks;
    $self->save_constants;;
    $self->save_variables;

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
    # Constant input.
    #

    if ($input =~ /^[A-Za-z_]\w*$/ && $self->constants->exists($input)) {
        $self->stack->push($self->constants->get($input));
        return;
    }

    #
    # Variables input.
    #

    if ($input =~ /^[A-Za-z_]\w*$/ && $self->variables->exists($input)) {
        $self->stack->push($self->variables->get($input));
        return 1;
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
    return @{ $self->{history} }
        if $self->{history} && @{ $self->{history} };
    return unless $self->{term} && $self->{term}->can('GetHistory');
    return $self->{term}->GetHistory();
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
