package Grid;
use Moose;
use Moose::Util::TypeConstraints;
use Data::Dumper;
use Carp;
use Cell;

has 'difficulty'  => (isa => 'Difficulty', is => 'rw');
has 'notes'       => (isa => 'String',     is => 'rw');
has 'solved'      => (isa => 'Int',        is => 'rw');
has 'rows'        => (isa => 'ArrayRef',   is => 'rw');
has 'columns'     => (isa => 'ArrayRef',   is => 'rw');
has 'boxes'       => (isa => 'ArrayRef',   is => 'rw');
has 'cells'       => (isa => 'ArrayRef',   is => 'rw');

# Methods
#
# Input of grid, setting each cell and establishing the rows, columns and boxes structures
# Output 'see below'
#
# given cell number, CELL, from 0 to 80 (0 will be reserved for string)
#
# ROW    = 1 + int(CELL/9) -> 1..9
# COLUMN = 1 + mod(CELL/9) -> 1..9
# BOX    = 1 + ( mod(CELL/9) / 3 ) + int(CELL/9) / 3 -> 1..9

sub load_from_string {
  my($self,$string) = @_;
  my($cell) = 0;
  $self->solved(0);
  $self->cells([]);
  $self->rows([[],[],[],[],[],[],[],[],[]]);
  $self->columns([[],[],[],[],[],[],[],[],[]]);
  $self->boxes([[],[],[],[],[],[],[],[],[]]);
# print $self->cells   . " <- cells\n";
# print $self->rows    . " <- rows\n";
# print $self->columns . " <- columns\n";
# print $col . " <- col\n";
# print $self->columns->[0] . " <- column->[0]\n";
# print $self->boxes   . " <- boxes\n";
  foreach ( split(//,$string) ) {
    s/[^1-9]/0/; # Change any character not 1, 2, 3, 4, 5, 6, 7, 8 OR 9  TO A  '0'  Such as underscores, dashes, periods or spaces
    my($col) = ( $cell  % 9 );
    my($row) = int( $cell / 9 );
    my($box) = int( ( $cell % 9 ) / 3 ) + 3 * int ( int( $cell / 9 ) / 3 );
    my ($new_cell) =  Cell->new;
    $new_cell->clue($_);
    $new_cell->row($row);    # print "Debug: " . $new_cell->row . " should be $row\n";
    $new_cell->column($col);
    $new_cell->box($box);

    $self->cells->[$cell++]      = $new_cell;
    push ( @{$self->rows->[$row]},    $new_cell );
    push ( @{$self->columns->[$col]}, $new_cell );
    push ( @{$self->boxes->[$box]},   $new_cell );
  }
# print "We have populated the grid with the given clues,
# now we will remove the given's as possibilities from their rows, columns and boxes.\n";
  foreach ( grep { $_->value } @{$self->cells} ) {
    $self->solved( 1 + $self->solved );
    $self->remove_my_solution_from_my_mates($_);
  }
}

sub find_and_set_singletons {  # a singleton is a cell which has only one possible value left
  my $self  = shift;
  my $progress = 0;
  print "Looking for Singletons (cells with only one possible value left) :\n";
  foreach my $this_cell ( @{ $self->cells } ) {
    # check if this cell has only one possibility left, and if so set it and clear it's value from row, column and box neighboors.
    if ( $this_cell->possibilities->[0] == 1 ) {
      $progress++;
      $self->solved( 1 + $self->solved );
      my($value,) = grep { $_ != 0 } @{$this_cell->possibilities}[1..9];
      $this_cell->value($value);
      printf "Setting cell ( %d, %d, %d ) to %d\n"
        , ( $this_cell->row + 1 )
        , ( $this_cell->column + 1 )
        , ( $this_cell->box + 1 )
        , $this_cell->value;
      $this_cell->possibilities( [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] );
      $self->remove_my_solution_from_my_mates($this_cell);
    }
  }
  print "Found and set $progress cells this singletons search pass.\n\n";
  return $progress;
}

sub cell_from_row_column {
  my ( $self, $row, $column ) = @_;
  my $cell;
  $cell = $self->rows->[$row]->[$column];
  return $cell;
}

sub find_and_set_lone_representatives {  # a lone_representative is only cell with a possible value in a cell cluster (row column or box)
  my $self  = shift;
  my $progress  = 0;
  my $possible_value;
  my $possibility_counts = {};
  # Plan: foreach cluster, count the number of cells foreach unsolved value
  # case 1) value has only one cell, this is a "lone representative" and may be assigned immediately
  # case 2) value has two or three cells.  If these cells all reside in another cluster, this value may be removed as a possibility 
  #         in that other cluster's other member cells
  # case 3) naked pair    two   cells with the same two   possibilites put this one in it's own method
  # case 4) naked triplet three cells with the same three possibilites put this one in it's own method as well
  # Starting with case 1:

  print "Looking for Lone representatives (possible value's present in only one cell of a cluster [row column or box]):\n";

  $possibility_counts = $self->possibilities_hash;
  # we now have a cell count of all possible values for all cells organized by cell cluster
  # we will search these counts for a 1, this represents a value that has only one cell in this box
  # in which this value is still a possibility.
  # CHECK BOXES FOR LONE REPRESENTATIVES
  foreach my $key ( sort grep { $_ =~ /box/ } keys %{ $possibility_counts } ) {
#   print "DEBUG - key for possibility_counts is $key\n"; next;
    if ( scalar ( @{ $possibility_counts->{$key} } ) == 1 ) { # found a lone representative cell/value
      ( $possible_value = $key ) =~ s/box\d://;
      $progress++;
      $self->solved( 1 + $self->solved );
      my $lone_representative = $possibility_counts->{$key}[0];
      $lone_representative->value($possible_value);
      $lone_representative->possibilities( [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] );
      $self->remove_my_solution_from_my_mates($lone_representative);
      printf "Lone in Box    Setting cell ( %d, %d, %d ) to %d\n"
        , ( $lone_representative->row + 1 )
        , ( $lone_representative->column + 1 )
        , ( $lone_representative->box + 1 )
        , $possible_value;
    }
  }

  # refresh possibility_counts hash as the lone representatives in BOXES above may have exposed more in ROWS
  $possibility_counts = $self->possibilities_hash;
  # we now have a new cell count of all possible values for all cells organized by cell cluster
  # we will search these counts for a 1, this represents a value that has only one cell in this row
  # in which this value is still a possibility.
  # CHECK ROWS FOR LONE REPRESENTATIVES
  foreach my $key ( grep { $_ =~ /row/ } keys %{ $possibility_counts } ) {
    if ( scalar ( @{ $possibility_counts->{$key} } ) == 1 ) { # found a lone representative cell/value
      ( $possible_value = $key ) =~ s/row\d://;
      $progress++;
      $self->solved( 1 + $self->solved );
      my $lone_representative = $possibility_counts->{$key}[0];
      $lone_representative->value($possible_value);
      $lone_representative->possibilities( [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] );
      $self->remove_my_solution_from_my_mates($lone_representative);
      printf "Lone in Row    Setting cell ( %d, %d, %d ) to %d\n"
        , ( $lone_representative->row + 1 )
        , ( $lone_representative->column + 1 )
        , ( $lone_representative->box + 1 )
        , $possible_value;
    }
  }

  # refresh possibility_counts hash as the lone representatives in ROWS above may have exposed more in COLS
  $possibility_counts = $self->possibilities_hash;
  # CHECK COLUMNS FOR LONE REPRESENTATIVES
  # we now have a new cell count of all possible values for all cells organized by cell cluster
  # we will search these counts for a 1, this represents a value that has only one cell in this column
  # in which this value is still a possibility.
  foreach my $key ( grep { $_ =~ /col/ } keys %{ $possibility_counts } ) {
    if ( scalar ( @{ $possibility_counts->{$key} } ) == 1 ) { # found a lone representative cell/value
      ( $possible_value = $key ) =~ s/col\d://;
      $progress++;
      $self->solved( 1 + $self->solved );
      my $lone_representative = $possibility_counts->{$key}[0];
      $lone_representative->value($possible_value);
      $lone_representative->possibilities( [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] );
      $self->remove_my_solution_from_my_mates($lone_representative);
      printf "Lone in Column Setting cell ( %d, %d, %d ) to %d\n"
        , ( $lone_representative->row + 1 )
        , ( $lone_representative->column + 1 )
        , ( $lone_representative->box + 1 )
        , $possible_value;
      $progress++;
    }
  }

  print "Found and set $progress cells this lone representatives search pass.\n\n";
  return $progress;
}

# I have returned and and am fixing this, as there are serveral puzzles
# in sudoku17-50, that will be solved with the proper find of a single remote pair.
# specifical 21 and 24.
sub find_remote_pairs {
  my $self = shift;
  my $progress = 0;
  my ( $cluster, $pair, $pairs );
  print "Looking for Remote Pairs, any two cells with the same\n";
  print "pair of possible values that exist in the different clusters [row column or box]):\n";
  my $pairs_by_cluster = $self->pairs_possible_by_cluster;
  # Find all naked pairs, that are represented twice in any given cluster, these are what are needed
  # to form the links in the chain of a remote pair.
  foreach my $key ( grep { scalar ( @{ $pairs_by_cluster->{$_} } ) == 2 } keys %{ $pairs_by_cluster } ) {
    ( $cluster, $pair ) = ( $key =~ /([rcb]o[wlx]:\d) -> (\d\d)/ ) ;
    $pairs->{$pair}{$cluster} = $pairs_by_cluster->{$key};
  }
# $pairs_by_cluster->{ "row:7 -> 57" } would be an array containing all cells with only 5 and 7 candidate values in row 7.
  foreach my $pair ( keys %$pairs ) {
    printf "Remote pair candidate: %s is in %d cells.\n", $pair, scalar ( @{ $pairs_by_cluster->{$pair} } ) ;
    # We have a pair that appears at least 4 times
    # See if we any group of 4, 6 or 8 cells form a chain.
  }
  # Once we have a pairs chain with an even number of cells, check any intersecting cells to remove
  # either member of the pair of candidate values being processed.
  print "Found and processed $progress cells this remote pair search pass.\n\n";
  return $progress;
}

sub find_naked_pairs {
  my $self = shift;
  my $progress = 0;
  print "Looking for Naked Pairs, any two cells with the same\n";
  print "pair of possible values that exist in the same cluster [row column or box]):\n";

  my $pairs = $self->pairs_possible_by_cluster;

  # look for pairs that have 2 cells

  foreach my $key ( grep { scalar ( @{ $pairs->{$_} } == 2 ) } keys %{ $pairs } ) {
    # we have a naked pair
    if ( $key =~ /row/ ) {
      my ( $col1, $col2, $row, $pair1, $pair2 );
      ( $row, $pair1, $pair2 )  = ( $key =~ /row:(\d) -> (\d)(\d)/ );
      # find the columns of the 2 cells holding the naked pair
      $col1 = $pairs->{ $key }[0]->column;
      $col2 = $pairs->{ $key }[1]->column;
      foreach my $cell ( grep { not $_->value } ( @{ $self->rows->[$row] } ) ) { # find unsolved cells in this row that aren't either of the naked pair.
        my $col = $cell->column;
        next if ( $col == $col1 or  $col == $col2 );
        # if $pair1 is still possible in this cell, remove it.
        if ( $cell->possibilities->[$pair1] ) {
          if ( $cell->possibilities->[$pair1] ) {
            printf "Naked pair in row %d, cols %d and %d leads to %d being removed from cell ( %d, %d, %d ).\n"
                   , $row + 1 , $col1 + 1 , $col2 + 1 , $pair1
                   , ( $cell->row + 1 )
                   , ( $cell->column + 1 )
                   , ( $cell->box + 1 );
            $cell->possibilities->[$pair1] = 0;
            $cell->possibilities->[0] = $cell->possibilities->[0] - 1;
            $progress++;
          }
        }
        # if $pair2 is still possible in this cell, remove it.
        if ( $cell->possibilities->[$pair2] ) {
          if ( $cell->possibilities->[$pair2] ) {
            printf "Naked pair in row %d, cols %d and %d leads to %d being removed from cell ( %d, %d, %d ).\n"
                   , $row + 1 , $col1 + 1 , $col2 + 1 , $pair2
                   , ( $cell->row + 1 )
                   , ( $cell->column + 1 )
                   , ( $cell->box + 1 );
            $cell->possibilities->[$pair2] = 0;
            $cell->possibilities->[0] = $cell->possibilities->[0] - 1;
            $progress++;
          }
        }
      }
    }

    if ( $key =~ /col/ ) {
      my ( $row1, $row2, $col, $pair1, $pair2 );
      ( $col, $pair1, $pair2 )  = ( $key =~ /col:(\d) -> (\d)(\d)/ );
      # find the columns of the 2 cells holding the naked pair
      $row1 = $pairs->{ $key }[0]->row;
      $row2 = $pairs->{ $key }[1]->row;
      foreach my $cell ( grep { not $_->value } ( @{ $self->columns->[$col] } ) ) { # find unsolved cells in this column that aren't either of the naked pair.
        my $row = $cell->row;
        next if ( $row == $row1 or  $row == $row2 );
        # if $pair1 is still possible in this cell, remove it.
        if ( $cell->possibilities->[$pair1] ) {
          if ( $cell->possibilities->[$pair1] ) {
            printf "Naked pair in col %d, rows %d and %d leads to %d being removed from cell ( %d, %d, %d ).\n"
                   , $col + 1 , $row1 + 1 , $row2 + 1 , $pair1
                   , ( $cell->row + 1 )
                   , ( $cell->column + 1 )
                   , ( $cell->box + 1 );
            $cell->possibilities->[$pair1] = 0;
            $cell->possibilities->[0] = $cell->possibilities->[0] - 1;
            $progress++;
          }
        }
        # if $pair2 is still possible in this cell, remove it.
        if ( $cell->possibilities->[$pair2] ) {
          if ( $cell->possibilities->[$pair2] ) {
            printf "Naked pair in col %d, rows %d and %d leads to %d being removed from cell ( %d, %d, %d ).\n"
                   , $col + 1 , $row1 + 1 , $row2 + 1 , $pair2
                   , ( $cell->row + 1 )
                   , ( $cell->column + 1 )
                   , ( $cell->box + 1 );
            $cell->possibilities->[$pair2] = 0;
            $cell->possibilities->[0] = $cell->possibilities->[0] - 1;
            $progress++;
          }
        }
      }
    }

    if ( $key =~ /box/ ) {
      my ( $row1, $row2, $col1, $col2, $box, $pair1, $pair2 );
      ( $box, $pair1, $pair2 )  = ( $key =~ /box:(\d) -> (\d)(\d)/ );
      # find the rows and columns of the 2 cells holding the naked pair
      $row1 = $pairs->{ $key }[0]->row;
      $row2 = $pairs->{ $key }[1]->row;
      $col1 = $pairs->{ $key }[0]->column;
      $col2 = $pairs->{ $key }[1]->column;
      foreach my $cell ( grep { not $_->value } ( @{ $self->boxes->[$box] } ) ) { # find unsolved cells in this row that aren't either of the naked pair.
        my $row = $cell->row;
        my $col = $cell->column;
        next if ( ( $row == $row1 and $col == $col1 )
               or ( $row == $row2 and $col == $col2 ) );
        # if $pair1 is still possible in this cell, remove it.
        if ( $cell->possibilities->[$pair1] ) {
          if ( $cell->possibilities->[$pair1] ) {
            printf "Naked pair in box %d, cells ( %d, %d ) and ( %d, %d ) leads to %d being removed from cell ( %d, %d, %d ).\n"
                   , $box + 1 , $row1 + 1 , $col1 + 1 , $row2 + 1 , $col2 + 1
                   , $pair1
                   , ( $cell->row + 1 )
                   , ( $cell->column + 1 )
                   , ( $cell->box + 1 );
            $cell->possibilities->[$pair1] = 0;
            $cell->possibilities->[0] = $cell->possibilities->[0] - 1;
            $progress++;
          }
        }
        # if $pair2 is still possible in this cell, remove it.
        if ( $cell->possibilities->[$pair2] ) {
          if ( $cell->possibilities->[$pair2] ) {
            printf "Naked pair in box %d, cells ( %d, %d ) and ( %d, %d ) leads to %d being removed from cell ( %d, %d, %d ).\n"
                   , $box + 1 , $row1 + 1 , $col1 + 1 , $row2 + 1 , $col2 + 1
                   , $pair2
                   , ( $cell->row + 1 )
                   , ( $cell->column + 1 )
                   , ( $cell->box + 1 );
            $cell->possibilities->[$pair2] = 0;
            $cell->possibilities->[0] = $cell->possibilities->[0] - 1;
            $progress++;
          }
        }
      }
    }
  }

  print "Found and processed $progress naked pairs.\n\n";
  return $progress;
}

sub find_x_wings {
  my $self  = shift;
  my $x_wings = 0;
  my $debug = 1;
  my $progress = 0;
  my ( $pairs, $value );
  my ( $row, $column );
  my $xwing_candidates;
  print "Looking for X-Wings, any 4 cells with the same possible value\n";
  print "that are only candidates in two cells of a given column or row and\n";
  print "involve the same two rows or columns respectively, thus forming an X:\n";

  # COLUMNS
  my $possibility_counts = $self->possibilities_hash;
  $pairs = [ grep { $_ =~ /col/ and scalar( @{ $possibility_counts->{$_} } ) == 2 } keys %{ $possibility_counts } ];
  print "#pairs ( " . scalar @$pairs . " ) \n";
  if ( scalar @$pairs ) {
    foreach my $key ( @$pairs ) {
      ( $column, $value )  = ( $key =~ /col(\d):(\d)/ );
      push ( @{ $xwing_candidates->{$value} } , $column );
      # $xwing_candidates->{ value is 4 } is array with all columns where it appears only twice
    }
    print "xwing_candidates: ( $xwing_candidates) \n";
    # loop over all values which have 2 or more columns where this value only appears twice as a candidate
    # for each pair of such columns see if this value forms an x-wing
    foreach $value ( grep { scalar( @{$xwing_candidates->{$_}} ) >= 2 } keys %$xwing_candidates ) {
      printf "X-wing (column-based): processing value $value,  " if ($debug);
      printf "which has %d columns where it appears as a candidate only twice.\n", scalar( @{ $xwing_candidates->{$value} } ) if ($debug);
      foreach my $first    ( 0               ..  ( $#{$xwing_candidates->{$value}} - 1 ) ) { # from first to next-to-last
        foreach my $second ( ( $first + 1 )  ..  $#{$xwing_candidates->{$value}}         ) { # from one after first to last
          my $first_column  = $xwing_candidates->{$value}[$first];
          my $second_column = $xwing_candidates->{$value}[$second];
          if ($debug) {
              printf "Examining columns %d and %d.\n"
                     , 1 + $first_column
                     , 1 + $second_column;
          }
          # I have a pair of columns for which $value shows up only twice as a candidate
          # if they happen to be in the same two rows, this will form an X-Wing and this value may be removed
          # from all other cells in the two rows which aren't part of the x-wing, see notes_x_wings.txt file
          # for more information.
          my $row_count = {};
          # process the 2 cells in the first column, noting the row in which they reside
          foreach my $cell ( @{ $possibility_counts->{ 'col' . $first_column  . ':' . $value } } ) {
            $row_count->{ $cell->row }++;
          }
          # process the 2 cells in the second column, noting the row in which they reside
          foreach my $cell ( @{ $possibility_counts->{ 'col' . $second_column . ':' . $value } } ) {
            $row_count->{ $cell->row }++;
          }
          if ( scalar ( keys( %$row_count )  )  == 2 ) { 
            if ($debug) {
              printf "We have found a column-based X-wing for $value, involving columns %d and %d and rows %d and %d!\n"
                     , 1 + $first_column
                     , 1 + $second_column
                     , map { 1 + $_ } keys %$row_count;
            }
            $x_wings++;
            foreach my $row ( keys %$row_count ) {
              foreach my $cell ( @{ $possibility_counts->{ 'row' . $row . ':' . $value } } ) {
                next if ( $cell->column == $first_column or $cell->column == $second_column );
                if ($debug) {
                  printf "X-wing column-based: removal of %d from cell at ( %d, %d )\n"
                         , $value
                         , 1 + $row
                         , 1 + $cell->column;
                }
                $progress += $cell->remove_possibility($value);
              }
            }
          }
        }
      }
    }
  } else {
    print "Found no row-based pair possibilities.\n";
  }

  # ROWS
  $xwing_candidates = {};
  $possibility_counts = $self->possibilities_hash;
  $pairs = [ grep { $_ =~ /row/ and scalar( @{ $possibility_counts->{$_} } ) == 2 } keys %{ $possibility_counts } ];
  if ( scalar @$pairs ) {
    foreach my $key ( @$pairs ) {
      ( $row, $value )  = ( $key =~ /row(\d):(\d)/ );
      push ( @{ $xwing_candidates->{$value} } , $row );
      # $xwing_candidates->{ value is 4 } is array with all rows where it appears only twice
    }
    # loop over all values which have 2 or more rows where this value only appears twice as a candidate
    # for each pair of such rows see if this value forms an x-wing
    foreach $value ( grep { scalar( @{$xwing_candidates->{$_}} ) >= 2 } keys %$xwing_candidates ) {
      printf "X-wing (row-based): processing value $value,  " if ($debug);
      printf "which has %d rows where it appears as a candidate only twice.\n", scalar( @{ $xwing_candidates->{$value} } ) if ($debug);
      foreach my $first    ( 0               ..  ( $#{$xwing_candidates->{$value}} - 1 ) ) { # from first to next-to-last
        foreach my $second ( ( $first + 1 )  ..  $#{$xwing_candidates->{$value}}         ) { # from one after first to last
          my $first_row  = $xwing_candidates->{$value}[$first];
          my $second_row = $xwing_candidates->{$value}[$second];
          if ($debug) {
              printf "Examining rows %d and %d.\n"
                     , 1 + $first_row
                     , 1 + $second_row;
          }
          # I have a pair of rows for which $value shows up only twice as a candidate
          # if they happen to be in the same two columns, this will form an X-Wing and this value may be removed
          # from all other cells in the two columns which aren't part of the x-wing.
          my $column_count = {};
          # process the 2 cells in the first column, noting the row in which they reside
          foreach my $cell ( @{ $possibility_counts->{ 'row' . $first_row  . ':' . $value } } ) {
            $column_count->{ $cell->column }++;
          }
          # process the 2 cells in the second column, noting the row in which they reside
          foreach my $cell ( @{ $possibility_counts->{ 'row' . $second_row . ':' . $value } } ) {
            $column_count->{ $cell->column }++;
          }
          if ( scalar ( keys( %$column_count )  )  == 2 ) { 
            if ($debug) {
              printf "We have found a row-based X-wing for $value, involving rows %d and %d and columns %d and %d!\n"
                     , 1 + $first_row
                     , 1 + $second_row
                     , map { 1 + $_ } keys %$column_count;
            }
            $x_wings++;
            foreach my $column ( keys %$column_count ) {
              foreach my $cell ( @{ $possibility_counts->{ 'col' . $column . ':' . $value } } ) {
                next if ( $cell->row == $first_row or $cell->row == $second_row );
                if ($debug) {
                  printf "X-wing row-based: removal of %d from cell at ( %d, %d )\n"
                         , $value
                         , 1 + $cell->row
                         , 1 + $column;
                }
                $progress += $cell->remove_possibility($value);
              }
            }
          }
        }
      }
    }
  } else {
    print "Found no row-based pair possibilities.\n";
  }
  
  print "Found and processed $x_wings X-Wings which resulted in $progress candidates being removed.\n\n";
  return $progress;
}

sub find_hidden_pairs {
  my $self  = shift;
  my $progress = 0;
  my $pairs;
  print "Looking for Hidden Pairs, (any two candidate values which exist \n";
  print "only in the same two cells in a given cluster):\n";
  my $possibility_counts = $self->possibilities_hash;
# { # DEBUG
#   print "---- find_hidden_pairs: Start all possibility counts ------\n";
#   printf "%d %s\n", scalar( @{ $possibility_counts->{$_} } ), $_ foreach ( sort grep { $_=~/col6/ } keys %{ $possibility_counts } );
#   print "---- find_hidden_pairs: End   all possibility counts ------\n";
# }

  # Box examination
  $pairs = [ sort grep { $_ =~ /box/ and scalar( @{ $possibility_counts->{$_} } ) == 2 } keys %{ $possibility_counts } ];
  # pairs holds keys representing candidate values that are present only twice in a given box
  foreach my $first ( 0 .. ( $#{$pairs} - 1 ) ) { # from first to next-to-last
    foreach my $second ( ( $first + 1 ) .. $#{$pairs} ) { # from one after first to last
      my( $box1, $box2, $value1, $value2, $cell1, $cell2 );
      ( $box1, $value1 ) = ( $pairs->[$first]  =~ /box(\d):(\d)/ );
      ( $box2, $value2 ) = ( $pairs->[$second] =~ /box(\d):(\d)/ );
      next if ( $box1 != $box2 );
      printf "Hidden pair (box): comparing candadate values %s and %s.\n", $pairs->[$first], $pairs->[$second];
      next if ( $possibility_counts->{$pairs->[$first] }[0]->row    != $possibility_counts->{$pairs->[$second]}[0]->row );
      next if ( $possibility_counts->{$pairs->[$first] }[0]->column != $possibility_counts->{$pairs->[$second]}[0]->column );
      print "Two candidate values shared first cell.\n";
      next if ( $possibility_counts->{$pairs->[$first] }[1]->row    != $possibility_counts->{$pairs->[$second]}[1]->row );
      next if ( $possibility_counts->{$pairs->[$first] }[1]->column != $possibility_counts->{$pairs->[$second]}[1]->column );
      print "Two candidate values shared second cell!  We have a pair.\n";
      # two cells are the same for value1 and value2
      $cell1 = $possibility_counts->{$pairs->[$first] }[0];
      $cell2 = $possibility_counts->{$pairs->[$first] }[1];
      if ( $cell1->possibilities->[0] > 2 ) { # first cell of this pair of candidate values have other candidate values
        foreach my $value ( grep { $_ } @{ $cell1->possibilities }[1..9] ) {
          print "Hidden pair (box): processing fist cell: candidate value $value?\n";
          next if ( $value == $value1 or $value == $value2 );
          print "Hidden pair (box): processing fist cell: Remove it!\n";
          # remove all others
          $cell1->remove_possibility($value);
        }
        print "Removed all other candidate values from first cell.\n";
      }
      if ( $cell2->possibilities->[0] > 2 ) { # second cell of this pair of candidate values have other candidate values
        foreach my $value ( grep { $_ } @{ $cell1->possibilities }[1..9] ) {
          next if ( $value == $value1 or $value == $value2 );
          # remove all others
          $cell2->remove_possibility($value);
        }
        print "Removed all other candidate values from second cell.\n";
      }
    }
  }

  # Row examination
  $pairs = [ sort grep { $_ =~ /row/ and scalar( @{ $possibility_counts->{$_} } ) == 2 } keys %{ $possibility_counts } ];
  # pairs holds keys representing candidate values that are present only twice in a given row
  foreach my $first ( 0 .. ( $#{$pairs} - 1 ) ) {         # from first to next-to-last
    foreach my $second ( ( $first + 1 ) .. $#{$pairs} ) { # from one after first to last
      my( $row1, $row2, $value1, $value2, $cell1, $cell2 );
      ( $row1, $value1 ) = ( $pairs->[$first]  =~ /row(\d):(\d)/ );
      ( $row2, $value2 ) = ( $pairs->[$second] =~ /row(\d):(\d)/ );
      next if ( $row1 != $row2 );
      printf "Hidden pair (row): comparing candadate values %s and %s.\n", $pairs->[$first], $pairs->[$second];
      next if ( $possibility_counts->{$pairs->[$first] }[0]->column != $possibility_counts->{$pairs->[$second]}[0]->column );
      print "Two candidate values shared first cell.\n";
      next if ( $possibility_counts->{$pairs->[$first] }[1]->column != $possibility_counts->{$pairs->[$second]}[1]->column );
      print "Two candidate values shared second cell!  We have a pair.\n";
      # two cells are the same for value1 and value2
      $cell1 = $possibility_counts->{$pairs->[$first] }[0];
      $cell2 = $possibility_counts->{$pairs->[$first] }[1];
      if ( $cell1->possibilities->[0] > 2 ) { # first cell of this pair of candidate values have other candidate values
        foreach my $value ( grep { $_ } @{ $cell1->possibilities }[1..9] ) {
          print "Hidden pair (row): processing fist cell: candidate value $value?\n";
          next if ( $value == $value1 or $value == $value2 );
          print "Hidden pair (row): processing fist cell: Remove it!\n";
          # remove all others
          $cell1->remove_possibility($value);
        }
        print "Removed all other candidate values from first cell.\n";
      }
      if ( $cell2->possibilities->[0] > 2 ) { # second cell of this pair of candidate values have other candidate values
        foreach my $value ( grep { $_ } @{ $cell1->possibilities }[1..9] ) {
          next if ( $value == $value1 or $value == $value2 );
          # remove all others
          $cell2->remove_possibility($value);
        }
        print "Removed all other candidate values from second cell.\n";
      }
    }
  }

  # Column examination
  $pairs = [ sort grep { $_ =~ /col/ and scalar( @{ $possibility_counts->{$_} } ) == 2 } keys %{ $possibility_counts } ];
  # pairs holds keys representing candidate values that are present only twice in a given column
  foreach my $first ( 0 .. ( $#{$pairs} - 1 ) ) {         # from first to next-to-last
    foreach my $second ( ( $first + 1 ) .. $#{$pairs} ) { # from one after first to last
      my( $col1, $col2, $value1, $value2, $cell1, $cell2 );
      ( $col1, $value1 ) = ( $pairs->[$first]  =~ /col(\d):(\d)/ );
      ( $col2, $value2 ) = ( $pairs->[$second] =~ /col(\d):(\d)/ );
      next if ( $col1 != $col2 );
      printf "Hidden pair (col): comparing candadate values %s and %s.\n", $pairs->[$first], $pairs->[$second];
      next if ( $possibility_counts->{$pairs->[$first] }[0]->row != $possibility_counts->{$pairs->[$second]}[0]->row );
      print "Two candidate values shared first cell.\n";
      next if ( $possibility_counts->{$pairs->[$first] }[1]->row != $possibility_counts->{$pairs->[$second]}[1]->row );
      print "Two candidate values shared second cell!  We have a pair.\n";
      # two cells are the same for value1 and value2
      $cell1 = $possibility_counts->{$pairs->[$first] }[0];
      $cell2 = $possibility_counts->{$pairs->[$first] }[1];
      if ( $cell1->possibilities->[0] > 2 ) { # first cell of this pair of candidate values have other candidate values
        foreach my $value ( grep { $_ } @{ $cell1->possibilities }[1..9] ) {
          print "Hidden pair (col): processing fist cell: candidate value $value?\n";
          next if ( $value == $value1 or $value == $value2 );
          print "Hidden pair (col): processing fist cell: Remove it!\n";
          # remove all others
          $cell1->remove_possibility($value);
        }
        print "Removed all other candidate values from first cell.\n";
      }
      if ( $cell2->possibilities->[0] > 2 ) { # second cell of this pair of candidate values have other candidate values
        foreach my $value ( grep { $_ } @{ $cell1->possibilities }[1..9] ) {
          next if ( $value == $value1 or $value == $value2 );
          # remove all others
          $cell2->remove_possibility($value);
        }
        print "Removed all other candidate values from second cell.\n";
      }
    }
  }

  print "Found and processed $progress hidden pairs.\n\n";
  return $progress;
}

# An imaginary value is a value whose only possible locations in one cluster are all exclusively in a single cluster of a different kind 
# See see the notes_imaginary_values.txt
sub find_imaginary_values {
  my $self  = shift;
  my $progress = 0;
  my $possible_value;
  print "Looking for Imaginary Values (all 2 or 3 representatives of a given value in a cluster share all belong to another cluster):\n";

  my $possibility_counts = $self->possibilities_hash;
  foreach my $key ( sort grep { $_ =~ /box/ } keys %{ $possibility_counts } ) {
    if ( scalar ( @{ $possibility_counts->{$key} } ) == 2 or scalar ( @{ $possibility_counts->{$key} } ) == 3 ) {
      # examine all cells in the possibility count and see if they are all in the row or same column
      my ( $cell_rows, $cell_cols, $box );
      foreach my $cell ( @{ $possibility_counts->{$key} } ) {
#       printf "IV-box: examining cell at ( %d, %d, %d ).\n"
#             , ( $cell->row + 1 )
#             , ( $cell->column + 1 )
#             , ( $cell->box + 1 );
        $cell_rows->{$cell->row}++;
        $cell_cols->{$cell->column}++;
      }
      # we now have a count of the unique cols and rows of these cells.
      # if either is a count of one, then all cells share the same row or column
      if ( ( scalar keys %{$cell_rows} ) == 1 ) {
        # all cells in this box representing this possible value live in the same row
        # if there are any cells in this row but outside of this box we can safely
        # remove this possible value from these "outside" cells
        my $row = ( keys %{$cell_rows} )[0];
        ( $box, $possible_value ) = ( $key =~ /box(\d):(\d)/);
        # do we have cells with this value outside this box 
        if ( $possibility_counts->{"row" . $row . ":" . $possible_value } and 
             ( scalar @{ $possibility_counts->{"row" . $row . ":" . $possible_value } }
             > scalar @{ $possibility_counts->{$key} } ) ) {
          foreach my $cell ( grep { $_->box != $box } @{ $possibility_counts->{"row" . $row . ":" . $possible_value} } ) {
            $cell->possibilities->[$possible_value] = 0;
            $cell->possibilities->[0] = $cell->possibilities->[0] - 1;
            printf "Imaginary value of %d found in Box %d all in row %d...   removing it from the cell ( %d, %d, %d ).\n"
              , $possible_value
              , $box + 1
              , $row + 1
              , ( $cell->row + 1 )
              , ( $cell->column + 1 )
              , ( $cell->box + 1 );
            $progress++;
          }
        }
      }
      if ( ( scalar keys %{$cell_cols} ) == 1 ) {
        # all cells in this box representing this possible value live in the same column
        # if there are any cells in this column but outside of this box we can safely
        # remove this possible value from these "outside" cells
        my $col = ( keys %{$cell_cols} )[0];
        ( $box, $possible_value ) = ( $key =~ /box(\d):(\d)/);
        # do we have cells with this value outside this box 
        if (   $possibility_counts->{"col" . $col . ":" . $possible_value } and 
             ( scalar @{ $possibility_counts->{"col" . $col . ":" . $possible_value } }
             > scalar @{ $possibility_counts->{$key} } ) ) {
          foreach my $cell ( grep { $_->box != $box } @{ $possibility_counts->{"col" . $col . ":" . $possible_value} } ) {
            $cell->possibilities->[$possible_value] = 0;
            $cell->possibilities->[0] = $cell->possibilities->[0] - 1;
            printf "Imaginary value of %d found in Box %d all in col %d...   removing it from the cell ( %d, %d, %d ).\n"
              , $possible_value
              , $box + 1
              , $col + 1
              , ( $cell->row + 1 )
              , ( $cell->column + 1 )
              , ( $cell->box + 1 );
            $progress++;
          }
        }
      }
    }
  }

  $possibility_counts = $self->possibilities_hash;
  foreach my $key ( sort grep { $_ =~ /row/ } keys %{ $possibility_counts } ) {
    if ( scalar ( @{ $possibility_counts->{$key} } ) == 2 or scalar ( @{ $possibility_counts->{$key} } ) == 3 ) {
      # examine all cells in the possibility count and see if they are all in the row or same column
      my ( $cell_boxes, $row );
      foreach my $cell ( @{ $possibility_counts->{$key} } ) {
#       printf "IV-row: examining cell at ( %d, %d, %d ).\n"
#             , ( $cell->row + 1 )
#             , ( $cell->column + 1 )
#             , ( $cell->box + 1 );
        $cell_boxes->{$cell->box}++;
      }
      # we now have a count of the unique boxes
      # if either is a count of one, then all cells share the same row or column
      if ( ( scalar keys %{$cell_boxes} ) == 1 ) {
        # all cells in this box representing this possible value live in the same row
        # if there are any cells in this row but outside of this box we can safely
        # remove this possible value from these "outside" cells
        my $box = ( keys %{$cell_boxes} )[0];
        ( $row, $possible_value ) = ( $key =~ /row(\d):(\d)/);
        # do we have cells with this value outside this box 
        if (   $possibility_counts->{"box" . $box . ":" . $possible_value } and 
             ( scalar @{ $possibility_counts->{"box" . $box . ":" . $possible_value } }
             > scalar @{ $possibility_counts->{$key} } ) ) {
          foreach my $cell ( grep { $_->row != $row } @{ $possibility_counts->{"box" . $box . ":" . $possible_value} } ) {
            $cell->possibilities->[$possible_value] = 0;
            $cell->possibilities->[0] = $cell->possibilities->[0] - 1;
            printf "Imaginary value of %d found in Row %d...   removing it from the cell ( %d, %d, %d ).\n"
              , $possible_value
              , $row + 1
              , ( $cell->row + 1 )
              , ( $cell->column + 1 )
              , ( $cell->box + 1 );
            $progress++;
          }
        }
      }
    }
  }

  $possibility_counts = $self->possibilities_hash;
  foreach my $key ( sort grep { $_ =~ /col/ } keys %{ $possibility_counts } ) {
    if ( scalar ( @{ $possibility_counts->{$key} } ) == 2 or scalar ( @{ $possibility_counts->{$key} } ) == 3 ) {
      # examine all cells in the possibility count and see if they are all in the row or same column
      my ( $cell_boxes, $col );
      foreach my $cell ( @{ $possibility_counts->{$key} } ) {
#       printf "IV-col $key: examining cell at ( %d, %d, %d ).\n"
#             , ( $cell->row + 1 )
#             , ( $cell->column + 1 )
#             , ( $cell->box + 1 );
        $cell_boxes->{$cell->box}++;
      }
      # we now have a count of the unique boxes
      # if either is a count of one, then all cells share the same row or column
      if ( ( scalar keys %{$cell_boxes} ) == 1 ) {
        # all cells in this box representing this possible value live in the same row
        # if there are any cells in this row but outside of this box we can safely
        # remove this possible value from these "outside" cells
        my $box = ( keys %{$cell_boxes} )[0];
        ( $col, $possible_value ) = ( $key =~ /col(\d):(\d)/);
#       printf "IV-col $key: all cells were in Box %d, this col has %d cells with %d whereas this box %s, %d\n"
#              , $box + 1
#              , $possibility_counts->{$key} ? scalar @{ $possibility_counts->{$key} } : 0
#              , $possible_value
#              , "box" . $box . ":" . $possible_value
#              , $possibility_counts->{"box" . $box . ":" . $possible_value } ? scalar @{ $possibility_counts->{"box" . $box . ":" . $possible_value } } : 0;
        # do we have cells with this value outside this box 
        if (   $possibility_counts->{"box" . $box . ":" . $possible_value } and 
             ( scalar @{ $possibility_counts->{"box" . $box . ":" . $possible_value } }
             > scalar @{ $possibility_counts->{$key} } ) ) {
          foreach my $cell ( grep { $_->column != $col } @{ $possibility_counts->{"box" . $box . ":" . $possible_value} } ) {
            $cell->possibilities->[$possible_value] = 0;
            $cell->possibilities->[0] = $cell->possibilities->[0] - 1;
            printf "Imaginary value of %d found in Col %d...   removing it from the cell ( %d, %d, %d ).\n"
              , $possible_value
              , $col + 1
              , ( $cell->row + 1 )
              , ( $cell->column + 1 )
              , ( $cell->box + 1 );
            $progress++;
          }
        }
      }
    }
  }

  print "Found and removed $progress possible values from cells via imaginary numbers.\n\n";
  return $progress;
}

# This method was meant to be a helper to the find_remote_pairs method which is presently abandonded.
#  sub pairs_possible {
#    my $self = shift;
#    my $debug = 0;
#    my $pairs = {};
#    print "Begin search for pairs.\n" if ($debug);
#    foreach my $cell ( @{ $self->cells } ) {
#      if ( $cell->possibilities->[0] == 2 ) {
#        my $pair = "";
#        foreach my $value ( @{ $cell->possibilities }[1..9] ) {
#          $pair .= $value if $value;  
#        }
#        printf "Pair %d found in cell ( %d, %d, %d ).\n"
#               , $pair
#               , ( $cell->row + 1 )
#               , ( $cell->column + 1 )
#               , ( $cell->box + 1 ) if ($debug);
#        push ( @{ $pairs->{ $pair } }, $cell );
#      }
#    }
#    if ($debug) {
#      print "Pair search yeilds:\n";
#      foreach my $key ( keys %{ $pairs } ) {
#        printf "%s: %d\n", $key, scalar ( @{ $pairs->{$key} } );
#      }
#    }
#    return $pairs;
#  }

# Find all cells with only two possible candidate values
# return them in in a hash pairs
# eg. $pairs->{ "row:7 -> 57" } would be an array containing all cells with only 5 and 7 candidate values in row 7.
# This method is used only in the find_naked_pairs method, but will likely be useful in the find_remote_pairs method
# as well.
sub pairs_possible_by_cluster {
  my $self = shift;
  my $debug = 0;
  my $pairs = {};
  print "Begin search for naked pairs.\n" if ($debug);
  foreach my $cell ( @{ $self->cells } ) {
    if ( $cell->possibilities->[0] == 2 ) {
      my $pair = "";
      foreach my $value ( @{ $cell->possibilities }[1..9] ) {
        $pair .= $value if $value;  
      }
      printf "Naked pair %d found in cell ( %d, %d, %d ).\n"
             , $pair
             , ( $cell->row + 1 )
             , ( $cell->column + 1 )
             , ( $cell->box + 1 ) if ($debug);
      push ( @{ $pairs->{ "row:" . $cell->row    . " -> " . $pair } }, $cell );
      push ( @{ $pairs->{ "col:" . $cell->column . " -> " . $pair } }, $cell );
      push ( @{ $pairs->{ "box:" . $cell->box    . " -> " . $pair } }, $cell );
    }
  }
  if ($debug) {
    print "Naked pair search yeilds:\n";
    foreach my $key ( keys %{ $pairs } ) {
      printf "%s: %d\n", $key, scalar ( @{ $pairs->{$key} } );
    }
  }
  return $pairs;
}

sub possibilities_hash {
  my $self = shift;
  my $possibility_counts = {};
  my $possible_value;
  my $cluster = 0;
  my $string = '';
  foreach my $row ( @{ $self->rows } ) {
    foreach my $cell ( @{ $row } ) {
      if ( not $cell->value ) { # look for unsolved cells in this cluster
        foreach $possible_value ( grep { $_ } @{ $cell->possibilities }[1..9] ) {  # a pointer to the cell is pushed onto the array all of the cell's possible values
          #                               "row0:7"
          push ( @{ $possibility_counts->{"row$cluster:" .$possible_value} } , $cell );
        }
      }
    }
    $cluster++;
  }
  $cluster = 0;
  foreach my $column ( @{ $self->columns } ) {
    foreach my $cell ( @{ $column } ) {
      if ( not $cell->value ) { # look for unsolved cells in this cluster
        foreach $possible_value ( grep { $_ } @{ $cell->possibilities }[1..9] ) {  # a pointer to the cell is pushed onto the array all of the cell's possible values
          push ( @{ $possibility_counts->{"col$cluster:" .$possible_value} } , $cell );
        }
      }
    }
    $cluster++;
  }
  $cluster = 0;
  foreach my $box ( @{ $self->boxes } ) {
    foreach my $cell ( @{ $box } ) {
      if ( not $cell->value ) { # look for unsolved cells in this cluster
        foreach $possible_value ( grep { $_ } @{ $cell->possibilities }[1..9] ) {  # a pointer to the cell is pushed onto the array all of the cell's possible values
          push ( @{ $possibility_counts->{"box$cluster:" .$possible_value} } , $cell );
        }
      }
    }
    $cluster++;
  }
  return $possibility_counts;
}

sub remove_my_solution_from_my_mates  {
  my($self,$cell) = @_;
  my($value) = $cell->value;
  foreach ( @{ $self->row_mates_of($cell) } ) {
    $_->remove_possibility($value);
  }
  foreach ( @{ $self->column_mates_of($cell) } ) {
    $_->remove_possibility($value);
  }
  foreach ( @{ $self->box_mates_of($cell) } ) {
    $_->remove_possibility($value);
  }
}

sub row_mates_of {  # return an array ref to an array containing all the other cells on my row that aren't me 
  my($self,$cell) = @_;
  my $row = $cell->row;
  my $a = [ grep { $_->column != $cell->column } @{$self->rows->[$row]} ];
# print "row: " . ( $row + 1 ) . "; number of cells: " . scalar @$a . "\n";
  $a;
}

sub column_mates_of {  # return an array ref to an array containing all the other cells on my column that aren't me 
  my($self,$cell) = @_;
  my $column = $cell->column;
  my $a = [ grep { $_->row != $cell->row } @{$self->columns->[$column]} ];
# print "column " . ( $column + 1 ) . "; number of cells: " . scalar @$a . "\n";
  $a;
}

sub box_mates_of {  # return an array ref to an array containing all the other cells on my box that aren't me 
  my($self,$cell) = @_;
  my $box = $cell->box;
# print "my box has " . scalar @{$self->boxes->[$box]} . " cells in it.\n";
  my $a = [ grep { $_->column != $cell->column or $_->row != $cell->row } @{$self->boxes->[$box]} ];
# print "box " . ( $box + 1 ) . "; number of cells: " . scalar @$a . "\n";
  $a;
}

sub intersections {
  my( $self, $cell_1, $cell_2 ) = @_;
  my $intersections = [];
  if ( $cell_1 == $cell_2 ) {                            # SAME ROW, SAME COLUMN, SAME BOX 1,1,1
    # 1 1 1 ( Same cell is NOT ALLOWED!)
    print "Cell::intersections called with self as the 'other cell'... cut it out!\n";
    exit 1;
  } else {                                               # DIFF SOMETHING                  X,Y,Z  one+ is 0
    if ( $cell_1->row == $cell_2->row ) {                # SAME ROW, DIFF COLUMN           
      if ( $cell_1->box == $cell_2->box ) {              # SAME ROW, DIFF COLUMN, SAME BOX 1,0,1
        # members of the shared box and shared row
        push ( @$intersections, grep { $_->column != $cell_2->column }                             @{ $self->row_mates_of($cell_1) } );
        push ( @$intersections, grep { $_->row != $cell_2->row and $_->column != $cell_2->column } @{ $self->box_mates_of($cell_1) } );
      } else {                                           # SAME ROW, DIFF COLUMN, DIFF BOX 1,0,0
        # just members of the shared row
        push ( @$intersections, grep { $_->column != $cell_2->column } @{ $self->row_mates_of($cell_1) } );
      }
    } else {                                             # DIFF ROW
      if ( $cell_1->column == $cell_2->column ) {        # DIFF ROW, SAME COLUMN
        if ( $cell_1->box == $cell_2->box ) {            # DIFF ROW, SAME COLUMN, SAME BOX 0,1,1
          # members of the shared box and shared column
          push ( @$intersections, grep { $_->row != $cell_2->row } @{ $self->column_mates_of($cell_1) } );
          push ( @$intersections, grep { $_->row != $cell_2->row and $_->column != $cell_2->column } @{ $self->box_mates_of($cell_1) } );
        } else {                                         # DIFF ROW, SAME COLUMN, DIFF BOX 0,1,0
          # just members of the shared column
          push ( @$intersections, grep { $_->row != $cell_2->row } @{ $self->column_mates_of($cell_1) } );
        }
      } else {                                           # DIFF ROW, DIFF COLUMN
        if ( $cell_1->box == $cell_2->box ) {            # DIFF ROW, DIFF COLUMN, SAME BOX 0,0,1
          # just members of the shared box
          push ( @$intersections, grep { $_->row != $cell_2->row and $_->column != $cell_2->column } @{ $self->box_mates_of($cell_1) } );
        } else {                                         # DIFF ROW, DIFF COLUMN, DIFF BOX 0,0,0
          # just two intersecting cells
          # (row1, col2) and (row2, col1)
          push ( @$intersections, $self->cell_from_row_column( $cell_1->row, $cell_2->column) );
          push ( @$intersections, $self->cell_from_row_column( $cell_2->row, $cell_1->column) );
        }
      }
    }
  }
  return $intersections;
}

sub unsolved_cells {
  my($self) = shift;
  my $unsolved = [ ];
  push ( @{$unsolved}, grep { not $_->value } @{$self->cells} ) ;
# print "Found " . scalar @{$unsolved} . " unsolved cells.\n";
  return $unsolved;
}

sub solved_cells {
  my($self) = shift;
  my $solved = [ ];
  push ( @{$solved}, grep { $_->value } @{$self->cells} ) ;
# print "Found " . scalar @{$solved} . " solved cells.\n";
  return $solved;
}

# Print status of all the cells
sub status {
  my $self = shift;
  print "Showing status of all cells:\n";
  foreach my $cell ( @{$self->cells} ) {
    printf "( %d, %d, %d ) ", ( 1 + $cell->row ), ( 1 + $cell->column ), ( 1 + $cell->box );
    if ( $cell->value ) {
      if ( $cell->given ) {
        print "Given:    " . $cell->value . "\n";
      } else {
        print "Solved:   " . $cell->value . "\n";
      }
    } else {
      printf "%d left -> " , $cell->possibilities->[0];
      printf "%-27s\n", join( ', ', ( grep { $_ != 0 } @{ $cell->possibilities }[1..9] ) );
    }
  }
}

# Print status of all the cells in a 3 column outputs
sub multi_column_status {
  my $self = shift;
  print "Showing status of all cells:\n";
  my $lines = [];
  my $line = 0;
  foreach my $cell ( @{$self->cells} ) {
    my $entry = '';
    $entry .= sprintf "( %d, %d, %d ) ", ( 1 + $cell->row ), ( 1 + $cell->column ), ( 1 + $cell->box ); # 12 characters
    if ( $cell->value ) {
      if ( $cell->given ) {
        $entry .= sprintf "Given:    %-27s", $cell->value; # 38 characters
      } else {
        $entry .= sprintf "Solved:   %-27s", $cell->value; # 38 characters
      }
    } else {
      $entry .= sprintf "%d left -> " , $cell->possibilities->[0]; # 10 characters
      $entry .= sprintf "%-27s", join( ', ', ( grep { $_ != 0 } @{ $cell->possibilities }[1..9] ) ); # 27 characters
    }
    # each column will be 12+10+27 = 50 characters wide
    $lines->[($line++)%27] .= " $entry";
  }
  print "$_\n" foreach @$lines;
}

# Simplest printout
sub out {
  my($self) = shift;
  for ( my($r) = 0; $r <= 8; $r++ ) {
    my $off = $r * 9;
    print "   ";
    printf "%3d", $self->cells->[ $off + $_ ]->value for ( 0 .. 8 ); 
    print "\n";
  }
}

# Prettier printout
sub pretty_print {
  my($self) = shift;
  my($format);
  $format .= "     1   2   3   4   5   6   7   8   9  \n";
  $format .= "   +---+---+---+---+---+---+---+---+---+\n";
  $format .= " 1 | %s ' %s ' %s | %s ' %s ' %s | %s ' %s ' %s |\n";
  $format .= "   + - + - + - + - + - + - + - + - + - +\n";
  $format .= " 2 | %s ' %s ' %s | %s ' %s ' %s | %s ' %s ' %s |\n";
  $format .= "   + - + - + - + - + - + - + - + - + - +\n";
  $format .= " 3 | %s ' %s ' %s | %s ' %s ' %s | %s ' %s ' %s |\n";
  $format .= "   +---+---+---+---+---+---+---+---+---+\n";
  $format .= " 4 | %s ' %s ' %s | %s ' %s ' %s | %s ' %s ' %s |\n";
  $format .= "   + - + - + - + - + - + - + - + - + - +\n";
  $format .= " 5 | %s ' %s ' %s | %s ' %s ' %s | %s ' %s ' %s |\n";
  $format .= "   + - + - + - + - + - + - + - + - + - +\n";
  $format .= " 6 | %s ' %s ' %s | %s ' %s ' %s | %s ' %s ' %s |\n";
  $format .= "   +---+---+---+---+---+---+---+---+---+\n";
  $format .= " 7 | %s ' %s ' %s | %s ' %s ' %s | %s ' %s ' %s |\n";
  $format .= "   + - + - + - + - + - + - + - + - + - +\n";
  $format .= " 8 | %s ' %s ' %s | %s ' %s ' %s | %s ' %s ' %s |\n";
  $format .= "   + - + - + - + - + - + - + - + - + - +\n";
  $format .= " 9 | %s ' %s ' %s | %s ' %s ' %s | %s ' %s ' %s |\n";
    $format .= "   +---+---+---+---+---+---+---+---+---+\n";
 
  printf $format, ( map { $_->value == 0 ?  ' ' : $_->value } @{$self->cells} ) ;
}

# Best and most complete printout
sub big_print  {
  my($self) = shift;
  my $grid = [];
  #        ( ( $col + 1 ) * 8 ) 
  #                        1         2         3         4         5         6         7        
  #              0123456789012345678901234567890123456789012345678901234567890123456789012345678
  $grid->[ 0] = "                                                                               "; #  0   center of cell is ( $row * 4 )
  $grid->[ 1] = "        1       2       3       4       5       6       7       8       9      "; #  1  
  $grid->[ 2] = "    +-------+-------+-------+-------+-------+-------+-------+-------+-------+  "; #  2      __________ row ______________ 
  $grid->[ 3] = "    |       '       '       |       '       '       |       '       '       |  "; #  3      int ( ( $val - 1 ) / 3 )  - 1 
  $grid->[ 4] = "  1 |       '       '       |       '       '       |       '       '       |  "; #  4   1:         0                  -1 
  $grid->[ 5] = "    |       '       '       |       '       '       |       '       '       |  "; #  5   2:         0                  -1 
  $grid->[ 6] = "    + ----- + ----- + ----- + ----- + ----- + ----- + ----- + ----- + ----- +  "; #  6   3:         0                  -1 
  $grid->[ 7] = "    |       '       '       |       '       '       |       '       '       |  "; #  7   4:         1                   0 
  $grid->[ 8] = "  2 |       '       '       |       '       '       |       '       '       |  "; #  8   5:         1                   0 
  $grid->[ 9] = "    |       '       '       |       '       '       |       '       '       |  "; #  9   6:         1                   0 
  $grid->[10] = "    + ----- + ----- + ----- + ----- + ----- + ----- + ----- + ----- + ----- +  "; # 10   7:         2                   1 
  $grid->[11] = "    |       '       '       |       '       '       |       '       '       |  "; # 11   8:         2                   1 
  $grid->[12] = "  3 |       '       '       |       '       '       |       '       '       |  "; # 12   9:         2                   1 
  $grid->[13] = "    |       '       '       |       '       '       |       '       '       |  "; # 13 
  $grid->[14] = "    +-------+-------+-------+-------+-------+-------+-------+-------+-------+  "; # 14   _____________ col ______________
  $grid->[15] = "    |       '       '       |       '       '       |       '       '       |  "; # 15   ( ( ( $val - 1 ) % 3 ) - 1 ) * 2
  $grid->[16] = "  4 |       '       '       |       '       '       |       '       '       |  "; # 16   1:     0                -1    -2
  $grid->[17] = "    |       '       '       |       '       '       |       '       '       |  "; # 17   2:     1                 0     0
  $grid->[18] = "    + ----- + ----- + ----- + ----- + ----- + ----- + ----- + ----- + ----- +  "; # 18   3:     2                 1     2
  $grid->[19] = "    |       '       '       |       '       '       |       '       '       |  "; # 19   4:     0                -1    -2
  $grid->[20] = "  5 |       '       '       |       '       '       |       '       '       |  "; # 20   5:     1                 0     0
  $grid->[21] = "    |       '       '       |       '       '       |       '       '       |  "; # 21   6:     2                 1     2
  $grid->[22] = "    + ----- + ----- + ----- + ----- + ----- + ----- + ----- + ----- + ----- +  "; # 22   7:     0                -1    -2
  $grid->[23] = "    |       '       '       |       '       '       |       '       '       |  "; # 23   8:     1                 0     0
  $grid->[24] = "  6 |       '       '       |       '       '       |       '       '       |  "; # 24   9:     2                 1     2
  $grid->[25] = "    |       '       '       |       '       '       |       '       '       |  "; # 25 
  $grid->[26] = "    +-------+-------+-------+-------+-------+-------+-------+-------+-------+  "; # 26 
  $grid->[27] = "    |       '       '       |       '       '       |       '       '       |  "; # 27 
  $grid->[28] = "  7 |       '       '       |       '       '       |       '       '       |  "; # 28 
  $grid->[29] = "    |       '       '       |       '       '       |       '       '       |  "; # 29 
  $grid->[30] = "    + ----- + ----- + ----- + ----- + ----- + ----- + ----- + ----- + ----- +  "; # 30 
  $grid->[31] = "    |       '       '       |       '       '       |       '       '       |  "; # 31 
  $grid->[32] = "  8 |       '       '       |       '       '       |       '       '       |  "; # 32 
  $grid->[33] = "    |       '       '       |       '       '       |       '       '       |  "; # 33 
  $grid->[34] = "    + ----- + ----- + ----- + ----- + ----- + ----- + ----- + ----- + ----- +  "; # 34 
  $grid->[35] = "    |       '       '       |       '       '       |       '       '       |  "; # 35 
  $grid->[36] = "  9 |       '       '       |       '       '       |       '       '       |  "; # 36 
  $grid->[37] = "    |       '       '       |       '       '       |       '       '       |  "; # 37 
  $grid->[38] = "    +-------+-------+-------+-------+-------+-------+-------+-------+-------+  "; # 38 
 
   foreach my $cell ( @{ $self->solved_cells } ) {
    substr( $grid->[ ( $cell->row + 1 ) * 4 ],
            ( ( $cell->column + 1 ) * 8 ),
            1, $cell->value);
  }
  
  foreach my $cell ( @{ $self->unsolved_cells } ) {
    foreach my $value ( grep { $_ } ( @{$cell->possibilities}[1..9] ) ) {
      substr( $grid->[ ( ( $cell->row + 1 ) * 4 )   +   int ( ( $value - 1 ) / 3 ) - 1 ],
              ( ( $cell->column + 1 ) * 8 ) + ( ( ( $value - 1 ) % 3 ) - 1 ) * 2,
              1, $value);
      }
  }

  print "$_\n" foreach ( @{ $grid } );
}

1;
__END__

  $format .= "     1   2   3   4   5   6   7   8   9  \n";
  $format .= "   +===+===+===+===+===+===+===+===+===+\n";
  $format .= " 1 I %s | %s | %s I %s | %s | %s I %s | %s | %s I\n";
  $format .= "   + - + - + - + - + - + - + - + - + - +\n";
  $format .= " 2 I %s | %s | %s I %s | %s | %s I %s | %s | %s I\n";
  $format .= "   + - + - + - + - + - + - + - + - + - +\n";
  $format .= " 3 I %s | %s | %s I %s | %s | %s I %s | %s | %s I\n";
  $format .= "   +===+===+===+===+===+===+===+===+===+\n";
  $format .= " 4 I %s | %s | %s I %s | %s | %s I %s | %s | %s I\n";
  $format .= "   + - + - + - + - + - + - + - + - + - +\n";
  $format .= " 5 I %s | %s | %s I %s | %s | %s I %s | %s | %s I\n";
  $format .= "   + - + - + - + - + - + - + - + - + - +\n";
  $format .= " 6 I %s | %s | %s I %s | %s | %s I %s | %s | %s I\n";
  $format .= "   +===+===+===+===+===+===+===+===+===+\n";
  $format .= " 7 I %s | %s | %s I %s | %s | %s I %s | %s | %s I\n";
  $format .= "   + - + - + - + - + - + - + - + - + - +\n";
  $format .= " 8 I %s | %s | %s I %s | %s | %s I %s | %s | %s I\n";
  $format .= "   + - + - + - + - + - + - + - + - + - +\n";
  $format .= " 9 I %s | %s | %s I %s | %s | %s I %s | %s | %s I\n";
  $format .= "   +===+===+===+===+===+===+===+===+===+\n";

       1   2   3   4   5   6   7   8   9  
     +===+===+===+===+===+===+===+===+===+
   1 I   |   |   I   |   |   I   |   |   I
     + - + - + - + - + - + - + - + - + - +
   2 I   | 1 |   I   | 2 |   I   | 3 |   I
     + - + - + - + - + - + - + - + - + - +
   3 I   |   |   I   |   |   I   |   |   I
     +===+===+===+===+===+===+===+===+===+
   4 I   |   |   I   |   |   I   |   |   I
     + - + - + - + - + - + - + - + - + - +
   5 I   | 4 |   I   | 5 |   I   | 6 |   I
     + - + - + - + - + - + - + - + - + - +
   6 I   |   |   I   |   |   I   |   |   I
     +===+===+===+===+===+===+===+===+===+
   7 I   |   |   I   |   |   I   |   |   I
     + - + - + - + - + - + - + - + - + - +
   8 I   | 7 |   I   | 8 |   I   | 9 |   I
     + - + - + - + - + - + - + - + - + - +
   9 I   |   |   I   |   |   I   |   |   I
     +===+===+===+===+===+===+===+===+===+



  Difficulty         number range of given numbers, other attributes as of yet unknown or unidentified
        0 - easy
        1 - medium
        2 - hard
        3 - crazy
        4 - diabolical

   Puzzle
     Notes           -> string describing origin of the puzzle
     Difficulty      -> 0 - easy, 1 - medium, 2 - hard, 3 - crazy, 4 - diabolical
     Rows            -> array 1 .. 9, pointers to each member row
     Columns         -> array 1 .. 9, pointers to each member columns
     Boxs            -> array 1 .. 9, pointers to each member box

   Row
     Members         -> array 1 .. 9, with pointers to cells in this Row

   Column
     Members         -> array 1 .. 9, with pointers to cells in this Column

   Box
     Members         -> array 1 .. 9, with pointers to cells in this Box

   Cell
     Given           -> boolean, true if given value was 'given' in original puzzle
     Value           -> single digit 1 - 9
     Possible values -> array 1 .. 9, with numbers for those that are possible and zeros for those that are not.
                        example, [ 1, 0, 0, 4, 0, 0, 0, 0, 0, 9 ] would be a cell who's possible remaining values would be 1, 4 and 9
     Box             -> number from 1 - 9, to which box    does this cell belong    
     Row             -> number from 1 - 9, to which row    does this cell belong    
     Column          -> number from 1 - 9, to which column does this cell belong    


     substr EXPR,OFFSET,LENGTH,REPLACEMENT
     substr EXPR,OFFSET,LENGTH
     substr EXPR,OFFSET

First character is at offset 0

OFFSET is negative   == that far from the end of the string.
no LENGTH            == everything to the end of the string.
LENGTH is negative   == leaves that many characters off the end of the string.

To keep the string the same length you may need to pad
or chop your value using "sprintf".


OFFSET and LENGTH partly outside, only part returned.
OFFSET and LENGTH completely outside, UNDEF returned.

Here's an example showing the behavior for boundary cases:

  my $name = 'fred';
  substr($name, 4) = 'dy';       # $name is now 'freddy'
  my $null = substr $name, 6, 2; # returns '' (no warning)
  my $oops = substr $name, 7;    # returns undef, with warning
  substr($name, 7) = 'gap';      # fatal error

  my $str="abd123hij";		     # 2 ways to replace 123 with efg
  substr($str, 2, 3, 'efg');	 # assign 4th arg.
  substr($str, 2, 3)='efg';	     # substr as an lvalue

