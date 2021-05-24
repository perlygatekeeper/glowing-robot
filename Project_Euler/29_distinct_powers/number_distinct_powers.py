#!/opt/local/bin/python
# Python program to find number of distinct powers a^b for a and b from 2 to 100

import sys 
import math 
import timeit
import time

start_time = timeit.default_timer()
sum = 1
a_limit = 5
b_limit = 5
a_limit = 100
b_limit = 100

powers = {}

for a in range(2,a_limit+1):
    for b in range(2,b_limit+1):
        powers[a**b] = True

number_of_distinct_powers = len(powers)

print("\nFound sum to be %d and this took %f seconds to find."
% ( number_of_distinct_powers, ( timeit.default_timer() - start_time ) ) )

