package RPN::Commands;

use strict;
use warnings;
use Text::Abbrev qw(abbrev);

sub new {
my ($class, $calc) = @_;

my $self = {
    calc     => $calc,
    commands => {},
    abbrevs  => {},
    types    => {},
};

bless $self, $class;

$self->_initialize();

return $self;

}

sub _initialize {
my ($self) = @_;

$self->{types} = {
    boolean    => 'true or false',
    constant   => 'named constants',
    conversion => 'unit conversions',
    debug      => 'developer functions',
    flow       => 'flow control',
    numeric    => 'arithmetic functions',
    stack      => 'stack manipulation',
    string     => 'string operations',
    trig       => 'trigonometric functions',
    utility    => 'help, display, quit',
};

#
# First commands migrated
#

$self->register(
    add => {
        type => 'numeric',
        help => 'pops two numbers and pushes their sum',
        code => sub {
            my ($calc) = @_;
            my ( $a, $b ) = $calc->stack->pop2;
            $calc->stack->push($b + $a);
        },
    }
);

$self->register(
    subtract => {
        aliases => ['-'],
        type    => 'numeric',
        help    => 'pops two numbers and pushes their difference',
        code    => sub {
            my ($calc) = @_;
            my ( $a, $b ) = $calc->stack->pop2;
            $calc->stack->push($b - $a);
        },
    }
);

$self->register(
    multiply => {
        aliases => ['*'],
        type    => 'numeric',
        help    => 'pops two numbers and pushes their product',
        code    => sub {
            my ($calc) = @_;
            my ( $a, $b ) = $calc->stack->pop2;
            $calc->stack->push($b * $a);
        },
    }
);

$self->register(
    divide => {
        aliases => ['/'],
        type    => 'numeric',
        help    => 'pops two numbers and pushes their quotient',
        code => sub {
            my ($calc) = @_;
            return unless $calc->stack->require_depth(2);
            my $divisor = $calc->stack->peek_at(0);
            if ($divisor == 0) {
               warn "divide by zero\n";
               return;
            }
            my ($a, $b) = $calc->stack->pop2;
            $calc->stack->push($b / $a);
        },
    }
);

$self->register(
    peek => {
        aliases => ['.'],
        type    => 'utility',
        help    => 'prints top value on stack',
        code    => sub {
            my ($calc) = @_;
            my $value = $calc->stack->peek;
            print "$value\n" if defined $value;
        },
    }
);

$self->register(
    "pop" => {
      # aliases => ['.'],
        type    => 'stack',
        help    => 'removes top value on stack',
        code    => sub {
            my ($calc) = @_;
            $calc->stack->pop;
        },
    }
);

$self->register(
    duplicate => {
      # aliases => ['.'],
        type    => 'stack',
        help    => 'prints top value on stack',
        code    => sub {
            my ($calc) = @_;
            my $value = $calc->stack->peek;
            $calc->stack->push($value);
        },
    }
);

$self->register(
    exchange => {
      # aliases => ['.'],
        type    => 'stack',
        help    => 'exchange top two values on stack',
        code    => sub {
            my ($calc) = @_;
            my ($a,$b) = $calc->stack->pop2;
            $calc->stack->push($a, $b);
        },
    }
);

$self->register(
    clear => {
      # aliases => ['.'],
        type    => 'stack',
        help    => 'removes all values on stack',
        code    => sub {
            my ($calc) = @_;
            $calc->stack->clear;
        },
    }
);

$self->register(
    depth => {
      # aliases => ['.'],
        type    => 'stack',
        help    => 'prints number of values on stack',
        code    => sub {
            my ($calc) = @_;
            $calc->stack->push($calc->stack->depth);
        },
    }
);

$self->register(
    quit => {
        aliases => [qw(exit bye ZZ)],
        type    => 'utility',
        help    => 'exit program',
        code    => sub {
            my ($calc) = @_;
            exit 0;
        },
    }
);

# keep this rebuild_abbrevs as last line of _initialize()
$self->_rebuild_abbrevs();
}

sub register {
    my ($self, $name, $definition) = @_;
    $self->{commands}{$name} = $definition;
    return;
}

sub _rebuild_abbrevs {
    my ($self) = @_;
    my %abbrevs;
    abbrev(\%abbrevs, sort keys %{ $self->{commands} });
    foreach my $name (keys %{ $self->{commands} }) {
        $abbrevs{$name} = $name;

        if (my $aliases = $self->{commands}{$name}{aliases}) {
            foreach my $alias (@$aliases) {
                $abbrevs{$alias} = $name;
            }
        }
    }
    $self->{abbrevs} = \%abbrevs;
    return;
}

sub command {
  my ($self, $name) = @_;

  my $real = $self->{abbrevs}{$name}
      or return;

  return $self->{commands}{$real};

}

sub execute {
  my ($self, $calc, $input) = @_;

  my ($command) = split /\s+/, $input, 2;

  my $entry = $self->command($command)
      or return 0;

  my $code = $entry->{code}
      or return 0;

  $code->($calc);

  return 1;

}

sub commands {
  my ($self) = @_;

  return $self->{commands};

}

1;

