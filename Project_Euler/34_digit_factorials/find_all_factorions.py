#!/opt/local/bin/python
# Program to find all Factorions in Base 10

import timeit
import time
import sys
import math

start_time = timeit.default_timer()

sum = 0

factorials = {}
factorials['0'] =      1
factorials['1'] =      1
factorials['2'] =      2
factorials['3'] =      6
factorials['4'] =     24
factorials['5'] =    120
factorials['6'] =    720
factorials['7'] =   5040
factorials['8'] =  40320
factorials['9'] = 362880

def sum_of_digits_factorials(number):
    sum_of_digit_factorials = 0
    for digit in str(number):
        sum_of_digit_factorials += factorials[digit]
    # print("%9d: %9d" % ( number, sum_of_digit_factorials ) )
    return sum_of_digit_factorials


for number in range(10,3000000):
    if sum_of_digits_factorials(number) == number:
        print('%7d' % number)
        sum += number

print("\nFound sum of all factorions is %d and this took %f seconds to find."
% ( sum, ( timeit.default_timer() - start_time ) ) )
