package Cell;
use Moose;
use Moose::Util::TypeConstraints;
use Data::Dumper;
use Carp;

has 'given'         => (isa => 'Int',      is => 'rw');
has 'value'         => (isa => 'Value',    is => 'rw');
has 'possibilities' => (isa => 'ArrayRef', is => 'rw'); # element 0 will contain NUMBER of possilities
has 'row'           => (isa => 'Value',    is => 'rw');
has 'column'        => (isa => 'Value',    is => 'rw');
has 'box'           => (isa => 'Value',    is => 'rw');

# Methods

sub clue {
  my($self,$value) = @_;
  if ( $value =~ /[1-9]/ ) {
     $self->given(1);
     $self->value($value);
     $self->possibilities( [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] );
  } else {
     $self->given(0);
     $self->value(0);
     $self->possibilities( [ 9, 1, 2, 3, 4, 5, 6, 7, 8, 9 ] );
  }
}; 

sub remove_possibility {
  my ($self,$value) = @_;
  my ($debug) = 0;
  if ( $self->value ) {
    printf "I already have a value assigned so I will be skipped.\n" if ($debug);
    return 0;
  } elsif ( not $self->possibilities->[$value] ) {
    printf "$value has previously been removed from my possibilites array.\n" if ($debug);
    return 0;
  } else {
    printf "removing possible value $value from cell at (%d,%d,%d)\n", 1 + $self->row, 1 + $self->column, 1 + $self->box if ($debug);
    $self->possibilities->[$value] = 0;
    $self->possibilities->[0]--;
    printf "my new possibilities array contains " . join (", " , @{$self->possibilities} ) . "\n" if ($debug);
    return 1;
  }
}

sub show_my_possibilities {
  my $self = shift;
  printf "Cell at ( %d, %d, %d ) ", ( 1 + $self->row ), ( 1 + $self->column ), ( 1 + $self->box );
  if ( $self->value ) {
    if ( $self->given ) {
      print "Given:  " . $self->value . "\n";
    } else {
      print "Solved: " . $self->value . "\n";
    }
  } else {
    print "Possibilities left: " . $self->possibilities->[0] . " -> ";
    print join( ', ', ( grep { $_ != 0 } @{ $self->possibilities }[1..9] ) );
    print "\n";
  }
}

sub my_mates        { # all other cells in any of my row, column or box
  my $self = shift;

}; 

sub my_row_mates    { # all other cells in his cell's row
  my $self = shift;
  $self->row;
  return [ ];

}; 

sub my_column_mates { # all other cells in his cell's column
  my $self = shift;

}; 

sub my_box_mates    { # all other cells in his cell's box
  my $self = shift;

}; 


1;
__END__
