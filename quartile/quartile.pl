#!/usr/bin/env perl
# A perl script to help solving quartile puzzle from the New York Times
#
# Total number of possible 4 syllable words will be 20*19*18*17 = 116,280

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [+X] .. [-Y] ..";

use strict;
use warnings;

use Data::Dumper;

my $debug = 1;
my $word = '';
my $syllable = '';

my %matches;
my @syllables = ();
my @found_words = ();

while (<DATA>) {
  next if (/^\s*$|^\s*#/); # skip white, blank and commented lines.
  chomp;
  s/^\s+|\s*$//g;
  push( @syllables, sort split(/[ ;,]+/, $_) );
}
if ($debug) {
  print "found these tiles: " . join(", ", @syllables) . ".\n"
}

my $combos = return_combos(@syllables);

if ( $combos->{'also'} ) {
  print "found 'also'\n";
}

my $words_file='/usr/share/dict/web2';
open(WORDS,"<", $words_file) || die("$name: Cannot read from '$words_file': $!\n");
while (<WORDS>) {
  chomp;
  if ( $combos->{lc $_} ) {
    push(@found_words, $_);
  }
}
close(WORDS);

print "\n";
foreach (@found_words) {
  print "found words: $_\n";
}

sub return_combos {
  my @n = @_;
  my $debug   = 1;
  my $count   = 0;
  my $add_ses = 0;
  my $combos  = {};
  my $possible_word = '';
  my $permutation;
  use Math::Combinatorics;

  if ($debug) {
    print "our array starts with " . ($#n + 1) . " elements.\n"
  }
  for ( my($i) = 1; $i <= 4; $i++ ) {
    $count = 0;
    # Object Oriented verrsion
    # my $comb = Math::Combinatorics->new(count => $i, data => [@n],);
    # my @permutations = permute($comb->next_combination);
    my @combos = combine($i, @n);
    # print Dumper(\@combos);
    # exit;
    foreach my $combo ( @combos ) {
      # print join(" ", @$combo) . "\n" if ($debug);
      my @permutations = permute(@$combo);
      foreach my $tiles ( @permutations ) {
        # print Dumper($tiles);
        # exit;
        $possible_word = join('', @$tiles);
        $combos->{ $possible_word }++;
        $count++;
        if ( $add_ses ) {
          if ( $possible_word =~ /s$/ ) {
            $possible_word =~ s/s$//;
            $combos->{ $possible_word }++;
          } else {
            $possible_word .= 's';
            $combos->{ $possible_word }++;
          }
        }
      }
    }
    if ($debug) {
      print "$count combinations with $i tiles.\n";
    }
  }
  print "total combos: " . scalar ( keys %$combos ) . "\n";
  if ( $debug > 1 ) {
    foreach (sort keys %$combos) {
      print "combo: >$_<\n";
    }
  }
  return $combos;
}


exit 0;

__END__
# ity, fan, wn, cie, siz, to, nis, al, nt, do, li, ry, tic, pur, ga, tas, ing, om, pecu, ar

so mer sa ult mis be ha ves vau de vil le con jec tur al swi mm in gly

# conjectureal
# misbehaves
# somersault
# swimmingly
# vaudeville
# also
# be
# bedevil
# behaves
# con
# deal
# devil
# ha
# hale
# haves
# in
# inhale
# insole
# lede
# misdeal
# sale
# saves
# so
# sole

# if ( $debug ) {
#   print "have: '"   . join(",",@must_have)  . "'\n";
#   print "not:   '"  . $must_not_have        . "'\n";
#   print "match:  '" . $must_match           . "'\n";
# }
# my $infile="long_words.txt";
# open(LONG,"<", $infile) || die("$name: Cannot read from '$infile': $!\n");
# while ($word = <LONG>) {
#     chomp $word;
#     foreach $syllable (@syllables) {
#         if ($word =~ /$syllable/) {
#            if ($debug > 1) {
#                printf("Found %5s in %s\n", $syllable, $word);
#            }
#            $matches{$word}++;
#         }
#     }
# }
# close(LONG);
# foreach $word (keys %matches) {
#   if ( $matches{$word} > 2 ) {
#       printf("%3d %s\n", $matches{$word}, $word);
#   }
# }
