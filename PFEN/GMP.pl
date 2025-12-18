#!/usr/bin/env perl
# A perl script to Demonstrate Features of the Math::Prime::Util::GMP Module
use strict;
use warnings;
use feature 'say';

use Math::Prime::Util::GMP ':all';
my $n = "115792089237316195423570985008687907853269984665640564039457584007913129639937";

# This doesn't impact the operation of the module at all, but does let you
# enter big number arguments directly as well as enter (e.g.): 2**2048 + 1.
use bigint;

# These return 0 for composite, 2 for prime, and 1 for probably prime
# Numbers under 2^64 will return 0 or 2.
# is_prob_prime does a BPSW primality test for numbers > 2^64
# is_prime adds some MR tests and a quick test to try to prove the result
# is_provable_prime will spend a lot of effort on proving primality

say "$n is probably prime"    if is_prob_prime($n);
say "$n is ", qw(composite prob_prime def_prime)[is_prime($n)];
say "$n is definitely prime"  if is_provable_prime($n) == 2;

# Miller-Rabin and strong Lucas-Selfridge pseudoprime tests
say "$n is a prime or spsp-2/7/61" if is_strong_pseudoprime($n, 2, 7, 61);
say "$n is a prime or slpsp"       if is_strong_lucas_pseudoprime($n);
say "$n is a prime or eslpsp"      if is_extra_strong_lucas_pseudoprime($n);

# Return array reference to primes in a range.
my $aref = primes( 10 ** 200, 10 ** 200 + 10000 );

my $next = next_prime($n);    # next prime > n
my $prev = prev_prime($n);    # previous prime < n

# Primorials and lcm
say "23# is ", primorial(23);
say "The product of the first 47 primes is ", pn_primorial(47);
say "lcm(1..1000) is ", consecutive_integer_lcm(1000);


# Find prime factors of big numbers
my @factors = factor(5465610891074107968111136514192945634873647594456118359804135903459867604844945580205745718497);
say 'factors ', join(", ",@factors);

# Finer control over factoring.
# These stop after finding one factor or exceeding their limit.
#                               # optional arguments o1, o2, ...
@factors = trial_factor($n);    # test up to o1
say '  trial factors ', join(", ",@factors);
@factors = prho_factor($n);     # no more than o1 rounds
say '   prho factors ', join(", ",@factors);
@factors = pbrent_factor($n);   # no more than o1 rounds
say ' pbrent factors ', join(", ",@factors);
@factors = holf_factor($n);     # no more than o1 rounds
say '   holf factors ', join(", ",@factors);
@factors = squfof_factor($n);   # no more than o1 rounds
say ' squfof factors ', join(", ",@factors);
@factors = pminus1_factor($n);  # o1 = smoothness limit, o2 = stage 2 limit
say 'pminus1 factors ', join(", ",@factors);
@factors = ecm_factor($n);      # o1 = B1, o2 = # of curves
say '    ecm factors ', join(", ",@factors);
@factors = qs_factor($n);       # (no arguments)
say '     qs factors ', join(", ",@factors);

__END__
> ./GMP.pl
115792089237316195423570985008687907853269984665640564039457584007913129639937 is composite
23# is 223092870
The product of the first 47 primes is 1645783550795210387735581011435590727981167322669649249414629852197255934130751870910
lcm(1..1000) is 7128865274665093053166384155714272920668358861885893040452001991154324087581111499476444151913871586911717817019575256512980264067621009251465871004305131072686268143200196609974862745937188343705015434452523739745298963145674982128236956232823794011068809262317708861979540791247754558049326475737829923352751796735248042463638051137034331214781746850878453485678021888075373249921995672056932029099390891687487672697950931603520000
factors 165901, 10424087, 18830281, 53204737, 56402249, 59663291, 91931221, 95174413, 305293727939, 444161842339, 790130065009
trial factors 115792089237316195423570985008687907853269984665640564039457584007913129639937
prho factors 1238926361552897, 93461639715357977769163558199606896584051237541638188580280321
pbrent factors 1238926361552897, 93461639715357977769163558199606896584051237541638188580280321
holf factors 115792089237316195423570985008687907853269984665640564039457584007913129639937
squfof factors 115792089237316195423570985008687907853269984665640564039457584007913129639937
pminus1 factors 115792089237316195423570985008687907853269984665640564039457584007913129639937
ecm factors 1238926361552897, 93461639715357977769163558199606896584051237541638188580280321
qs factors 93461639715357977769163558199606896584051237541638188580280321, 1238926361552897

