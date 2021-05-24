#!/opt/local/bin/python
# Program to find all numbers which are equal to
# the sum of each of their digits raised to the fifth power
# and report the sum of all such numbers

import timeit
import time
import sys
import math

Powers = {}
sum_of_numbers = 0

for i in range(0,10):
  Powers[i] =  i ** 5

start_time = timeit.default_timer()

for d1 in range(0,10):
    n1 = d1 * 100000
    for d2 in range(0,10):
        n2 = d2 * 10000
        for d3 in range(0,10):
            n3 = d3 * 1000
            for d4 in range(0,10):
                n4 = d4 * 100
                for d5 in range(0,10):
                    n5 = d5 * 10
                    for d6 in range(0,10):
                       number = n1 + n2 + n3 + n4 + n5 + d6
                       if number == 1:
                           continue
                       powers_sum = Powers[d1] + Powers[d2] + Powers[d3] + Powers[d4] + Powers[d5] + Powers[d6]
                       if number == powers_sum:
                           print("Found one %d" % (number))
                           sum_of_numbers += number

print("\nFound sum to be %d and this took %f seconds to find."
% ( sum_of_numbers, ( timeit.default_timer() - start_time ) ) )

