# There is a new set_to() method in the Point3D class so the method of the same name defined in the Point class
# is not invoked in the case of Point3D instances. The clear() method on the other hand is not replaced but extended in the subclass,
# so both methods are run in the correct order.
 
package Point3D;
use Moose;
use Carp;
 
extends 'Point';
 
has 'z' => (isa => 'Num', is => 'rw');
 
after 'clear' => sub {
    my $self = shift;
    $self->z(0);
};
 
sub set_to {
    @_ == 4 or croak "Bad number of arguments";
    my $self = shift;
    my ($x, $y, $z) = @_;
    $self->x($x);
    $self->y($y);
    $self->z($z);
}
