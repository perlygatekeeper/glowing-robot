package RPN;

use v5.34;
use strict;
use warnings;

use RPN::Stack;
use RPN::Commands;
use RPN::Constants;
use RPN::Variables;
use RPN::Functions;
use RPN::CodeBlocks;
use RPN::CodeBlock;
use RPN::Vector;
use RPN::Matrix;
use Term::ReadLine;
use Cwd qw(abs_path);
use Data::Dumper;

# Constuctor

sub new {
    my ($class, %args) = @_;

    my $install_dir = abs_path($args{install_dir} // '.')
        || $args{install_dir}
        || '.';

    my $self = {
        version             => '3.9.0',
        debug               => 0,
        angle_mode          => 'radians',
        install_dir         => $install_dir,
        prompt_template     => exists $args{prompt} ? $args{prompt} : 'RPN> ',
        commands            => undef,
        term                => undef,
        stack               => RPN::Stack->new(),
        constants           => RPN::Constants->new(),
        functions           => RPN::Functions->new(),
        codeblocks          => undef,
        variables           => RPN::Variables->new(),
        history             => [],
        function_call_stack => [],
    };

    bless $self, $class;

    $self->{term} = $args{no_readline}
        ? undef
        : Term::ReadLine->new('Reverse Polish Notation Calculator');

    $self->{files} = {
        history   => $ENV{RPN_HISTORY}   || "$ENV{HOME}/.rpn_history",
        stacks    => $ENV{RPN_STACKS}    || "$ENV{HOME}/.rpn_stacks",
        variables => $ENV{RPN_VARIABLES} || "$ENV{HOME}/.rpn_variables",
        constants => $ENV{RPN_CONSTANTS} || "$ENV{HOME}/.rpn_constants",
        functions  => $ENV{RPN_FUNCTIONS}  || "$ENV{HOME}/.rpn_functions",
        codeblocks => $ENV{RPN_CODEBLOCKS} || "$ENV{HOME}/.rpn_codeblocks",
    };

    $self->{first_run} =
           ! -e $self->{files}{history}
        || -z $self->{files}{history};

    $self->load_history;
    $self->load_stacks;
    $self->load_constants( $self->file('constants') )
        if -e $self->file('constants');
    $self->load_variables( $self->file('variables') );
    $self->{codeblocks} = RPN::CodeBlocks->new(file => $self->file('codeblocks'));
    $self->load_functions( $self->file('functions') );
    $self->load_codeblocks( $self->file('codeblocks') );
    $self->{commands} = RPN::Commands->new($self);

    return $self;
}

sub run {
    my ($self) = @_;

    die "Cannot run interactively without Term::ReadLine\n"
        unless $self->{term};

    my $term = $self->{term};

    if ($self->{first_run}) {
        print "\n";
        print "Welcome to the RPN Calculator.\n";
        print "\n";
        print "New here? Try:\n";
        print "\n";
        print "    quickstart\n";
        print "\n";
        print "for a 10-minute introduction.\n";
        print "\n";
    }

    $self->{running} = 1;

    while ($self->{running} && defined(my $input = $term->readline($self->prompt))) {
        next unless $input =~ /\S/;
        push @{ $self->{history} }, $input;
        $self->process_input($input);
    }

    $self->save_all;

    return;
}

# Persistence filename recover method

sub file {
    my ($self, $name) = @_;

    return $self->{files}{$name}
        if exists $self->{files}{$name};

    die "Unknown persistence file '$name'\n";
}


sub save_all {
    my ($self) = @_;
    $self->save_history;
    $self->save_stacks;
    $self->save_constants( $self->file('constants') );
    $self->save_variables( $self->file('variables') );
    $self->save_functions( $self->file('functions') );
    $self->save_codeblocks( $self->file('codeblocks') );
    return;
}

# Accessor commands

sub history {
    my ($self) = @_;
    return @{ $self->{history} }
        if $self->{history} && @{ $self->{history} };
    return unless $self->{term} && $self->{term}->can('GetHistory');
    return $self->{term}->GetHistory();
}

sub functions {
    my ($self) = @_;
    return $self->{functions};
}

sub codeblocks {
    my ($self) = @_;
    return $self->{codeblocks};
}

sub stack {
    my ($self) = @_;
    return $self->{stack};
}

sub commands {
    my ($self) = @_;
    return $self->{commands};
}

sub constants {
    my ($self) = @_;
    return $self->{constants};
}

sub variables {
    my ($self) = @_;
    return $self->{variables};
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

sub version {
    my ($self) = @_;
    return $self->{version};
}

sub install_dir {
    my ($self) = @_;
    return $self->{install_dir};
}

sub docs_dir {
    my ($self) = @_;
    return $self->install_dir . '/docs';
}

sub tutorials_dir {
    my ($self) = @_;
    return $self->docs_dir . '/tutorials';
}

sub examples_dir {
    my ($self) = @_;
    return $self->install_dir . '/examples';
}

sub constants_dir {
    my ($self) = @_;
    return $self->install_dir . '/constants';
}

# History methods

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

# Persistence load/save methods

# HISTORY
sub load_history {
    my ($self) = @_;
    my $file = $self->file('history');
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
    my $file = $self->file('history');
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

# STACKS
sub load_stacks {
    my ($self) = @_;
    $self->stack->load_file( $self->file('stacks') );
    return;
}

sub save_stacks {
    my ($self) = @_;
    $self->stack->save_file( $self->file('stacks') );
    return;
}

# CONSTANTS
#       if -e $self->file('history');
#       if -e $self->file('stacks');
#       if -e $self->file('constants');
#       if -e $self->file('variables');
#       if -e $self->file('functions');
sub load_constants {
    my ($self, $file) = @_;

    $file = $self->file('constants')
        unless defined $file && length $file;

    return $self->{constants}->load_file($file);
}

sub save_constants {
    my ($self, $file) = @_;

    $file = $self->file('constants')
        unless defined $file && length $file;

    return $self->{constants}->save_file($file);
}

# VARIABLES
sub load_variables {
    my ($self, $file) = @_;

    $file = $self->file('variables')
        unless defined $file && length $file;

    return $self->{variables}->load_file($file);
}

sub save_variables {
    my ($self, $file) = @_;

    $file = $self->file('variables')
        unless defined $file && length $file;

    return $self->{variables}->save_file($file);
}

# FUNCTIONS
sub save_functions {
    my ($self, $file) = @_;

    $file = $self->file('functions')
        unless defined $file && length $file;

    return $self->{functions}->save_file($file);
}

sub load_functions {
    my ($self, $file) = @_;

    $file = $self->file('functions')
        unless defined $file && length $file;

    return $self->{functions}->load_file($file);
}

# CODE BLOCKS
sub save_codeblocks {
    my ($self, $file) = @_;

    $file = $self->file('codeblocks')
        unless defined $file && length $file;

    return $self->{codeblocks}->save_file($file);
}

sub load_codeblocks {
    my ($self, $file) = @_;

    $file = $self->file('codeblocks')
        unless defined $file && length $file;

    return $self->{codeblocks}->load_file($file);
}

# Helper methods

sub format_value {
    my ($self, $value) = @_;

    return $value->as_string
        if ref($value) && $value->can('as_string');

    return $value;
}

sub nearly_zero {
    my ($self, $value) = @_;
    return abs($value) < 1e-12;
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

sub is_number_list {
    my ($self, $input) = @_;
    my @tokens = grep { length } split /[\s,;]+/, $input;
    return unless @tokens > 1;
    foreach my $token (@tokens) {
        return unless $self->isanumber($token);
    }
    return 1;
}

sub angle_to_radians {
    my ($self, $value) = @_;
    return $value if $self->angle_mode eq 'radians';
    return $value * atan2(1, 1) / 45;
}

# Methods needed to interpret and execute inputs

sub prompt {
    my ($self) = @_;
    return $self->current_prompt;
}

sub current_prompt {
    my ($self) = @_;

    my $prompt = $self->{prompt_template};

    my %tokens = (
        TOS       => sub { $self->prompt_tos },
        DEPTH     => sub { $self->stack->depth },
        STACKNAME => sub { $self->stack->current_name },
    );

    $prompt =~ s/%([^%]+)%/
        exists $tokens{$1} ? $tokens{$1}->() : "%$1%"
    /gex;

    return $prompt;
}

sub prompt_tos {
    my ($self) = @_;

    my $top = $self->stack->peek;
    return '-EMPTY-' unless defined $top;

    return $self->format_value($top);
}

sub strip_input_comment {
    my ($self, $input) = @_;

    return '' unless defined $input;

    my $quote;
    my $escaped = 0;
    my $out = '';

    foreach my $char (split //, $input) {
        if ($escaped) {
            $out .= $char;
            $escaped = 0;
            next;
        }

        if (defined $quote && $char eq '\\') {
            $out .= $char;
            $escaped = 1;
            next;
        }

        if ($char eq q{"} || $char eq q{'}) {
            if (defined $quote) {
                undef $quote if $char eq $quote;
            }
            else {
                $quote = $char;
            }

            $out .= $char;
            next;
        }

        last if !defined($quote) && $char eq '#';

        $out .= $char;
    }

    return $out;
}

sub process_input {
    my ($self, $input) = @_;

    $input = $self->strip_input_comment($input);

    $input =~ s/^\s+//;
    $input =~ s/\s+$//;

    return unless length $input;

    # We examine the input and perform the lookup search in the following order:
    # This ordering is IMPORTANT for maintaining a sane and working namespace
    # of commands, aliases, user-defined functions, variables, constants and abbreviated command names
    #
    # 1) CodeBlock literal
    # 2) Quoted string
    # 3) Numeric list
    # 4) Single Number
    # 5) Command or an Alias (named exactly, names registered, ie. not abbreviated)
    # 6) Function
    # 7) Constant
    # 8) Variable
    # 9) Abbreviated Command
    # 10) Unknown

    # 1) CodeBlock literal input.
    # Accepts a single-line literal such as:
    #   { dup * }
    # Nested CodeBlocks and multi-line CodeBlocks are intentionally deferred.

    if ($input =~ /^\{.*\}$/s) {
        my $body = $input;
        $body =~ s/^\{\s*//;
        $body =~ s/\s*\}$//;

        if ($body =~ /[{}]/) {
            warn "Nested code blocks are not supported yet
";
            return;
        }

        my $block = eval { RPN::CodeBlock->new(source => $input) };
        if (!$block) {
            warn $@ || "Invalid code block literal
";
            return;
        }

        $self->stack->push($block);
        return;
    }

    if ($input =~ /^\{/ || $input =~ /\}$/) {
        warn "Invalid code block literal
";
        return;
    }

    # 2) Quoted string input.
    # Accepts:
    #   "hello
    #   "hello"
    #   'hello
    #   'hello'

    if ($input =~ /^(['"])(.*)$/) {
        my $quote = $1;
        my $value = $2;

        $value =~ s/\Q$quote\E$//
            if length($value);

        $self->stack->push($value);
        return;
    }

    #
    # 3) Numeric list input.
    # Accepts:
    #   12 14 18 20 16
    #   12,14,18,20,16
    #   12, 14, 18, 20, 16
    #   12;14;18

    if ($self->is_number_list($input)) {
        my @tokens = grep { length } split /[\s,;]+/, $input;

        foreach my $token (@tokens) {
            $self->push_number($token);
        }

        return;
    }

    #
    # 4) Single number input.
    #

    if ($self->isanumber($input)) {
        $self->push_number($input);
        return;
    }

    #
    # 5) Registered commands or aliases
    #

    if ($self->commands->execute_registered($self, $input)) {
        return;
    }

    #
    # 6) User-defined Functions
    #

    if ($input =~ /^[A-Za-z_]\w*$/ && $self->functions->exists($input)) {
        $self->execute_function($input);

        #       removed to make recursion possible
        #       my $body = $self->functions->get($input);
        #       foreach my $token (split /\s+/, $body) {
        #           next unless length $token;
        #           $self->process_input($token);
        #       }
        #
        return;
    }

    #
    # 7) Constants
    #

    if ($input =~ /^[A-Za-z_]\w*$/ && $self->constants->exists($input)) {
        $self->stack->push($self->constants->get($input));
        return;
    }

    #
    # 8) Variables
    #

    if ($input =~ /^[A-Za-z_]\w*$/ && $self->variables->exists($input)) {
        $self->stack->push($self->variables->get($input));
        return;
    }

    #
    # 9) Abbreviated Commands
    #

    if ($self->commands->execute($self, $input)) {
        return;
    }

    warn "Unknown input: $input\n";

    return;
}

sub push_number {
    my ($self, $token) = @_;
    my $type = $self->isanumber($token)
        or return;
    if ($type eq 'hex' || $type eq 'oct' || $type eq 'bin') {
        $self->stack->push(oct($token));
    } else {
        $self->stack->push($token);
    }
    return 1;
}


sub is_executable {
    my ($self, $value) = @_;

    return 1 if RPN::CodeBlock::is_codeblock($value);

    return 0 if ref $value;
    return 0 unless defined $value;

    my $source = $value;
    $source =~ s/^\s+//;
    $source =~ s/\s+$//;

    return 0 unless length $source;
    return 0 if $self->isanumber($source);

    return 1;
}

sub execute {
    my ($self, $value) = @_;

    die "execute requires an executable value\n"
        unless $self->is_executable($value);

    if (RPN::CodeBlock::is_codeblock($value)) {
        return $self->_execute_codeblock($value);
    }

    return $self->_execute_token_string($value);
}

sub _execute_token_string {
    my ($self, $source) = @_;

    foreach my $token (split /\s+/, $source) {
        next unless length $token;
        $self->process_input($token);
    }

    return 1;
}

sub _execute_codeblock {
    my ($self, $block) = @_;

    foreach my $step ($block->steps) {
        my $token = $step->{token};
        next unless defined $token && length $token;
        $self->process_input($token);
    }

    return 1;
}

sub execute_function {
    my ($self, $name) = @_;

    unless ($self->functions->exists($name)) {
        warn "No such function '$name'\n";
        return;
    }

    if (grep { $_ eq $name } @{ $self->{function_call_stack} }) {
        warn "Recursive function call detected: $name\n";
        return;
    }

    push @{ $self->{function_call_stack} }, $name;

    my $body = $self->functions->get($name);

    foreach my $token (split /\s+/, $body) {
        next unless length $token;
        $self->process_input($token);
    }

    pop @{ $self->{function_call_stack} };

    return 1;
}

1;
