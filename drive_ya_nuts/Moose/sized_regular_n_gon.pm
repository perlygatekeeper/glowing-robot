# now we give it a size
package sized_regular_n_gon;
use Math::Trig;
use Moose;

extends 'regular_n_gon';

has 'super_radius' => (
  isa => 'Num', is => 'rw',
  clearer => '_clear_super_radius', predicate => '_has_super_radius',
  lazy => 1, builder => '_build_super_radius',
  # trigger => sub { $_[0]->_clear_sub_radius; $_[0]->_clear_side_length },
);

sub _build_super_radius {
  my ($self) = @_;
  if ($self->_has_sub_radius) {
    return $self->sub_radius       / sin( $self->internal_angle/2.0 );
  } elsif ($self->_has_side_length) {
    return $self->side_length/2.0  / cos( $self->internal_angle/2.0 );
  } else {
    die "Trying to infer super_radius but neither sub_radius nor side_length is set";
  }
}

has 'sub_radius' => (
  isa => 'Num', is => 'rw',
  clearer => '_clear_sub_radius', predicate => '_has_sub_radius',
  lazy => 1, builder => '_build_sub_radius',
  # trigger => sub { $_[0]->_clear_sub_radius; $_[0]->_clear_side_length },
);

sub _build_sub_radius {
  my ($self) = @_;
  if ($self->_has_super_radius) {
    return $self->super_radius     * sin( $self->internal_angle/2.0 );
  } elsif ($self->_has_side_length) {
    return $self->side_length/2.0  * tan( $self->internal_angle/2.0 );
  } else {
    die "Trying to infer sub_radius but neither super_radius nor side_length is set";
  }
}

has 'side_length' => (
  isa => 'Num', is => 'rw',
  clearer => '_clear_side_length', predicate => '_has_side_length',
  lazy => 1, builder => '_build_side_length',
  # trigger => sub { $_[0]->_clear_side_length; $_[0]->_clear_side_length },
);

sub _build_side_length {
  my ($self) = @_;
  if ($self->_has_super_radius) {
    return 2.0 * $self->super_radius * cos( $self->internal_angle/2.0 );
  } elsif ($self->_has_sub_radius) {
    print $self->internal_angle/2.0 . "\n";
    print tan($self->internal_angle/2.0) . "\n";
    return 2.0 * $self->sub_radius   / tan( $self->internal_angle/2.0 );
  } else {
    die "Trying to infer side_length but neither super_radius nor sub_radius is set";
  }
}

has 'perimeter' => (
  isa => 'Num', is => 'rw',
  clearer => '_clear_perimeter', predicate => '_has_perimeter',
  lazy => 1, builder => '_build_perimeter',
);

sub _build_perimeter {
    my $self = shift;
	return $self->sides() * $self->side_length();
}

has 'area' => (
  isa => 'Num', is => 'rw',
  clearer => '_clear_area', predicate => '_has_area',
  lazy => 1, builder => '_build_area',
);

sub _build_area {
    my $self = shift;
	# number_of_triangles * ( 1/2 * Base * Height)
	return $self->sides * $self->side_length/2.0 * $self->sub_radius;
}


1;

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

    .
    |\
    | \
   S|  \
   u|   \   _Super
   b|    \ /
    |     \
    |      \
    |      a\        a = internal_angle / 2
    |________\
	  hSide          hSide = Side / 2


  hSide = cos(a)    hSide = cos(a) * Super    Super = hSide/cos(a)
  Super

  _Sub_ = sin(a)      Sub = sin(a) * Super    Super = Sub/sin(a)
  Super

  _Sub_ = tan(a)      Sub = tan(a) * hSide    hSide = Sub/tan(a)
  hSide


    return $self->sub_radius       / sin( $self->internal_angle/2.0 );
