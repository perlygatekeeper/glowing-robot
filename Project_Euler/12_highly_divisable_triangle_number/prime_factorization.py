#!/opt/local/bin/python
# Python program to find first triangle number with 500 factors

import sys 
import math 
import timeit
import time

def sieveOfSundaram(n=80):
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
    if n > 2:
        primes.append(2)
    for i in range(1, k + 1):
        if a[i] == 0:
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


def printPrimeFactorizations(primes, limit=1000000): 
    solution = {}
    for n in range(1,limit):
        prime_factors = primeFactors(n)
        number_of_factors = 0
        for prime_factor in prime_factors:
            number_of_factors += ( prime_factors[prime_factor] + 1 ) 
        print("%9d-%2d:" % ( n, number_of_factors ), end="" )
        for prime in primes:
            if prime in prime_factors:
                print(" %2d" % (prime_factors[prime] ), end="")
            else:
                print("  0", end="")
        print(" ")

              


start_time = timeit.default_timer()

limit = 100000000 # hundred million
primes = sieveOfSundaram(230)
print( len(primes) )
for prime in primes:
    print(" %2d" % (prime), end="")
print(" ")
solution = printPrimeFactorizations(primes,limit)
print("Printing out the first %d primefactorizations took %f seconds."
% ( limit, ( timeit.default_timer() - start_time ) ) )

# if bool(solution):
#     print("The %d-th triangle number is %d and has %d factors, the search for which took %f seconds."
#             % ( solution["n"], solution["triangle"], solution["number_of_factors"], ( timeit.default_timer() - start_time ) ) )
#     print("%d's prime factors are:" % (solution["triangle"]) )
#     for prime in solution["prime_factors"]:
#         print("%d^%d " % ( prime, solution["prime_factors"][prime] ) )
# else:
#     print("No triangle number with more than 500 factors within the first %d, this search took %f seconds."
#             % ( limit, ( timeit.default_timer() - start_time ) ) )



