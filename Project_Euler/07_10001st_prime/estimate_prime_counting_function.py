#!/opt/local/bin/python
# Program to estimate the prime counting function with x/ln(x)

import timeit
import time
import math
import sys


def binarySearch(lower,upper):
    target = 10001
    midpoint = ( lower + upper )/2
    counter = 0
    while (upper-lower) > 0.01 and counter < 50:
        midpoint = ( lower + upper )/2
        counter += 1
        f_of_midpoint = midpoint/math.log(midpoint)
        if f_of_midpoint > target:
            print("%2d: lower: %9.1f, UPPER: %9.1f, midpoint: %9.1f - %f" % ( counter, lower, upper, midpoint, f_of_midpoint ))
            upper = midpoint
        elif f_of_midpoint < target:
            print("%2d: LOWER: %9.1f, upper: %9.1f, midpoint: %9.1f - %f" % ( counter, lower, upper, midpoint, f_of_midpoint ))
            lower = midpoint
        else:
            break
    return(midpoint)

start_time = timeit.default_timer()

lower_estimate = 100
upper_estimate = 1000000
binarySearch(lower_estimate,upper_estimate)

print(timeit.default_timer() - start_time)
