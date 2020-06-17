#!/opt/local/bin/python
# Program to find the 10001st prime number.

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

# def sieveOfSundaram(n=1000):
#     # this version prints primes <= n
#     k = int(( n - 2 ) / 2 )
#     a = [0] * ( k + 1 )
#     for i in range( 1, k + 1):
#         j = i
#         while(( i + j + 2 * i * j ) <= k):
#             a[ i + j + 2 * i * j ] = 1
#             j+=1
#     if n > 2:
#         print(2,' ',end='')
#     for i in range(1, k + 1):
#         if a[i] == 0:
#             print((2 * i +1),' ',end='')

print(f"Finding 10001th prime")
start_time = timeit.default_timer()
primes = sieveOfSundaram(130000)
print( primes[10000] ) # primes list indexed starting with 0
print(timeit.default_timer() - start_time)
