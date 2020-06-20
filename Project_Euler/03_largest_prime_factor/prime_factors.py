#!/opt/local/bin/python
# Python program to print prime factors 
  
import sys 
import math 
import timeit
import time

# A function to print all prime factors of  
# a given number n 
def primeFactors(n): 
      
    factors = []
    # Print the number of two's that divide n 
    while n & 1 == 0: 
        factors.append(2)
        print(2), 
        n = int(n / 2)
          
    # n must be odd at this point 
    # so a skip of 2 ( i = i + 2) can be used 
    for i in range(3,int(math.sqrt(n))+1,2): 
          
        # while i divides n , print i ad divide n 
        while n % i == 0: 
            factors.append(i)
            print(i), 
            n = n / i 
              
    # Condition if n is a prime 
    # number greater than 2 
    if n > 2: 
        factors.append(n)
        print(n)
    return(factors)


if len(sys.argv) == 2:
  target    = int(sys.argv[1])
else: 
  target    = 4620
  target    = 600851475143

start_time = timeit.default_timer()
primeFactors(target)
print( timeit.default_timer() - start_time )

# print("We found %d primes factors in %d" % (prime_factors, target))
# print("In %f seconds." % ( timeit.default_timer() - start_time) )

#-----


