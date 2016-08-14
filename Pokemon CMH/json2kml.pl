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

my $file="map-01.json";
open(FILE,"<", $file) || die("$name: Cannot open '$file': $!\n");
close(FILE);


exit 0;

__END__

http://www.pokemongomap.info/images/markerpoke.png
