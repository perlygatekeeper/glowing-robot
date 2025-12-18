#!/bin/tcsh

setenv ECPP /usr/local/bin/ecpp

echo $ECPP

$ECPP -f 25k_digit_probable_prime \
      -n `cat  25K_digit_probable_primes.txt` \
      -v -g

#  The argument
# ‘-p’ causes printing of the certificate on screen,
# ‘-v’ enables printing of progress information, and
# ‘-g’ enables even more #  verbose debug output.

#  $ ecpp -n 'nextprime(10^31)' -p
#
#  c = [[10000000000000000000000000000033, -5882759018432034, 12103604, 25,
#  [3876868516114165308082393519623, 7268598020338906447634857503614]],
#  [826200196239071096737717, 667597927066, 916, 0,
#  [376111257001838975439341, 115218092585553575608847]],
#  [901965279736248361147, 54401389280, 118118316, 0,
#  [282628664937444390372, 352399418333719760852]]];

#     Alternatively, the argument ‘-c’ checks the validity of the computed 
#  certificate; to see the result, the option ‘-v’ needs to be enabled.
#  
#     The argument
# ‘-f’ FILENAME stores the computed certificate in a file of the given name in PARI/GP format,
#   and additionally in the file  FILENAME‘.primo’ in Primo (*note Primo::)
#  format (for checking it with #  Primo, one needs to rename the file to FILENAME‘.out’).
#   Additionally, #  it enables checkpointing: During
# the first phase of ECPP (the downrun step determining cardinalities of elliptic curves leading to a primality proof),
#  the file FILENAME‘.cert1’ is written, during
#  the second ECPP phase of computing the elliptic curves by complex multiplication,
#  the file FILENAME‘.cert2’ is written.
#  Upon restart, the program picks up these files and continues where it has been interrupted.
#  After a successful run, these checkpointing files may be deleted.

#     Checkpointing is particularly useful with the MPI based parallel
#  version of the binary, called ‘ecpp-mpi’; this is created and installed
#  alongside the sequential ‘ecpp’ binary when the ‘--enable-mpi’ configure
#  option is given.

#     Thus in a suitably set up MPI environment,
#  $ mpirun ecpp-mpi -g -n '10^1000+453' -c -f cert-1000
#     computes and checks an ECPP certificate for the first prime with 1001
#  digits and stores it into the file ‘cert-1000’, while outputting debug
#  information on screen.

