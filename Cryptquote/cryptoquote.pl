#!/usr/bin/env perl
# A perl script to help solve cryptoquote puzzles.

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [-opt1] [-opt2] [-opt3]";

use strict;
use warnings;

use Term::ReadLine;
my $term = new Term::ReadLine
my $hist_save = $ENV{HOME} . "/.cryptoquote";
if (-s $hist_save) {
  open(HIST,"<$hist_save")
    || warn("$name: Cannot read from '$hist_save': $!\n");
  my(@hist)=<HIST>;
  @hist=grep((chomp($_),$_),@hist);
  close(HIST);
  $term->SetHistory(@hist)
}

my $puzzle;
my $response;
my $translate;
my $debug = 1;
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
foreach my $c ( keys %$translate ) {
  $from .= $c;
  $to   .= $translate->{$c};
}

while ( defined ($response = $term->readline($prompt)) ) {
  print STDERR "read a line.\n" if ( $debug );
  $response = uc $response;
  chomp($response);
  $response =~ s/^\s+|\s+$//g;
# $term->add_history($response);
  print "response was '$response'\n" if ( $debug );

  if (      $response =~ /^\s*$|^\s*#/) { # skip white, blank and commented lines.
    print "Skip line.\n" if ( $debug );
    next;

  } elsif ( $response =~ m/^\.$/ ) { # print out puzzle with translations
    print "Print puzzle.\n" if ( $debug );
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

  } elsif ( $response =~ m/^,$/ ) { # print out puzzle without translations
    print "Print raw puzzle.\n" if ( $debug );
    foreach my $line ( @$puzzle ) {
      print "$line";
    }

  } elsif ( $response =~ m/^([A-Z])[-,.>|;:'_ ]+([A-Z])?$/ ) { # add/clear translation
    print "Single new translation.\n" if ( $debug );
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

  } elsif ( $response =~ m/^(:|h(ist)?)$/i ) { # print out a histogram
    print "Print out a histogram of puzzle characters.\n" if ( $debug );
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

  } elsif ( $response =~ m/^l(eft)?$/i ) { # print out not translated to characters
    print "Print out characters to which there is yet a translation.\n" if ( $debug );
    my $alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    foreach my $char ( values %$translate ) {
       next if $char =~ / /;
       print "$char\n" if ( $debug );
       eval "\$alphabet =~ tr/$char/ /";
    }
    print "$alphabet\n";

  } elsif ( $response =~ m/^d(up(s)?)?$/i ) { # find dupicate translation values
    print "Print out characters to which there is two or more translations.\n" if ( $debug );
    my $counts;
    foreach my $key ( keys %$translate ) {
      push(@{$counts->{$translate->{$key}}},$key);
    }
    foreach my $char ( values %$translate ) {
      next if $char =~ / /;
      if ( scalar @{$counts->{$char}} > 1 ) {
      	print "Found duplicate translations leading to ($char)\n";
      	print "Namely, " . join(', ',@{$counts->{$char}}) . "\n";
      }
    }

  } elsif ( $response =~ m/^t(ran(s)?)?$/i ) { # input new translation matrix
    print "Input a completely new translation matrix.\n" if ( $debug );
    print "Input targets of new translation matrix: ";
    $from = <>; $from = uc $from; chomp $from;
    print "Input outputs of new translation matrix: ";
    $to   = <>; $to   = uc $to;   chomp $to;
    $translate = {};
    for (my($i)=0; $i<length($from); $i++) {
      my $c_from = substr($from, $i, 1);
      my $c_to   = substr($to,   $i, 1)   || ' ';
      print "($c_from) -> ($c_to)\n" if ( $debug );
      $translate->{$c_from} = $c_to;
    }

  } elsif ( $response =~ m/^a(dd)?$/i ) { # input additions to the translation matrix
    print "Input a multicharacter addition to the translation matrix.\n" if ( $debug );
    print "Input targets of addition to translation matrix: ";
    my $add_from = <>; $add_from = uc $add_from; chomp $add_from;
    print "Input outputs of addition to translation matrix: ";
    my $add_to   = <>; $add_to   = uc $add_to;   chomp $add_to;
    for (my($i)=0; $i<length($add_from); $i++) {
      my $c_from = substr($add_from, $i, 1);
      my $c_to   = substr($add_to,   $i, 1)   || ' ';
      print "($c_from) -> ($c_to)\n" if ( $debug );
      $translate->{$c_from} = $c_to;
    }
    $from = '';
    $to   = '';
    foreach my $c ( keys %$translate ) {
      $from .= $c;
      $to   .= $translate->{$c};
    }

  } elsif ( $response =~ m/^p(attern)?$/i ) { # print out pattern-matching words
    print "Input pattern for which to search: ";
    my $pattern = <>; chomp $pattern;
    &pattern($pattern);

  } elsif ( $response =~ m/^(\>|t(rans)?)$/i ) { # print out translation matrix
    print "Display the present translation matrix.\n" if ( $debug );
    if ( $from ) {
      print "$from\n";
      print "$to\n";
    } else { 
      print "No translation characters yet defined.\n"
    }

  } elsif ( $response =~ m/^2$/i ) { # print out common 2 letter words
    print "25 of some of the most common 2-letter words/combinations.\n";
    print "am	an	as	at	be\n";
    print "by	do	go	he	hi\n";
    print "if	in	is	it	me\n";
    print "my	no	of	on	or\n";
    print "so	to	up	us	we\n";
    print "T N S H R D L\n";
    print "E A I O U\n";
    print "Initial Letters: T O A W B C D S F M R H I Y E G L N P U J K\n";
    print "Final Letters:   E S T D N R Y F L O G H A K M P U W\n";
    print "Doubled Letters: SS, EE, TT, FF, LL, MM and OO\n";
    print "Digraphs:        TH ER ON AN RE HE IN ED ND HA AT EN ES OF OR NT EA TI TO IT ST IO LE IS OU AR AS DE RT VE\n";

  } elsif ( $response =~ m/^3$/i ) { # print out common 3 letter words
    print "Some of the most common 3-letter words/combinations.\n";
    print "the	and	for	are	but	not	you	all	any	can\n";
    print "her	was	one	our	out	day	get	has	him	his\n";
    print "how	man	new	now	old	see	two	way	who	boy\n";
    print "did	its	let	put	say	she	too	use	dad	mom\n";
    print "act	bar	car	dew	eat	far	gym	hey	ink	jet\n";
    print "key	log	mad	nap	odd	pal	ram	saw	tan	urn\n";
    print "vet	wed	yap	zoo\n";
    print "THE AND THA ENT ION TIO FOR NDE HAS NCE EDT TIS OFT STH MEN\n";

  } elsif ( $response =~ m/^4$/i ) { # print out common 4 letter words
    print "Some of the most common 4-letter words.\n";
    print "that, with, have, this, will, your, from, they, know, want, been, good, much, some, time\n";

  } elsif ( $response =~ m/^(c(lear)?|\*)$/i ) { # clear the transltion matrix
    print "Translation matrix has been cleared.\n";
    foreach my $c ( 'A' .. 'Z' ) {
      $translate->{$c} = ' ';
      $from .= $c;
      $to   .= ' ';
    }

  } elsif ( $response =~ /^(e(xit)?|q(uit)?)$/i ) {
    print "exiting...\n" if ( $debug );
    # apparently Term::ReadLine's GetHistory method returns an array poisoned with nulls
    my(@hist)= grep(/\S/,$term->GetHistory());
    if (@hist) {
      open(HIST, ">", $hist_save)
        || warn("$name: Cannot write to '$hist_save': $!\n");
      foreach my $hist (@hist) {
        chomp($hist); next if not $hist;
        printf HIST "%s\n", $hist;
      } 
      close(HIST);
    } 
    exit 0;

  } elsif ( $response =~ m/(h(elp)?|\?)$/i ) { # print out help
    print "-" x 40 . "\n";
    print ".|print   - print puzzle\n";
    print ",         - print puzzle without translation\n";
    print ":|hist    - print histogram of puzzle's characters\n";
    print "*|clear   - clear translation matrix\n";
    print ">|trans   - print translation matrix\n";
    print "l|left    - print characters for which there is yet a translation entry made\n";
    print "d|dups    - print characters to which there are two or more translations\n";
    print "t|trans   - input NEW translation matrix (on two following lines)\n";
    print "a|add     - input additions to the translation matrix (on two following lines)\n";
    print "p|pattern - print some known words matching the pattern of a input word\n";
    print "2         - print out the 25 most common 2-letter words and combinations\n";
    print "3         - print out some of most common 3-letter words and combinations\n";
    print "4         - print out some of most common 3-letter words and combinations\n";
    print "?|help    - print puzzle\n";
    print "X Y       - translate X's into Y's\n";
    print "X <space> - remove translation for X's\n";
    print "QUIT|EXIT\n";
    print "-" x 40 . "\n";
  }
  print "End of command loop: response was '$response'\n" if ( $debug );
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

sub pattern {
  my $pattern = shift;
  my ( $backref, $unique, $regexp, $characters );
  $backref->[1]  = '\1';
  $backref->[2]  = '\2';
  $backref->[3]  = '\3';
  $backref->[4]  = '\4';
  $backref->[5]  = '\5';
  $backref->[6]  = '\6';
  $backref->[7]  = '\7';
  $backref->[8]  = '\8';
  $backref->[9]  = '\9';
  $unique->[1]  = '(.)';
  $unique->[2]  = '((?!\1).)';
  $unique->[3]  = '((?!\1)(?!\2).)';
  $unique->[4]  = '((?!\1)(?!\2)(?!\3).)';
  $unique->[5]  = '((?!\1)(?!\2)(?!\3)(?!\4).)';
  $unique->[6]  = '((?!\1)(?!\2)(?!\3)(?!\4)(?!\5).)';
  $unique->[7]  = '((?!\1)(?!\2)(?!\3)(?!\4)(?!\5)(?!\6).)';
  $unique->[8]  = '((?!\1)(?!\2)(?!\3)(?!\4)(?!\5)(?!\6)(?!\7).)';
  $unique->[9]  = '((?!\1)(?!\2)(?!\3)(?!\4)(?!\5)(?!\6)(?!\7)(?!\8).)';
  $unique->[10] = '((?!\1)(?!\2)(?!\3)(?!\4)(?!\5)(?!\6)(?!\7)(?!\8)(?!\9).)';
  $regexp = '^';
  my $next_unique = 1;
  for (my($i)=0; $i<length($pattern); $i++) {
    my $char = substr($pattern, $i, 1);
    if ( exists $characters->{$char} ) {
      $regexp .= $characters->{$char};
    } else {
      $regexp .= $unique->[$next_unique];
      $characters->{$char} = $backref->[$next_unique];
      $next_unique++;
    }
  }
  $regexp .= '$';
  print "$regexp\n" if ( $debug );
  $regexp = qr($regexp);
  my $words_file="/usr/share/dict/web2";
  open(WORDS,"<", $words_file) || die("$name: Cannot read from '$words_file': $!\n");
  while (<WORDS>) {
    print if /$regexp/;
  }
  close(WORDS);
}

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

# puzzle 09 2018-10-27 Dispatch
# LPW'M KHM MOH EHTN PE
# KPIAW SH UNHTMHN MOTW
# MOH HYRAMHGHWM PE
# VAWWAWU. - NPSHNM ZAQPITZA
# solution 09
# TWJQIEPHGRLVYSBNMFACZUDXOK
# AN YSFOEMCDWXB RT I KG  HL

# puzzle 10 2018-10-29 Dispatch
  FXU EQCA CLNLF FE EZY
  YUBCLRBFLEQ ES FENEYYED
  DLCC HU EZY KEZHFM
  ES FEKBA. - SYBQPCLQ K. YEEMUOUCF
# solution 10
# WLUGFMKIBCJNAPQTOVERYZXHSD
#  IE TSD AL MYKN V OZRUHBFW
