use v5.34;
use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use lib 'lib';
use RPN::Graphics::Point;
use RPN::Graphics::Plot;
use RPN::Graphics::QRCode;
use RPN::Graphics::Scene;
use RPN::Graphics::Shape;
use RPN::Graphics::SVG;
use RPN::Transform;

{
    package Text::QRCode;
    sub new { bless {}, shift }
    sub plot { [[qw(* 0 *)], [qw(0 * 0)], [qw(* 0 *)]] }
}
$INC{'Text/QRCode.pm'} = __FILE__;

my $point = RPN::Graphics::Point->new(2, 3);
is($point->transform(RPN::Transform->translation2d(4, 5))->as_string,
    'point(6,8)', 'graphics point uses 2D transforms');
my $line = RPN::Graphics::Shape->new(type => 'line', data => [1,2,3,4]);
my $styled = $line->with_style(stroke => 'red');
is($line->style->{stroke}, undef, 'shape styling is immutable');
is($styled->style->{stroke}, 'red', 'styled copy has new stroke');
my $moved = $styled->transformed(RPN::Transform->translation2d(10, 20));
my $scene = RPN::Graphics::Scene->new(width => 320, height => 200)->add($moved);
is($scene->shape_count, 1, 'scene contains shape');
my $svg = RPN::Graphics::SVG->render($scene);
like($svg, qr/<svg /, 'renders SVG document');
like($svg, qr/<line /, 'renders line');
like($svg, qr/transform="matrix\(1 0 0 1 10 20\)"/, 'renders transform matrix');
like($svg, qr/stroke="red"/, 'renders style');
my $dir = tempdir(CLEANUP => 1); my $file = "$dir/test.svg";
ok(RPN::Graphics::SVG->save($scene, $file), 'saves SVG');
ok(-s $file, 'SVG file is nonempty');
my $plot = RPN::Graphics::Plot->scene(x => [-1,0,1], y => [1,0,1], width => 400, height => 300);
ok(RPN::Graphics::Scene::is_scene($plot), 'plot creates scene');
cmp_ok($plot->shape_count, '>=', 2, 'plot includes curve and axes');
my $qr = RPN::Graphics::QRCode->from_matrix([[1,0,1],[0,1,0],[1,0,1]], x=>10,y=>10,size=>90);
my $qrsvg = RPN::Graphics::SVG->render(RPN::Graphics::Scene->new(width=>110,height=>110)->add($qr));
like($qrsvg, qr/<g fill="black"/, 'renders QR module group');
is(() = $qrsvg =~ /<rect x=/g, 5, 'renders each dark QR module');
my $encoded = RPN::Graphics::QRCode->encode('hello', size => 110);
is($encoded->type, 'qrcode', 'optional encoder creates QR shape');
is(scalar @{ ($encoded->data)->[0] }, 11, 'encoder adds four-module quiet zone');
done_testing();
