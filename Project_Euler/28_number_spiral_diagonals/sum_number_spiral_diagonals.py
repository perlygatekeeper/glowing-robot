#!/opt/local/bin/python
# Python program to find sum of number spiral diagonals

import sys 
import math 
import timeit
import time

start_time = timeit.default_timer()
sum = 1
limit = 1    # 3 x 3
limit = 2    # 5 x 5
limit = 3    # 7 x 7
limit = 500  # 1001 x 1001

for N in range(1,limit+1):
    sum += 4 * ( 4 * N * N + N + 1 )

print("\nFound sum to be %d and this took %f seconds to find."
% ( sum, ( timeit.default_timer() - start_time ) ) )

