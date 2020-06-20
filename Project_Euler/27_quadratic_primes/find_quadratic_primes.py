#!/opt/local/bin/python
# Python program to find first triangle number with 500 factors

import sys 
import math 
import timeit
import time

def test_quadratic_for_primes(a,b):
    prime = []
    return ( number_of_primes, primes )


def find_best_quadratic(a,b):
# whne n = 0  ->  n^2 + a*n + b = b           therefore b must be a positive prime number.
# when n = 1  ->  n^2 + a*n + b = 1 + a + b   since when (a + b) must be even
    b = 2
    for a in range(-1000,1001,2):      # b is even so a must be even for (a+b) to be even
        test_quadratic_for_primes(a,b)
    for b in primes_less_than_1000:    # there are 167 such primes where 2 < P < 1000
        for a in range(-999,1000,2):   # b is  odd so a must be  odd for (a+b) to be even
            test_quadratic_for_primes(a,b)
                      

start_time = timeit.default_timer()


print("The number of amicable numbers below %d is %d which sum to %d and this took %f seconds to find."
% ( limit, len(amicables), sum_of_amicables, ( timeit.default_timer() - start_time ) ) )

for prime in XXX:
    print (prime)


