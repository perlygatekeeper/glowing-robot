#!/opt/local/bin/python
# Python program to find first triangle number with 500 factors

import sys 
import math 
import timeit
import time
# import itertools

def my_iter_product(iterable, repeat=1):
    # product('ABCD', 'xy') --> Ax Ay Bx By Cx Cy Dx Dy
    # product(range(2), repeat=3) --> 000 001 010 011 100 101 110 111
    pools = [tuple(pool) for pool in iterable] * repeat
    result = [[]]
    for pool in pools:
        result = [x+[y] for x in result for y in pool]
    for prod in result:
        yield tuple(prod)

# A function to print all prime factors of  
# a given number n and their exponents
def primeFactorization(n): 
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

# NOTE: PFN = Prime Factorized Number
# will give example for number = 360
def PFN_all_proper_divisors(number): 
    proper_factors = []
    prime_factors = primeFactorization(number)
    # prime_factors 2:3, 3:2, 5:1
    possible_products = []
    for prime_factor in prime_factors.keys():
        factors = []
        for exponent in range(prime_factors[prime_factor]+1):
            # prime_factor is 2
            # factors = [ 2^0, 2^1, 2^2, 2^3 ] == [ 1, 2, 4, 8 ]
            # prime_factor is 3
            # factors = [ 3^0, 3^1, 3^2 ] == [ 1, 3, 9 ]
            # prime_factor is 5
            # factors = [ 5^0, 5^1 ] == [ 1, 5 ]
            factors.append(int(math.pow(prime_factor,exponent)))
        # possible_products = [ [ 1, 2, 4, 8 ], [ 1, 3, 9 ], [ 1, 5 ] ]
        possible_products.append(factors)
    for factors in my_iter_product(possible_products):
        product = 1
        for factor in factors:
            product *= factor
        if (product != number):
            proper_factors.append(product)
#   print(f"{number:6d}: ", end="")
#   print( sorted(proper_factors, key=int) )
    return( proper_factors )

def sum_of_proper_divisors(number):
    proper_divisors = PFN_all_proper_divisors(number)
    return sum(proper_divisors)

def find_all_amicable_numbers(n):
    amicables = []
    d = {}
    for i in range(1,n+1):
#       print(f"Calling sum_of_proper_divisors for {i}") 
        d[i] = sum_of_proper_divisors(i)
        print(f"{i:6d}: {d[i]:6d}")
    for i in range(2,n+1):
        if d[i] <= n and d[i] != i and d[d[i]] == i:
            amicables.append(i)
    return amicables

start_time = timeit.default_timer()

limit = 300  
limit = 10000  # ten thousand
amicables = find_all_amicable_numbers(limit)

sum_of_amicables = 0

for amicable in amicables:
    sum_of_amicables += amicable

print("The number of amicable numbers below %d is %d which sum to %d and this took %f seconds to find."
% ( limit, len(amicables), sum_of_amicables, ( timeit.default_timer() - start_time ) ) )

for amicable in amicables:
    print (amicable)


