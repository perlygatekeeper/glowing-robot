#!/opt/local/bin/python
# Python program to find first triangle number with 500 factors

import sys 
import math 
import timeit
import time

def sieveOfSundaram(n=20):
    # this version returns a dictionary for quick lookup and
    # therefore verification if some number in range is a prime or composite
    k = int(( n - 2 ) / 2 )
    a = [0] * ( k + 1 )
#   primes = {}
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
#       primes[2] = sequence
        primes.append(2)
    for i in range(1, k + 1):
        if a[i] == 0:
            sequence += 1 
#           primes[2+i+1] = sequence
            primes.append( (2*i + 1 ))
    return primes


# A function to print all prime factors of  
# a given number n 
def primeFactors(n): 
    factors = {}
    # return dictionary with prime factors as and that prime factors powers as values
    while n & 1 == 0: 
        if 2 in factors:
            factors[2] += 1
        else:
            factors[2]  = 1
        n = int(n / 2)
    # n must be odd at this point 
    # so a skip of 2 ( i = i + 2) can be used 
    for i in range(3,int(math.sqrt(n))+1,2): 
        # while i divides n , print i ad divide n 
        while n % i == 0: 
            if i in factors:
                factors[i] += 1
            else:
                factors[i] =  1
            n = int(n / i) 
    # Condition if n is a prime 
    # number greater than 2 
    if n > 2: 
        factors[n] = 1
    return(factors)


def findTriangleNumberWithOver500Factors(limit=1000): 
    solution = {}
    for n in range(1,limit):
        triangle = int( n * ( n + 1 ) / 2 )
        prime_factors = primeFactors(triangle)
        number_of_factors = 0
        for prime_factor in prime_factors:
            number_of_factors += ( prime_factors[prime_factor] + 1 ) 
        print("%9d - %9d: %3d" % ( n, triangle, number_of_factors ) )
        if number_of_factors > 500:
            solution["n"] = n
            solution["prime_factors"] = prime_factors
            solution["triangle"] = triangle
            solution["number_of_factors"] = number_of_factors
            return(solution)
    return(None)


start_time = timeit.default_timer()

limit = 100000
solution = findTriangleNumberWithOver500Factors(limit)

if bool(solution):
    print("The %d-th triangle number is %d and has %d factors, the search for which took %f seconds."
            % ( solution["n"], solution["triangle"], solution["number_of_factors"], ( timeit.default_timer() - start_time ) ) )
    print("%d's prime factors are:" % (solution["triangle"]) )
    for prime in solution["prime_factors"]:
        print("%d^%d " % ( prime, solution["prime_factors"][prime] ) )
else:
    print("No triangle number with more than 500 factors within the first %d, this search took %f seconds."
            % ( limit, ( timeit.default_timer() - start_time ) ) )



