#!/usr/bin/env perl
# A perl script to help solve cryptoquote puzzles.

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [-opt1] [-opt2] [-opt3]";

use strict;
use warnings;

my $puzzle;
my $response;
my $translate;
my $debug = 0;
my $prompt = 'Command: ';
my $histogram;
my $from;
my $to;

@$puzzle = <DATA>;
foreach my $c ( 'A' .. 'Z' ) {
  $translate->{$c} = ' ';
}
$translate->{Z} = 'T';
$translate->{I} = 'H';
$translate->{H} = 'E';
foreach my $c ( keys %$translate ) {
  $from .= $c;
  $to   .= $translate->{$c};
}

while ( $response = &response( $prompt, 1 ) ) {
  next unless ($response =~ /./ );
  $response = uc $response;
  print "response was '$response'\n" if ( $debug );
  if (      $response =~ m/\./ ) {
    my $i = 0;
    print "\n";
    foreach my $line ( @$puzzle ) {
      my $new_line = $line;
      if ( $from ) {
        eval "\$new_line =~ tr/$from/$to/";
        print " $new_line";
      }
      print " $line";
    }
    print "\n";
  } elsif ( $response =~ m/([A-Z])[-,.>|;:'_ ]+([A-Z])?/ ) {
    $from = '';
    $to   = '';
    my $c_from = uc $1;
    my $c_to   = uc $2 || ' ';
    print "($c_from) -> ($c_to)\n";
    $translate->{$c_from} = $c_to;
    foreach my $c ( keys %$translate ) {
      $from .= $c;
      $to   .= $translate->{$c};
    }
  } elsif ( $response =~ m/(:|h(ist)?)$/i ) {
    if ( scalar(keys %$histogram) == 0 ) {
      foreach my $line ( @$puzzle ) {
        foreach my $c ( split(//,$line) ) {
          next if ($c !~ /[A-Z]/);
          $histogram->{$c}++;
        }
      }
    }
    foreach my $c ( keys %$histogram ) {
      printf "%s - %d\n", $c, $histogram->{$c};
    }
  } elsif ( $response =~ m/(\>|t(rans)?)$/i ) {
    if ( $from ) {
      print "$from\n";
      print "$to\n";
    } else { 
      print "No translation characters yet defined.\n"
    }
  } elsif ( $response =~ m/2$/i ) {
    print "25 of some of the most common 2-letter words.\n";
    print "am	an	as	at	be\n";
    print "by	do	go	he	hi\n";
    print "if	in	is	it	me\n";
    print "my	no	of	on	or\n";
    print "so	to	up	us	we\n";
  } elsif ( $response =~ m/(c(lear)?|\*)$/i ) {
    print "Translation matrix has been cleaned.\n";
    foreach my $c ( 'A' .. 'Z' ) {
      $translate->{$c} = ' ';
      $from .= $c;
      $to   .= ' ';
    }
  } elsif ( $response =~ m/(h(elp)?|\?)$/i ) {
    print "-" x 40 . "\n";
    print ".|print   - print puzzle\n";
    print ":|hist    - print histogram of puzzle's characters\n";
    print "*|clear   - clear translation matrix\n";
    print ">|trans   - print translation matrix\n";
    print "2         - print out the 25 most common 2-letter words\n";
    print "?|help    - print puzzle\n";
    print "X Y       - replace X's with Y's\n";
    print "X <space> -  replace X's with Y's\n";
    print "QUIT|EXIT\n";
    print "-" x 40 . "\n";
  }
}

sub response {
  my ( $prompt, $reply, $regexp, $exit_regexp ) = @_;
  print ( $prompt ? $prompt : "yes|no " ) ;
  my $response=<STDIN>;
  chomp $response;
  $exit_regexp ||= '^e(xit)?$|^q(uit)?$';
  if ($exit_regexp and $response=~/$exit_regexp/i) {
    print "Quitting $name in response to user input '$response'\n";
    exit;
  }
  if ( $reply ) {
    return $response;
  } else {
    return ($response =~ /$regexp/i);
  }
}
exit 0;

__END__
NFYS FT ZIH CBTFJ MU
KBZBCGKY NFGST KCMGDTZ
ZIH UKSHS NMMST.
- NFYYFKC NMLSTNMLZI
