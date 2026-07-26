package RPN::Commands::Graphics;

use v5.34;
use strict;
use warnings;

use RPN::CodeBlock;
use RPN::Graphics::Plot;
use RPN::Graphics::QRCode;
use RPN::Graphics::Scene;
use RPN::Graphics::Shape;
use RPN::Graphics::SVG;
use RPN::Matrix;
use RPN::Transform;
use RPN::Vector;

sub register_commands {
    my ($commands) = @_;
    $commands->register(scene => { category => 'graphics', help => 'create an SVG scene: WIDTH HEIGHT scene', code => sub {
        my ($c) = @_; _factory($c, 2, 'scene', sub { RPN::Graphics::Scene->new(width => $_[0], height => $_[1]) });
    }});
    $commands->register(line => { category => 'graphics', help => 'create a line: X1 Y1 X2 Y2 line', code => sub {
        my ($c) = @_; _shape($c, 'line', 4);
    }});
    $commands->register(rectangle => { aliases => ['rect'], category => 'graphics', help => 'create a rectangle: X Y WIDTH HEIGHT rectangle', code => sub {
        my ($c) = @_; _shape($c, 'rectangle', 4);
    }});
    $commands->register(circle => { category => 'graphics', help => 'create a circle: CX CY R circle', code => sub {
        my ($c) = @_; _shape($c, 'circle', 3);
    }});
    $commands->register(polygon => { category => 'graphics', help => 'create a polygon from an Nx2 matrix', code => sub {
        my ($c) = @_; return unless $c->stack->require_depth(1, 'polygon'); my $m = $c->stack->pop;
        unless (RPN::Matrix::is_matrix($m) && $m->cols == 2 && $m->rows >= 3) { $c->stack->push($m); warn "polygon requires an Nx2 matrix with at least three points\n"; return }
        $c->stack->push(RPN::Graphics::Shape->new(type => 'polygon', data => [$m->data]));
    }});
    $commands->register(draw => { category => 'graphics', help => 'add a shape immutably: SCENE SHAPE draw', code => sub {
        my ($c) = @_; return unless $c->stack->require_depth(2, 'draw'); my $shape = $c->stack->pop; my $scene = $c->stack->pop;
        unless (RPN::Graphics::Scene::is_scene($scene) && RPN::Graphics::Shape::is_shape($shape)) { $c->stack->push($scene, $shape); warn "draw requires a scene and a graphics shape\n"; return }
        $c->stack->push($scene->add($shape));
    }});
    $commands->register(transformshape => { aliases => ['xformshape'], category => 'graphics', help => 'transform a shape: SHAPE TRANSFORM transformshape', code => sub {
        my ($c) = @_; return unless $c->stack->require_depth(2, 'transformshape'); my $t = $c->stack->pop; my $shape = $c->stack->pop;
        unless (RPN::Graphics::Shape::is_shape($shape) && RPN::Transform::is_transform($t) && $t->dimension == 2) { $c->stack->push($shape, $t); warn "transformshape requires a shape and a 2D transform\n"; return }
        $c->stack->push($shape->transformed($t));
    }});
    for my $spec ([strokecolor => 'stroke'], [fillcolor => 'fill'], [strokewidth => 'stroke-width']) {
        my ($name, $key) = @$spec;
        $commands->register($name => { category => 'graphics', help => "set shape $key: SHAPE VALUE $name", code => sub {
            my ($c) = @_; return unless $c->stack->require_depth(2, $name); my $value = $c->stack->pop; my $shape = $c->stack->pop;
            unless (RPN::Graphics::Shape::is_shape($shape) && defined($value) && !ref($value)) { $c->stack->push($shape, $value); warn "$name requires a shape and scalar value\n"; return }
            $c->stack->push($shape->with_style($key => $value));
        }});
    }
    $commands->register(svg => { category => 'graphics', help => 'render a scene as SVG text', code => sub {
        my ($c) = @_; return unless $c->stack->require_depth(1, 'svg'); my $scene = $c->stack->pop;
        unless (RPN::Graphics::Scene::is_scene($scene)) { $c->stack->push($scene); warn "svg requires a graphics scene\n"; return }
        $c->stack->push(RPN::Graphics::SVG->render($scene));
    }});
    $commands->register(savesvg => { category => 'graphics', help => 'save a scene: SCENE FILENAME savesvg', code => sub {
        my ($c) = @_; return unless $c->stack->require_depth(2, 'savesvg'); my $file = $c->stack->pop; my $scene = $c->stack->pop;
        unless (RPN::Graphics::Scene::is_scene($scene) && defined($file) && !ref($file)) { $c->stack->push($scene, $file); warn "savesvg requires a scene and filename\n"; return }
        my $ok = eval { RPN::Graphics::SVG->save($scene, $file) }; if (!$ok) { $c->stack->push($scene, $file); warn $@; return } $c->stack->push($file);
    }});
    $commands->register(plot => { category => 'graphics', help => 'plot vectors: XVECTOR YVECTOR WIDTH HEIGHT plot', code => sub {
        my ($c) = @_; return unless $c->stack->require_depth(4, 'plot'); my ($h,$w,$yv,$xv) = map { $c->stack->pop } 1..4;
        unless (_vector_numbers($xv) && _vector_numbers($yv) && $xv->dim == $yv->dim) { $c->stack->push($xv,$yv,$w,$h); warn "plot requires equal numeric x and y vectors, width, and height\n"; return }
        my $scene = eval { RPN::Graphics::Plot->scene(x => [$xv->values], y => [$yv->values], width => $w, height => $h) };
        if (!$scene) { $c->stack->push($xv,$yv,$w,$h); warn $@; return } $c->stack->push($scene);
    }});
    $commands->register(functionplot => { category => 'graphics', help => 'plot executable: XMIN XMAX SAMPLES WIDTH HEIGHT EXEC functionplot', code => sub { _function_plot(@_) }});
    $commands->register(qrcode => { category => 'graphics', help => 'create an SVG QR shape: TEXT X Y SIZE qrcode', code => sub {
        my ($c) = @_; return unless $c->stack->require_depth(4, 'qrcode'); my ($size,$y,$x,$text) = map { $c->stack->pop } 1..4;
        my $shape = eval { RPN::Graphics::QRCode->encode($text, x=>$x, y=>$y, size=>$size) };
        if (!$shape) { $c->stack->push($text,$x,$y,$size); warn $@; return } $c->stack->push($shape);
    }});
    $commands->register(qravailable => { category => 'graphics', help => 'push 1 when optional QR support is installed, otherwise 0', code => sub { $_[0]->stack->push(RPN::Graphics::QRCode->available) }});
    return;
}

sub _shape { my ($c,$type,$count)=@_; _factory($c,$count,$type,sub { RPN::Graphics::Shape->new(type=>$type,data=>[@_]) }) }
sub _factory {
    my ($c,$count,$name,$factory)=@_; return unless $c->stack->require_depth($count,$name);
    my @v = reverse map { $c->stack->pop } 1..$count; my $result = eval { $factory->(@v) };
    if (!$result) { $c->stack->push(@v); warn $@; return } $c->stack->push($result); return 1;
}
sub _vector_numbers { my ($v)=@_; return unless RPN::Vector::is_vector($v); for ($v->values) { return if ref($_) || $_ !~ /^[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?$/ } return 1 }
sub _function_plot {
    my ($c)=@_; return unless $c->stack->require_depth(6,'functionplot');
    my ($exec,$height,$width,$samples,$xmax,$xmin)=map{$c->stack->pop}1..6; my @original=($xmin,$xmax,$samples,$width,$height,$exec);
    unless ((!ref($exec) || RPN::CodeBlock::is_codeblock($exec)) && $samples =~ /^\d+$/ && $samples >= 2 && $xmax > $xmin) { $c->stack->push(@original); warn "functionplot requires a range, sample count, dimensions, and executable value\n"; return }
    my (@xs,@ys); my @saved=$c->stack->values;
    for my $i (0..$samples-1) { my $x=$xmin+($xmax-$xmin)*$i/($samples-1); $c->stack->set_values($x); my $ok=eval{$c->execute($exec);1}; my $y=$c->stack->peek; if(!$ok || $c->stack->depth != 1 || !defined($y) || ref($y) || !$c->isanumber($y)){ $c->stack->set_values(reverse(@original),@saved); warn $@||"functionplot executable must return one number\n"; return } push @xs,$x; push @ys,$y }
    $c->stack->set_values(@saved); my $scene=eval{RPN::Graphics::Plot->scene(x=>\@xs,y=>\@ys,width=>$width,height=>$height)}; if(!$scene){$c->stack->push(@original);warn$@;return}$c->stack->push($scene);
}

1;
