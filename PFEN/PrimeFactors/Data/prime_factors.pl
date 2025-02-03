#!/usr/bin/env perl
# A perl script to SCRIPT_DESCRIPTION

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name";

use strict;
use warnings;
use DBI;
use DBD::MYSQL;

my $prime_factor_file = $name;

#    $prime_factor_file =~ s:\.pl:_tight.txt:;
# open(PRIME_FACTORS,"<", $prime_factor_file) || die("$name: Cannot read from '$prime_factor_file': $!\n");

$prime_factor_file =~ s:\.pl:.txt.gz:;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;
my $z = new IO::Uncompress::Gunzip $prime_factor_file
  or die "gunzip failed: $GunzipError\n";

my ( $number, $factorization, $prime_sequence, $prime ) ;

# while (my $line = <PRIME_FACTORS>) {
while (my $line = <$z>) {
    next if ($line !~ /=/);
    print $line;
    chomp $line;
    my ($number, $RHS);
    ( $number, $RHS ) = ( $line =~ /(^\d+)=(.*)/ );
    if ( $line =~ /\((\d+)\)/ ) { # prime
        $prime = $1;
        print " $number is the $prime-th prime.\n";
    }
    if ( $RHS =~ /;(\d+)/ ) {
    	my $prime_factor_sequence = $1;
    	print " $number is a prime factor sequence: $prime_factor_sequence\n";
    	$RHS =~ s/;\d+//;
    }
    if ( $RHS =~ /^[0-9x^]+$/ ) { # prime sequence product
    	parse_factorization($RHS);
    }
}
# close(PRIME_FACTORS);

sub parse_factorization {
    my $factorization_string = shift;
    my @factors = split( /x/, $factorization_string );
    my $factor_exponents = {};
    my $exponent;
    foreach my $prime_factor (@factors) {
      my ($factor, $exponent) = ( $prime_factor =~ /(\d+)\^?(\d*)/ );
      $exponent = 1 if (not $exponent);
      $factor_exponents->{$factor}=$exponent;
    }
    print " " . join(', ', @factors) . "\n";
    return $factor_exponents;
}

exit 0;

__END__

Prime Factors 2-99999
2=2(1);1
3=3(2)
4=2^2
5=5(3)
6=2x3;2
7=7(4)
8=2^3
9=3^2
10=2x5

Prime Factors 2-99999
2 = 2 (prime 1) ** prime sequence = 1
3 = 3 (prime 2)
4 = 2^2
5 = 5 (prime 3)
6 = 2 x 3 ** prime sequence = 2
7 = 7 (prime 4)
8 = 2^3
9 = 3^2
10 = 2 x 5
11 = 11 (prime 5)
12 = 2^2 x 3
13 = 13 (prime 6)
14 = 2 x 7
15 = 3 x 5
16 = 2^4
17 = 17 (prime 7)
18 = 2 x 3^2
19 = 19 (prime 8)
20 = 2^2 x 5
21 = 3 x 7
22 = 2 x 11
23 = 23 (prime 9)
24 = 2^3 x 3
25 = 5^2
26 = 2 x 13
27 = 3^3
28 = 2^2 x 7
29 = 29 (prime 10)
30 = 2 x 3 x 5 ** prime sequence = 3
31 = 31 (prime 11)
32 = 2^5
33 = 3 x 11
34 = 2 x 17
35 = 5 x 7
36 = 2^2 x 3^2
37 = 37 (prime 12)
38 = 2 x 19
39 = 3 x 13
40 = 2^3 x 5
41 = 41 (prime 13)
42 = 2 x 3 x 7
43 = 43 (prime 14)
44 = 2^2 x 11
45 = 3^2 x 5
46 = 2 x 23
47 = 47 (prime 15)
48 = 2^4 x 3
49 = 7^2
50 = 2 x 5^2
51 = 3 x 17
52 = 2^2 x 13
53 = 53 (prime 16)
54 = 2 x 3^3
55 = 5 x 11
56 = 2^3 x 7
57 = 3 x 19
58 = 2 x 29
59 = 59 (prime 17)
60 = 2^2 x 3 x 5
61 = 61 (prime 18)
62 = 2 x 31
63 = 3^2 x 7
64 = 2^6
65 = 5 x 13
66 = 2 x 3 x 11
67 = 67 (prime 19)
68 = 2^2 x 17
69 = 3 x 23
70 = 2 x 5 x 7
71 = 71 (prime 20)
72 = 2^3 x 3^2
73 = 73 (prime 21)
74 = 2 x 37
75 = 3 x 5^2
76 = 2^2 x 19
77 = 7 x 11
78 = 2 x 3 x 13
79 = 79 (prime 22)
80 = 2^4 x 5
81 = 3^4
82 = 2 x 41
83 = 83 (prime 23)
84 = 2^2 x 3 x 7
85 = 5 x 17
86 = 2 x 43
87 = 3 x 29
88 = 2^3 x 11
89 = 89 (prime 24)
90 = 2 x 3^2 x 5
91 = 7 x 13
92 = 2^2 x 23
93 = 3 x 31
94 = 2 x 47
95 = 5 x 19
96 = 2^5 x 3
97 = 97 (prime 25)
98 = 2 x 7^2
99 = 3^2 x 11
100 = 2^2 x 5^2



!Gcrk ' \*\* prime sequence = ' ';'
!Gcrk 'prime ' ''
!Gcrk ' ([x=(]|prime|\*\*) ?' '$1'

# Prime Factors 2-99999
2=2(1);1
3=3(2)
4=2^2
5=5(3)
6=2x3;2
7=7(4)
8=2^3
9=3^2
10=2x5
11=11(5)
12=2^2x3
13=13(6)
14=2x7
15=3x5
16=2^4
17=17(7)
18=2x3^2
19=19(8)
20=2^2x5
21=3x7
22=2x11
23=23(9)
24=2^3x3
25=5^2
26=2x13
27=3^3
28=2^2x7
29=29(10)
30=2x3x5;3
31=31(11)
32=2^5
33=3x11
34=2x17
35=5x7
36=2^2x3^2
37=37(12)
38=2x19
39=3x13
40=2^3x5
41=41(13)
42=2x3x7
43=43(14)
44=2^2x11
45=3^2x5
46=2x23
47=47(15)
48=2^4x3
49=7^2
50=2x5^2
51=3x17
52=2^2x13
53=53(16)
54=2x3^3
55=5x11
56=2^3x7
57=3x19
58=2x29
59=59(17)
60=2^2x3x5
61=61(18)
62=2x31
63=3^2x7
64=2^6
65=5x13
66=2x3x11
67=67(19)
68=2^2x17
69=3x23
70=2x5x7
71=71(20)
72=2^3x3^2
73=73(21)
74=2x37
75=3x5^2
76=2^2x19
77=7x11
78=2x3x13
79=79(22)
80=2^4x5
81=3^4
82=2x41
83=83(23)
84=2^2x3x7
85=5x17
86=2x43
87=3x29
88=2^3x11
89=89(24)
90=2x3^2x5
91=7x13
92=2^2x23
93=3x31
94=2x47
95=5x19
96=2^5x3
97=97(25)
98=2x7^2

Numbers:

Number_ID:     		Int;
Number:        		Int;
Prime:			Int;
Prime_Sequence:		Int;
Sqaure:			Boolean;
Cube:			Boolean;

Prime_Factors:
PF_ID:			Int;
Number:			Int;
Prime_Factor:		FK to Numbers;
Exponent:		Int;
