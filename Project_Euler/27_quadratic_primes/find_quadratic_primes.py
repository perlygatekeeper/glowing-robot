#!/opt/local/bin/python
# Python program to find first triangle number with 500 factors

import sys 
import math 
import timeit
import time

def sieveOfSundaram(n=1000):
    # this version returns a dictionary for quick lookup of primes <= n
    # this version returns a list for easy identification of nth prime
    k = int(( n - 2 ) / 2 )
    a = [0] * ( k + 1 )
    primes = []
    for i in range( 1, k + 1):
        if i%1000000 == 0:
            print("one million processed")
        j = i
        while(( i + j + 2 * i * j ) <= k):
            a[ i + j + 2 * i * j ] = 1
            j+=1
    sequence = 0 
    if n > 2:
        primes.append(2)
    for i in range(1, k + 1):
        if a[i] == 0:
            sequence += 1 
            primes.append( (2*i + 1 ))
    return primes


def test_quadratic_for_primes(a,b,primes):
    quadratic_primes = {}
    n = 0
    prime = b  # n^2 + a*n + b = b if n=0
    quadratic_primes.update( { 0: b } )
    while prime in primes:
        n += 1
        prime = int(n*n + a*n + b)
        if prime in primes:
            quadratic_primes.update( { n: prime } )
# n^2 +  1n +   41    0 ≤ n ≤ 39   a =   1  &  b =   41
# n^2 + -79n + 1601   0 ≤ n ≤ 79   a = -79  &  b = 1601
    if ( ( a == 1 and b == 41 ) or  ( a == -79 and b == 1601 ) ):
        print("(%5d,%5d): %d" % (a, b, len(quadratic_primes)))
    return ( quadratic_primes )


def find_best_quadratic(primes):
# whne n = 0  ->  n^2 + a*n + b = b           therefore b must be a positive prime number.
# when n = 1  ->  n^2 + a*n + b = 1 + a + b   since when (a + b) must be even
    record_primes = []
    primes_less_than_1000 = sieveOfSundaram(1000)
    b = 2
    for a in range(-1000,1001,2):      # b is even so a must be even for (a+b) to be even
        quadratic_primes = test_quadratic_for_primes(a,b,primes)
        if len(quadratic_primes) > len(record_primes):
            record_primes = quadratic_primes.copy()
            record_a = a
            record_b = b
            print("(%5d,%5d): %d" % (a, b, len(quadratic_primes)))
    for b in primes_less_than_1000:    # there are 167 such primes where 2 < P < 1000
        for a in range(-999,1000,2):   # b is  odd so a must be  odd for (a+b) to be even
            quadratic_primes = test_quadratic_for_primes(a,b,primes)
            if len(quadratic_primes) > len(record_primes):
                record_a = a
                record_b = b
                record_primes = quadratic_primes.copy()
                print("(%5d,%5d): %d" % (a, b, len(quadratic_primes)))
    return ( record_a, record_b, record_primes )


start_time = timeit.default_timer()
limit = 100000
primes = sieveOfSundaram(limit)
(a, b, those_primes) = find_best_quadratic(primes)

print("\nFound best quadratic prime number generator with a = %d and b = %d generated %d primes and whose sum to %d and this took %f seconds to find."
% ( a, b, len(those_primes), a+b, ( timeit.default_timer() - start_time ) ) )

for n in sorted(those_primes):
    print ("%4d - %5d" % (n, those_primes[n]) )
