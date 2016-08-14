package regular_n_gon;
use Moose;
use Carp;
use Math::Trig ':pi';

# print pi2 . "\n";
 
has 'sides'          => ( isa => 'Int', is => 'ro', required => 1, );
has 'internal_angle' => ( isa => 'Num', is => 'ro', required => 0, lazy =>1, builder=>'_find_internal_angle' );
 
sub _find_internal_angle {
    my $self = shift;
	return 0 if ( not $self->sides );
	return pi - pi2/$self->sides;
}

sub in_degrees {
    my $self  = shift;
    my $angle = shift;
	return $angle*180/pi;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
