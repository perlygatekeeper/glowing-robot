#!/opt/local/bin/python
# Python program to find first triangle number with 500 factors

import sys 
import math 
import timeit
import time


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

# We will also need a function that will multiply the two factors by adding the two "prime-vectors",
# and calculate the products total_number_of_factors.
def PFN_product(first, second): 
    product = {}  
    product["prime_factors"] = first.copy()
    for second_prime_factor in second:
        if second_prime_factor in product:
            product["prime_factors"][second_prime_factor] += second[second_prime_factor]
        else:
            product["prime_factors"][second_prime_factor]  = second[second_prime_factor]
    product["number_of_factors"] = 1
    for prime_factor in product["prime_factors"]:
        product["number_of_factors"] *= ( product["prime_factors"][prime_factor] + 1 ) 
    return( product )

 
def findTriangleNumberWithOver500Factors(limit,target_factors): 
    solution = {}
##    dots = 0
# INITIALIZE:
    smaller = 0
    larger  = 1
    RPN_larger = primeFactorization(larger)
# LOOP:
    while smaller <= limit:
        smaller += 1
##        if smaller%1000 == 0:
##            print(".",end="");
##            dots += 1
##            if dots%100 == 0:
##                print("")
        RPN_smaller = primeFactorization(smaller)
        product = PFN_product(RPN_smaller, RPN_larger)
        print("%6d: %6d - %6d - %3d" % ( larger, smaller, larger, product["number_of_factors"]) )
        if product["number_of_factors"] > target_factors:
            product["n"]        = smaller
            product["triangle"] = smaller * larger
            product["smaller"]  = smaller
            product["larger"]   = larger
            return(product)
        larger += 2
        RPN_larger = primeFactorization(larger)
        product = PFN_product(RPN_smaller, RPN_larger)
        print("%6d: %6d - %6d - %3d" % ( smaller*2, smaller, larger, product["number_of_factors"]) )
        if product["number_of_factors"] > target_factors:
            product["n"]        = larger - 1
            product["triangle"] = smaller * larger
            product["smaller"]  = smaller
            product["larger"]   = larger
            return(product)
    return(None)


start_time = timeit.default_timer()

limit = 1000000  # one million
target_factors = 500
solution = findTriangleNumberWithOver500Factors(limit,target_factors)

if bool(solution):
    print("The %d-th triangle number is %d is a product of %d and %d"
            % ( solution["n"], solution["triangle"], solution["smaller"], solution["larger"] ) )
    print("and has %d factors, the search for which took %f seconds."
            % ( solution["number_of_factors"], ( timeit.default_timer() - start_time ) ) )
    print("%d's prime factors are:" % (solution["triangle"]) )
    for prime in sorted(solution["prime_factors"].keys(), key=lambda item: int(item)):
        print("%d^%d " % ( prime, solution["prime_factors"][prime] ) )
else:
    print("No triangle number with more than 500 factors within the first %d, this search took %f seconds."
            % ( limit, ( timeit.default_timer() - start_time ) ) )



