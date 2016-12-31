#!/usr/bin/env perl

# A perl script to convert the json returned from getEnties.js from
#
# https://www.ingress.com/intel
#
# to *.kml or *.kmz (keyhole markup language) used by google maps.

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [-opt1] [-opt2] [-opt3]";

use strict;
use warnings;

use JSON;
use Carp;
use Data::Dumper;
# use Geo::KML::PolyMap;

my $json_file="map-01.json";
open(JSONFH,"<", $json_file) || die("$name: Cannot open '$json_file': $!\n");
my $json_text = '';
while (<JSONFH>) {
    chomp;
    $json_text .= $_;
}
close(JSONFH);

my $json = JSON->new->allow_nonref;
my $perl_scalar = $json->decode( $json_text );

$perl_scalar = $json->decode( $json_text );
print $json->pretty->encode( $perl_scalar ); # pretty-printing

exit 0;

__END__

http://www.pokemongomap.info/images/markerpoke.png

NAME
    JSON - JSON (JavaScript Object Notation) encoder/decoder

SYNOPSIS
     use JSON; # imports encode_json, decode_json, to_json and from_json.
 
     # simple and fast interfaces (expect/generate UTF-8)
 
     $utf8_encoded_json_text = encode_json $perl_hash_or_arrayref;
     $perl_hash_or_arrayref  = decode_json $utf8_encoded_json_text;
 
     # OO-interface
 
     $json = JSON->new->allow_nonref;
 
     $json_text   = $json->encode( $perl_scalar );
     $perl_scalar = $json->decode( $json_text );
 
     $pretty_printed = $json->pretty->encode( $perl_scalar ); # pretty-printing
 
     # If you want to use PP only support features, call with '-support_by_pp'
     # When XS unsupported feature is enable, using PP (de|en)code instead of XS ones.
 
     use JSON -support_by_pp;
 
     # option-acceptable interfaces (expect/generate UNICODE by default)
 
     $json_text   = to_json( $perl_scalar, { ascii => 1, pretty => 1 } );
     $perl_scalar = from_json( $json_text, { utf8  => 1 } );
 
     # Between (en|de)code_json and (to|from)_json, if you want to write
     # a code which communicates to an outer world (encoded in UTF-8),
     # recommend to use (en|de)code_json.


