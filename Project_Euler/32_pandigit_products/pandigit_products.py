#!/opt/local/bin/python
# Program to find all pandigit products

import timeit
import time
import sys
import math

start_time = timeit.default_timer()
pandigit_products = {}

def count_digits(*numbers):
    # return dictionary of count of all digits in all arguemnts
    # if arguments were 11, 7, 9833
    # ( 1: 2, 3: 2, 7: 1, 9: 1 )
    digits = {}
    for number in numbers:
        for digit in str(number):
            if digit == '0':
                continue
            digits[digit] = True
    return digits


# 1-digit * 4-digit leading to 4-digit
#    2 -    9 =>    8 1-digit numbers  
# 1234 - 9876 => 8643 4-digit numbers

for multiplicand in range( 2, 9 + 1 ):
    for multiplier in range( 1234, 9876 + 1):
        product = multiplicand * multiplier
        if product > 9999:
            break
        digits = count_digits( multiplicand, multiplier, product )
        if len(digits) == 9:
            print ( " %d X %d = %d" % ( multiplicand, multiplier, product ) )
            pandigit_products[product] = True

# 2-digit * 3-digit leading to 4-digit
#   12 -  98 =>   87  2-digit numbers
#  123 - 987 =>  865  3-digit numbers

for multiplicand in range( 12, 98 + 1 ):
    for multiplier in range( 123, 987 + 1):
        product = multiplicand * multiplier
        if product > 9999:
            break
        digits = count_digits( multiplicand, multiplier, product )
        if len(digits) == 9:
            print ( " %d X %d = %d" % ( multiplicand, multiplier, product ) )
            pandigit_products[product] = True

sum = 0
for product in pandigit_products.keys():
    sum += product

print("\nFound %d pandigit products with a sum of %d and this took %f seconds to find."
% ( len(pandigit_products), sum, ( timeit.default_timer() - start_time ) ) )
