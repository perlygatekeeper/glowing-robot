#!/opt/local/bin/python
# Python program to find sum_of_squares - square_of_sums_difference of numbers from 1 to 100
  
import sys 
import math 
import timeit
import time

def brute_force(n=100):
    sum_of_squares = 0
    the_sum        = 0
    for i in range(1,n+1):
#       print (" ", i, flush=True)
        sum_of_squares += i * i
        the_sum += i
    print("\nThe difference of the sum_of_squares from the square_of_sums for the numbers 1 .. %d is %d" % ( n, the_sum * the_sum - sum_of_squares) )



def fancy(n=100):
    half_sum = 0
    for i in range(1, n):
        for j in range(i+1, n+1):
#           print (" (%d,%d)" % (i,j), flush=True)
            half_sum += i*j
    print("\nThe difference of the sum_of_squares from the square_of_sums for the numbers 1 .. %d is %d" % ( n, 2 * half_sum  ) )


n = 1000
start_time = timeit.default_timer()
brute_force(n)
print("The brute force method took %f seconds" % ( timeit.default_timer() - start_time ))
fancy(n)
print("Where the fancy method took %f seconds" % ( timeit.default_timer() - start_time ))

