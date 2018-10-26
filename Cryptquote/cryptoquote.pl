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

while (<DATA>) {
  next if (/^\s*$|^\s*#/); # skip white, blank and commented lines.
  push(@$puzzle, $_);
}
foreach my $c ( 'A' .. 'Z' ) {
  $translate->{$c} = ' ';
}
# $translate->{H} = 'T';
# $translate->{X} = 'H';
# $translate->{Q} = 'E';
# $translate->{G} = 'B';
foreach my $c ( keys %$translate ) {
  $from .= $c;
  $to   .= $translate->{$c};
}

while ( $response = &response( $prompt, 1 ) ) {
  next unless ($response =~ /./ );
  $response = uc $response;
  print "response was '$response'\n" if ( $debug );
  if (      $response =~ m/\./ ) { # print out puzzle with translations
    my $i = 0;
    print "\n";
    foreach my $line ( @$puzzle ) {
      my $new_line = $line;
      if ( $from ) {
        eval "\$new_line =~ tr/$from/$to/";
        print " $new_line";
      }
      print " $line";
      print "\n";
    }

  } elsif ( $response =~ m/,/ ) { # print out puzzle without translations
    foreach my $line ( @$puzzle ) {
      print "$line";
    }

  } elsif ( $response =~ m/([A-Z])[-,.>|;:'_ ]+([A-Z])?/ ) { # add/clear translation
    $from = '';
    $to   = '';
    my $c_from = uc $1;
    my $c_to   = $2 ? uc $2 : ' ';
    print "($c_from) -> ($c_to)\n";
    $translate->{$c_from} = $c_to;
    foreach my $c ( keys %$translate ) {
      $from .= $c;
      $to   .= $translate->{$c};
    }

  } elsif ( $response =~ m/(:|h(ist)?)$/i ) { # print out a histogram
    if ( scalar(keys %$histogram) == 0 ) {
      foreach my $line ( @$puzzle ) {
        foreach my $c ( split(//,$line) ) {
          next if ($c !~ /[A-Z]/);
          $histogram->{$c}++;
        }
      }
    }
    my @hist = ();
    foreach my $c ( sort keys %$histogram ) {
      push( @hist, sprintf ("%s - %2d", $c, $histogram->{$c} ) );
    }
    sub numerically_by_value { $histogram->{$a} <=> $histogram->{$b}; }
    my $index = 0;
    foreach my $c ( sort numerically_by_value keys %$histogram ) {
      $hist[$index] .= sprintf ("   %s - %2d\n", $c, $histogram->{$c} );
      $index++;
    }
    foreach ( @hist ) {
      print $_;
    }

  } elsif ( $response =~ m/l(eft)?$/i ) { # print out not translated to characters
    my $alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    foreach my $char ( values %$translate ) {
       $alphabet =~ tr/$char/ /;
    }
    print "$alphabet\n";

  } elsif ( $response =~ m/d(up(s)?)?$/i ) { # find dupicate translation values
    my $counts;
    foreach my $key ( keys %$translate ) {
      push(@{$counts->{$translate->{$key}}},$key);
    }
    foreach my $char ( values %$translate ) {
      if ( scalar @{$counts->{$char}} > 1 ) {
      	print "Found duplicate translations leading to ($char)\n";
      	print "Namely, " . join(', ',@{$counts->{$char}}) . "\n";
      }
    }
  } elsif ( $response =~ m/t(ran(s)?)?$/i ) { # input new translation matrix
    $from = <>; $from = uc $from;
    $to   = <>; $to   = uc $to;
    my $c_from = $1;
    my $c_to   = $2 || ' ';
    print "($c_from) -> ($c_to)\n" if ( $debug );
    $translate->{$c_from} = $c_to;

  } elsif ( $response =~ m/(\>|t(rans)?)$/i ) { # print out translation matrix
    if ( $from ) {
      print "$from\n";
      print "$to\n";
    } else { 
      print "No translation characters yet defined.\n"
    }

  } elsif ( $response =~ m/3$/i ) { # print out common 3 letter words
    print "the	and	for	are	but	not	you	all	any	can\n";
    print "her	was	one	our	out	day	get	has	him	his\n";
    print "how	man	new	now	old	see	two	way	who	boy\n";
    print "did	its	let	put	say	she	too	use	dad	mom\n";
    print "act	bar	car	dew	eat	far	gym	hey	ink	jet\n";
    print "key	log	mad	nap	odd	pal	ram	saw	tan	urn\n";
    print "vet	wed	yap	zoo\n";
    print "T N S H R D L\n";
    print "E A I O U\n";

  } elsif ( $response =~ m/2$/i ) { # print out common 2 letter words
    print "25 of some of the most common 2-letter words.\n";
    print "am	an	as	at	be\n";
    print "by	do	go	he	hi\n";
    print "if	in	is	it	me\n";
    print "my	no	of	on	or\n";
    print "so	to	up	us	we\n";
    print "T N S H R D L\n";
    print "E A I O U\n";
    print "SS, EE, TT, FF, LL, MM and OO\n";
    print "th er on an re he in ed nd ha at en es of or nt ea ti to it st io le is ou ar as de rt ve\n";

  } elsif ( $response =~ m/(c(lear)?|\*)$/i ) { # clear the transltion matrix
    print "Translation matrix has been cleaned.\n";
    foreach my $c ( 'A' .. 'Z' ) {
      $translate->{$c} = ' ';
      $from .= $c;
      $to   .= ' ';
    }

  } elsif ( $response =~ m/(h(elp)?|\?)$/i ) { # print out help
    print "-" x 40 . "\n";
    print ".|print   - print puzzle\n";
    print ",         - print puzzle without translation\n";
    print ":|hist    - print histogram of puzzle's characters\n";
    print "*|clear   - clear translation matrix\n";
    print ">|trans   - print translation matrix\n";
    print "l|left    - print characters for which there is yet a translation entry made\n";
    print "2         - print out the 25 most common 2-letter words\n";
    print "3         - print out some of most common 3-letter words\n";
    print "?|help    - print puzzle\n";
    print "X Y       - translate X's into Y's\n";
    print "X <space> - remove translation for X's\n";
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
# T N S H R D L
# E A I O U
#
# 12,000 E              2,500 F
#  9,000 T              2,000 W, Y
#  8,000 A, I, N, O, S  1,700 G, P
#  6,400 H              1,600 B
#  6,200 R              1,200 V
#  4,400 D                800 K
#  4,000 L                500 Q
#  3,400 U                400 J, X
#  3,000 C, M             200 Z


# puzzle 01
# NFYS FT ZIH CBTFJ MU
# KBZBCGKY NFGST KCMGDTZ
# ZIH UKSHS NMMST.
# - NFYYFKC NMLSTNMLZI
# solution 01
# GKZUAJIQXOMDHSWPTCYBVFNREL
# NATF CH   OGED  SMLU IW  R

# puzzle 02
# WC JBX HQF BKIQD DQPQPGQD
# JBX ZWEQ WYBFZQD ZWYI:
# FZQ AMDCF MC FB ZQKT
# JBXDCQKA. FZQ CQVBYI
# MC FB ZQKT BFZQDC.
# - WXIDQJ ZQTGXDY
# solution 02
# QNVFKRJOAYUDBIMXLPTWCSEGHZ
# E CTL Y FN RODIU MPAS VBGH

# puzzle 03
# QRCRA TJCR JQ RWNRMV VF
# NFQCJNVJFQG FE DFQFA LQY
# TFFY GRQGR.
# - UJQGVFQ NDPANDJKK
# solution 03
# ZEIWPJTKLCHODSQMYRAFGUBNXV
#  F XUIGLAV  H NPDEROSW C T
# 1 rebel defer refer renew repel leper beset reset meter level seven never jewel vexed inane
# 2 deadly  dredge  drudge  eatery  eldest  endear  excess  expect  expend  expert  extend 
# 3 edged sense onion    d e n 

# puzzle 04
# GRK CLEEKBKYOK FKGDKKY
# DRS ZSM WBK WYC DRS ZSM
# DWYG GS FK LV DRWG ZSM
# CS. - MYAYSDY
# solution 04
# PVOGBXCIYNSMHWKUDAFJLERZQT
# SCTR D N OU AE WKB IFHY  

# puzzle 05 2018-10-23 Dispatch
# ABV PWS JVGDVHDY HWD
# WBAQZEXDE PBC CABEH; ABV
# PWS JVGDVHDY HWD
# LWDDCDQZEXDE PBC B XDVJZC.
# - ABHHWDP ALLSVBZXWDN
# solution 05
# WKOQBHSCDENZGRVFTMUJAXPLIY
# H  BATOSER UV N    IMGWC D

# puzzle 06 2018-10-24 Dispatch
# BJ HVG TLDUUH UVVP
# MUVRLUH.  ZVRI VSLTQBNFI
# RGMMLRRLR IVVP D UVQN
# IBZL.  - RILSL YVOR
# solution 06
# CIXPTQVUMDEWANORLGKHZYSBFJ
#  T KRNOLCA   GBSEU YMJVIHF

# puzzle 07 2018-10-25 Dispatch
# YJOGO KGO TL ZOUGOYZ YL
# ZSUUOZZ. DY DZ YJO GOZSWY
# LB EGOEKGKYDLT. JKGM
# RLGP. KTM WOKGTDTN BGLV
# BKDWSGO. - ULWDT ELROWW
# solution 07
# BIDZKSGJEPAWVFQOUNYMLRHTXC
# F ISAURHPK LM  ECGTDOW N  
#
# puzzle 08 2018-10-26 Dispatch
# KSMMLWZALLM DQMDKLW. MJL
# PLXXDA, PLZZB, XLTG-RSQRSHI,
# YLWGLQM YTEZL KLMALLH MJL
# DYYDZSHI PSZLWSLZ DG
# ZEPPLW THF ASHMLW.
# - QTWDX KSZJDY JSYYZ
# PP ZZ LL YY
# solution 08
# EGWKOALPVHTFDIBQSYMUJZXRNC
# UFRB WEM NADOGYCIPT HSLK  
