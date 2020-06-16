#!/opt/local/bin/python
# Python program to find largest palidrome product
  
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

def findLowestCommonMultiple(primes,values):
    # loop through values
    lcm = 1
    lcm_factors = {}
    for value in values:
        factors_of = primeFactors(value)
        for factor in factors_of:
            if factor in lcm_factors:
                lcm_factors[factor] = max( lcm_factors[factor], factors_of[factor])
            else:
                lcm_factors[factor] = factors_of[factor]
    for factor in lcm_factors:
        print("adding multiple (%d ^ %d)" % (factor, lcm_factors[factor]) )
        lcm *= pow(factor, lcm_factors[factor])
    return lcm


start_time = timeit.default_timer()
primes = sieveOfSundaram(20)
# print("Finding primes up to %d" % 20 )
# print( timeit.default_timer() - start_time )

values = []
for i in range(2, 20):
    values.append(i)
lowest = findLowestCommonMultiple(primes,values)
print ("Found lowest common multiple of numbers 1 .. 20 is %d" % ( lowest) )

print( timeit.default_timer() - start_time )
