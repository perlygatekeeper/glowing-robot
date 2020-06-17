#!/opt/local/bin/python

import timeit
import time
import sys

def sieveOfSundaram(n=1000):
    # this version returns a dictionary for quick lookup of primes <= n
    # this version returns a list for easy identification of nth prime
    k = int(( n - 2 ) / 2 )
    a = [0] * ( k + 1 )
#   primes = {}
    primes = []
    the_sum = 0
    for i in range( 1, k + 1):
#       if i%1000000 == 0:
#           print("one million processed")
        j = i
        while(( i + j + 2 * i * j ) <= k):
            a[ i + j + 2 * i * j ] = 1
            j+=1
    sequence = 0 
    if n > 2:
#       primes[2] = sequence
        primes.append(2)
        the_sum += 2
    for i in range(1, k + 1):
        if a[i] == 0:
            sequence += 1 
#           primes[2+i+1] = sequence
            primes.append( (2*i + 1 ))
            the_sum += (2*i + 1)
    return ( the_sum, primes )


limit = 2000000
print("Finding sum of primes below %d" % (limit))
start_time = timeit.default_timer()
(the_sum, primes) = sieveOfSundaram(limit)
print("the sum is %d" % ( the_sum ) ) # primes list indexed starting with 0
print(timeit.default_timer() - start_time)
