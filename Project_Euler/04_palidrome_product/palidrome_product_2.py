#!/opt/local/bin/python
# Python program to find largest palidrome product
  
import sys 
import math 
import timeit
import time

def sieveOfSundaram(n=1000):
    # this version returns a dictionary for quick lookup and
    # therefore verification if some number in range is a prime or composite
    k = int(( n - 2 ) / 2 )
    a = [0] * ( k + 1 )
    primes = {}
    print("We made a list of %d zeros" % (k+1) )
    print("In %f seconds." % ( timeit.default_timer() - start_time) )
    for i in range( 1, k + 1):
        if i%1000000 == 0:
            print("one million processed")
        j = i
        while(( i + j + 2 * i * j ) <= k):
            a[ i + j + 2 * i * j ] = 1
            j+=1
    sequence = 0 
    if n > 2:
        primes[2] = sequence
#       primes.append(2)
    for i in range(1, k + 1):
        if a[i] == 0:
            sequence += 1 
            primes[2+i+1] = sequence
#           primes.append( (2*i + 1 ))
    return primes

# A function to print all prime factors of  
# a given number n 
def isPalidrome(n): 
    n_as_string = str(n)
    length = len( n_as_string )
    for i in range(0, int(length/2) ): # step though characters
        if n_as_string[i] != n_as_string[(-1 * i)-1]:
#           print ("digits %d and %d differ %s != %s." % (i, (-1*i)-1, n_as_string[i], n_as_string[(-1 * i)-1] ) )
            return(False)
    return(True)

# A function to print all prime factors of  
# a given number n 
def primeFactors(n): 
    factors = []
    # Print the number of two's that divide n 
    while n & 1 == 0: 
        factors.append(2)
#       print(2), 
        n = int(n / 2)
    # n must be odd at this point 
    # so a skip of 2 ( i = i + 2) can be used 
    for i in range(3,int(math.sqrt(n))+1,2): 
        # while i divides n , print i ad divide n 
        while n % i == 0: 
            factors.append(i)
#           print(i), 
            n = int(n / i) 
    # Condition if n is a prime 
    # number greater than 2 
    if n > 2: 
        factors.append(n)
#       print(n)
    return(factors)

def findLargestPalidrome(primes):
    # find composit numbers less than 998001
    factor = []
    found_it = False
    for i in range(998001, 10001, -1):
        if found_it:
            break
        if not isPalidrome(i):
            continue;
        print("--------------------------")
        print("%d is a palidrome canidate." % (i) )
        if i in primes:
            continue
        else:
            for possible_factor in range( math.ceil(math.sqrt(i)), 999):
                if ( i % possible_factor == 0 ):
                    print("Found it: %d = %d * %d" % ( i, possible_factor, i/possible_factor ))
                    found_it = True
                    
            


# print("testing the palidrome checker")
# for i in [ 10001, 100011, 123321, 900009, 123456 ]:
#     if isPalidrome(i):
#         print("%6d IS a Palidrome." % (i))
#     else:
#         print("%6d is NOT a Palidrome." % (i))

start_time = timeit.default_timer()
primes = sieveOfSundaram(999*999)
print("Finding primes up to %d" % (999*999) )
print( timeit.default_timer() - start_time )

# 100 * 100 =  10000 smallest candidate
# 999 * 999 = 998001 largest  candidate
findLargestPalidrome(primes)

print( timeit.default_timer() - start_time )
