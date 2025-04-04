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

if (@ARGV) {
    @syllables = @ARGV;
} else {
}
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

my $words_file='/usr/share/dict/web2';
open(WORDS,"<", $words_file) || die("$name: Cannot read from '$words_file': $!\n");
while (<WORDS>) {
  chomp;
  if ( $combos->{lc $_} ) {
    push(@found_words, lc $_);
  }
}
close(WORDS);

print "\n";
foreach (@found_words) {
  if ( $combos->{$_} =~ /\D/ ) { # alternate word found
    print "found words: $_\t$combos->{$_}\n";
  } else {
    print "found words: $_\n";
  }
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
        my $alternate_word = '';
        $combos->{ $possible_word }++;
        $count++;
        if ( $possible_word =~ /ies$/ ) {
            ($alternate_word = $possible_word) =~ s/ies$/y/;
            $combos->{ $alternate_word } = $possible_word;
        } elsif ( $possible_word =~ /es$/ ) {
            ($alternate_word = $possible_word) =~ s/es$//;
            $combos->{ $alternate_word } = $possible_word;
        } elsif ( $possible_word =~ /s$/ ) {
            ($alternate_word = $possible_word) =~ s/s$//;
            $combos->{ $alternate_word } = $possible_word;
        } elsif ( $possible_word =~ /ed$/ ) {
            ($alternate_word = $possible_word) =~ s/d$//;
            $combos->{ $alternate_word } = $possible_word;
            ($alternate_word = $possible_word) =~ s/ed$//;
            $combos->{ $alternate_word } = $possible_word;
        }
        if ( $add_ses ) {
          if ( $possible_word =~ /s$/ ) {
            ($alternate_word = $possible_word) =~ s/s$/ses/;
            $combos->{ $alternate_word } = $possible_word;
          } else {
            $alternate_word = $possible_word;
            $alternate_word .= 's';
            $combos->{ $alternate_word } = $possible_word;
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
scr ewd riv er des pond en cy ul tra sou nd ma rsh ali ng sea sic kne ss
# sigh ts ee ing ki neti cal ly log ger he ads sel ect iv ity pat ri ar chy
# cat er pil lar emp ha si ze lab yr inth ine ar ne min es tro met ic ith
# ded lly es cut tan ive wn se do ca rec con graeuph gl ori sca mp eri ng
# mic dom od rit yna eco st ga es ttl ar ck cha ab aer ly tic zing shu ate
# nic es sp ial go ogr ig or film otl emb gla diat tita ht al ly ies ar aph
# al bers ze ori ps em imm fra te bar ho rni uni fi cat ion pre sump tu ous
# oim ly ies ical ios cur tif ne aut bea it mu rev el ati on whe at gra ss
# sim ulta neo us per pet ua te mon ume nt al im agi nat ive br ow bea ten
# pin cu shi on wa tch wo rds co llo qui al hap pen sta nce geop oli ti cs
# ls qu tes mae tri bu mas tro ms era ded at pic kle ba ll pre fer enti al
# ado le sce nt sm art wa tch in equ it ies meri to cra cy cata pul ti ng
# mas ter min ded def in iti ve rs res ou bad ful au trou pe ton us ct omo
# st and sti lls lea de rbo ard rej uv en ate algo ri th mic mul ti med ia
# scr uf fie st ste am bo ats per so nal ity stra to sph ere fle dgl in gs
# do ve tai led pen ta thl ons mas och ist ic tra nslu ce nt flu ct uat ed
# sto ck pil es dis cer nib le car na tio ns fin al izi ng pyr ote chni cs
# arc hbi sho ps com pl exi ty spe nd thr ift mer ci ful ly do cu men ting
# dis bel ie ve qu in tup let to wns peo ple acc ele ra te tho rou ghbr ed
# eck ig ch rp sts rai call li ove sed ra phy ante ced en ts cen ter fo lds
# cli ck str eam da lli anc es for tuna te ly ext ra pol ate in qu isi tion
# co ndo mini um cata cly sm ic cul tiv at ed scr ut in ize poc ket kni fe
# man usc ri pt pla net ari um scr een pl ay up sta ndi ng effo rt les sly
# bac ch ana lia str ata ge ms tri gono met ry ab hor re nt dis sat isfi ed
# dre ad fu lly fri volo usn ess ins om ina cs tat ed pi ks bac tro ke pal
# sur vei lli ng jit ter bug ged hou se pla nt tap me mic ody ho rs bi na 
# li ngo nbe rry mi llio na ire agg rav at ed rad io act ive un fla vo red
# sh ru lti fi mb cur ic jel ons ge ist br ead tas ly mu ked mud alt cru
# key boa rdi sts chi ldb ir th tur du ck en sma rt ph one unpl eas ant ly
# se mi circ les inn ov at ion res pon si ble ha ck tiv ists tran qu ili ze
# semi aq ua tic ex pli ci tly tri um pha nt rec omm en ded win dow pan es entice
# phi lo so phy new fa ng led im per ial ist spon ta neo usly sch ool ma tes
# ur pha tal cy nti es clo ex ver peri af car ele icat le kr men ban ne upt
# fl our ish ing fea rf uln ess mul ti sta ge gyr os co pe$ auct ion ee  r$
# fri end li es bud ge ta ry ind iv idu ally pri nci pal ity gue ssti ma te
# gre men con uper ri sed vi te ous ss che der da mys ck poi uns sh bal nt
# ls less al sau beh ce rlfr ste gi nds ior mai rus go voi nev the er av ie
# le$ un$ ogy orn on hol cre it mb ti cra dis pro ve rb ial ga te kee p$
# les le$ uns un$ ogy orn on hol cre it mb ti cra dis pro ve rb ial ga te kee p$ ping
# yel low ta ils il$ gre en gro cer reco nsi de r$ red st op lig ht$ hts traf fi cki ng
# al to get her sc and ali zed gra s$ ss roo t$ ts hyd ran ge as hori zo nta lly
# acc om pan ied bel uig er ent blo od hou nd ir revo ca ble sim ula cr um
# wi se cra cked pur por ted ly cha nn eli ng bib lio ph ile ma rshm all ow
# yo ur sel ves tha nk fuln ess serv ice ab le you ng st ers for ma lde hyde
# pre sum ab ly lep re cha uns gla ss bl ower con sti tuen cy jay wal ki ng
# med al lio n out ru nn ing car boh ydr ate mar ath on er orth op edi c
# ib cre shi io iv bscr for ps mem ng ers ely di bat war su ber nary pro at
# fa ir gro und ball oo ni st safe gu ar ds out lan dis hly cou nter str ike d
# si nus it is det eri ora ted sym met ric al re mai nd er lac kad aisi cal
# gal li van ts he re dit ary tin der bo xes ro tis ser ie poly syl lab ic t x
# las ci vi ous theo re ti cal phe nom en on mis con str ue mou se tra ps
# sta ti one ry fr ost bit ten femi ni ne ly pap erw ei ght digi tiz ati on
# fra me wor ks pla yfu ln ess the ra peu tic ba rri ca des un doub ted ly
# acc ess ib le furt her mo re gre en wa sh cir cum sp ect scha den fre ude
# mem or an dum str ong hol ds sto ne wal led de cisi ve ly psy chi at ric
# stu us ste pre rg eo tero si ns pos nce sub un sea son ably tur tle ne ck 
# met ro poli tan so li loq uy ger ry man der com mon pla ce gym na st ics
# qua rt erl ies oc cup ati on mis pron oun ce imme as ur ably mil li lit ers
# thi ck eni ng con tra di ct bl ame wor thy dip lo ma tic idio syn cr asy
# nde ms gs nt eat re un res udo pub an ed can pse ple def mer li boo ny
# di sh clo th dog ma ti st com ment at or con sqe uen ce pand emo ni um
# vidi ici veni vici ous en ne ss che di con ng tly ma ck ant sub rom tes ze
# vina ig ret te mi cro cos ms sus pe ns ion sou nd pr oofs pon ti fic ate
# cou rse wo rk kin derg art en head mis tre ss at ten da nce uni ve rsi ty
# pes ca tar ian bee ke ep ing pro hibi ti ve hi ero gl yph sug ar coa ted
# un eve nt ful anth ro polo gy cus gs le ons ke cist po mi si rin han dis
# jal ck ster ap bu blo os en olo met gy hod com mo di fy spr in kl ed
# bar ns tor mers cle me nti ne eg reg io us wi nd sur fed eng in eer ing
# cub by ho le seq ues te red vac ci nat ion dis ast ro us phil har mon ic
# idi nd int fa st ous sta ri com do cio ot afi na po pat hype rte ns ion
# tee por ream eau ne st io red vol tri nt un tma li ll ted con nth ju ga
# ity, fan, wn, cie, siz, to, nis, al, nt, do, li, ry, tic, pur, ga, tas, ing, om, pecu, ar
# so mer sa ult mis be ha ves vau de vil le con jec tur al swi mm in gly

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
