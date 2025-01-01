#!/usr/bin/env perl
# A perl script to SCRIPT_DESCRIPTION

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [-opt1] [-opt2] [-opt3]";

use strict;
use warnings;

while (<>) {
  my %az = ();
  foreach my $i ( 'a' .. 'z' ) {
    $az{$i}++;
  };
  my $l = $_;
  chomp $l;
  my @c = split(//,$l);
  foreach my $c (@c) {
    $az{$c}--;
  };
  $l .= "    ";
  foreach my $c (sort keys %az) {
    if ( $az{$c} ) {
      $l .= "  $c"
    }
  }
  print "$l\n";
}

exit 0;

__END__
