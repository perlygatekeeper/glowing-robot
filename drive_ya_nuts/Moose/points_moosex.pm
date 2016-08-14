package Point;
 
# This is the same using the MooseX::Declare extension:
use Carp;
use MooseX::Declare;
 
class Point {
    has 'x' => (isa => 'Num', is => 'rw');
    has 'y' => (isa => 'Num', is => 'rw');
 
    method clear {
        $self->x(0);
        $self->y(0);
    }
    method set_to (Num $x, Num $y) {
        $self->x($x);
        $self->y($y);
    }
}
 
class Point3D extends Point {
    has 'z' => (isa => 'Num', is => 'rw');
 
    after clear {
        $self->z(0);
    }
    method set_to (Num $x, Num $y, Num $z) {
        $self->x($x);
        $self->y($y);
        $self->z($z);
    }
}
