package RPN::Commands::Transform;

use v5.34;
use strict;
use warnings;

use RPN::Transform;
use RPN::Vector;

sub register_commands {
    my ($commands) = @_;

    $commands->register(
        identity2d => {
            category => 'geometry',
            help => 'push the 2D identity transform',
            code => sub {
                my ($calc) = @_;
                $calc->stack->push(RPN::Transform->identity(2));
            },
        },
    );

    $commands->register(
        translate2d => {
            category => 'geometry',
            help => 'create a 2D translation: DX DY translate2d',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2, 'translate2d');
                my ($dy, $dx) = $calc->stack->pop2;
                return _push_factory_result(
                    $calc,
                    [$dx, $dy],
                    sub { RPN::Transform->translation2d($dx, $dy) },
                );
            },
        },
    );

    $commands->register(
        rotate2d => {
            category => 'geometry',
            help => 'create a 2D rotation using the current angle mode: ANGLE rotate2d',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1, 'rotate2d');
                my $angle = $calc->stack->pop;
                return _push_factory_result(
                    $calc,
                    [$angle],
                    sub {
                        RPN::Transform->rotation2d(
                            $calc->angle_to_radians($angle)
                        );
                    },
                );
            },
        },
    );

    $commands->register(
        scale2d => {
            category => 'geometry',
            help => 'create a 2D scale transform: SX SY scale2d',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2, 'scale2d');
                my ($sy, $sx) = $calc->stack->pop2;
                return _push_factory_result(
                    $calc,
                    [$sx, $sy],
                    sub { RPN::Transform->scaling2d($sx, $sy) },
                );
            },
        },
    );

    $commands->register(
        shear2d => {
            category => 'geometry',
            help => 'create a 2D shear: X-BY-Y Y-BY-X shear2d',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2, 'shear2d');
                my ($y_by_x, $x_by_y) = $calc->stack->pop2;
                return _push_factory_result(
                    $calc,
                    [$x_by_y, $y_by_x],
                    sub { RPN::Transform->shearing2d($x_by_y, $y_by_x) },
                );
            },
        },
    );

    $commands->register(
        reflectx2d => {
            category => 'geometry',
            help => 'push a 2D reflection across the x-axis',
            code => sub {
                my ($calc) = @_;
                $calc->stack->push(RPN::Transform->reflection_x2d);
            },
        },
    );

    $commands->register(
        reflecty2d => {
            category => 'geometry',
            help => 'push a 2D reflection across the y-axis',
            code => sub {
                my ($calc) = @_;
                $calc->stack->push(RPN::Transform->reflection_y2d);
            },
        },
    );

    $commands->register(
        compose2d => {
            category => 'geometry',
            help => 'compose transforms in execution order: FIRST SECOND compose2d',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2, 'compose2d');
                my $second = $calc->stack->pop;
                my $first  = $calc->stack->pop;

                unless (_is_2d($first) && _is_2d($second)) {
                    $calc->stack->push($first);
                    $calc->stack->push($second);
                    warn "compose2d requires two 2D transforms\n";
                    return;
                }

                $calc->stack->push($first->then($second));
            },
        },
    );

    $commands->register(
        inverse2d => {
            category => 'geometry',
            help => 'invert a non-singular 2D transform',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1, 'inverse2d');
                my $transform = $calc->stack->pop;

                unless (_is_2d($transform)) {
                    $calc->stack->push($transform);
                    warn "inverse2d requires a 2D transform\n";
                    return;
                }

                my $inverse = eval { $transform->inverse };
                if ($@) {
                    $calc->stack->push($transform);
                    warn $@;
                    return;
                }

                $calc->stack->push($inverse);
            },
        },
    );

    $commands->register(
        point2d => {
            category => 'geometry',
            help => 'create a 2D point: X Y point2d',
            code => sub {
                my ($calc) = @_;
                _make_point($calc, 2, 'point2d');
            },
        },
    );

    $commands->register(
        distance2d => {
            category => 'geometry',
            help => 'distance between two 2D points',
            code => sub {
                my ($calc) = @_;
                _distance($calc, 2, 'distance2d');
            },
        },
    );

    $commands->register(
        apply2d => {
            category => 'geometry',
            help => 'apply a transform to a point: POINT TRANSFORM apply2d',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2, 'apply2d');
                my $transform = $calc->stack->pop;
                my $point     = $calc->stack->pop;

                unless (RPN::Vector::is_vector($point) && $point->dim == 2
                    && _is_2d($transform)) {
                    $calc->stack->push($point);
                    $calc->stack->push($transform);
                    warn "apply2d requires a 2D point and 2D transform\n";
                    return;
                }

                $calc->stack->push($transform->apply($point));
            },
        },
    );

    $commands->register(
        identity3d => {
            category => 'geometry',
            help => 'push the 3D identity transform',
            code => sub {
                my ($calc) = @_;
                $calc->stack->push(RPN::Transform->identity(3));
            },
        },
    );

    $commands->register(
        translate3d => {
            category => 'geometry',
            help => 'create a 3D translation: DX DY DZ translate3d',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(3, 'translate3d');
                my $dz = $calc->stack->pop;
                my $dy = $calc->stack->pop;
                my $dx = $calc->stack->pop;
                return _push_factory_result(
                    $calc,
                    [$dx, $dy, $dz],
                    sub { RPN::Transform->translation3d($dx, $dy, $dz) },
                );
            },
        },
    );

    for my $axis (qw(x y z)) {
        my $name = "rotate${axis}3d";
        my $method = "rotation_${axis}3d";
        $commands->register(
            $name => {
                category => 'geometry',
                help => "create a 3D rotation about the $axis-axis using the current angle mode",
                code => sub {
                    my ($calc) = @_;
                    return unless $calc->stack->require_depth(1, $name);
                    my $angle = $calc->stack->pop;
                    return _push_factory_result(
                        $calc,
                        [$angle],
                        sub {
                            RPN::Transform->$method(
                                $calc->angle_to_radians($angle)
                            );
                        },
                    );
                },
            },
        );
    }

    $commands->register(
        scale3d => {
            category => 'geometry',
            help => 'create a 3D scale transform: SX SY SZ scale3d',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(3, 'scale3d');
                my $sz = $calc->stack->pop;
                my $sy = $calc->stack->pop;
                my $sx = $calc->stack->pop;
                return _push_factory_result(
                    $calc,
                    [$sx, $sy, $sz],
                    sub { RPN::Transform->scaling3d($sx, $sy, $sz) },
                );
            },
        },
    );

    for my $plane (qw(xy xz yz)) {
        my $name = "reflect${plane}3d";
        my $method = "reflection_${plane}3d";
        $commands->register(
            $name => {
                category => 'geometry',
                help => "push a 3D reflection across the $plane-plane",
                code => sub {
                    my ($calc) = @_;
                    $calc->stack->push(RPN::Transform->$method());
                },
            },
        );
    }

    $commands->register(
        compose3d => {
            category => 'geometry',
            help => 'compose transforms in execution order: FIRST SECOND compose3d',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2, 'compose3d');
                my $second = $calc->stack->pop;
                my $first  = $calc->stack->pop;

                unless (_is_3d($first) && _is_3d($second)) {
                    $calc->stack->push($first);
                    $calc->stack->push($second);
                    warn "compose3d requires two 3D transforms\n";
                    return;
                }

                $calc->stack->push($first->then($second));
            },
        },
    );

    $commands->register(
        inverse3d => {
            category => 'geometry',
            help => 'invert a non-singular 3D transform',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1, 'inverse3d');
                my $transform = $calc->stack->pop;

                unless (_is_3d($transform)) {
                    $calc->stack->push($transform);
                    warn "inverse3d requires a 3D transform\n";
                    return;
                }

                my $inverse = eval { $transform->inverse };
                if ($@) {
                    $calc->stack->push($transform);
                    warn $@;
                    return;
                }

                $calc->stack->push($inverse);
            },
        },
    );

    $commands->register(
        point3d => {
            category => 'geometry',
            help => 'create a 3D point: X Y Z point3d',
            code => sub {
                my ($calc) = @_;
                _make_point($calc, 3, 'point3d');
            },
        },
    );

    $commands->register(
        distance3d => {
            category => 'geometry',
            help => 'distance between two 3D points',
            code => sub {
                my ($calc) = @_;
                _distance($calc, 3, 'distance3d');
            },
        },
    );

    $commands->register(
        apply3d => {
            category => 'geometry',
            help => 'apply a transform to a point: POINT TRANSFORM apply3d',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(2, 'apply3d');
                my $transform = $calc->stack->pop;
                my $point     = $calc->stack->pop;

                unless (RPN::Vector::is_vector($point) && $point->dim == 3
                    && _is_3d($transform)) {
                    $calc->stack->push($point);
                    $calc->stack->push($transform);
                    warn "apply3d requires a 3D point and 3D transform\n";
                    return;
                }

                $calc->stack->push($transform->apply($point));
            },
        },
    );

    $commands->register(
        transformmatrix => {
            category => 'geometry',
            help => 'replace a transform with a copy of its homogeneous matrix',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(1, 'transformmatrix');
                my $transform = $calc->stack->pop;

                unless (RPN::Transform::is_transform($transform)) {
                    $calc->stack->push($transform);
                    warn "transformmatrix requires a transform\n";
                    return;
                }

                $calc->stack->push($transform->matrix);
            },
        },
    );

    return;
}

sub _is_2d {
    my ($value) = @_;
    return RPN::Transform::is_transform($value) && $value->dimension == 2;
}

sub _is_3d {
    my ($value) = @_;
    return RPN::Transform::is_transform($value) && $value->dimension == 3;
}

sub _make_point {
    my ($calc, $dimension, $name) = @_;
    return unless $calc->stack->require_depth($dimension, $name);

    my @values = map { $calc->stack->pop } 1 .. $dimension;
    @values = reverse @values;

    for my $value (@values) {
        unless (defined($value) && !ref($value) && $calc->isanumber($value)) {
            $calc->stack->push($_) for @values;
            warn "$name requires $dimension numeric coordinates\n";
            return;
        }
    }

    $calc->stack->push(RPN::Vector->new(@values));
    return;
}

sub _distance {
    my ($calc, $dimension, $name) = @_;
    return unless $calc->stack->require_depth(2, $name);
    my $b = $calc->stack->pop;
    my $a = $calc->stack->pop;

    unless (RPN::Vector::is_vector($a) && $a->dim == $dimension
        && RPN::Vector::is_vector($b) && $b->dim == $dimension) {
        $calc->stack->push($a);
        $calc->stack->push($b);
        warn "$name requires two ${dimension}D points\n";
        return;
    }

    $calc->stack->push($a->subtract($b)->magnitude);
    return;
}

sub _push_factory_result {
    my ($calc, $original, $factory) = @_;

    my $result = eval { $factory->() };
    if ($@ || !RPN::Transform::is_transform($result)) {
        $calc->stack->push($_) for @{$original};
        warn $@ || "could not create transform\n";
        return;
    }

    $calc->stack->push($result);
    return 1;
}

1;
