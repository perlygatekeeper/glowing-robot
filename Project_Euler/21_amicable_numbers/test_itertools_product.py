#!/opt/local/bin/python
# Python program to find first triangle number with 500 factors

import sys 
import math 
import timeit
import time
import itertools

def my_iter_product(iterable, repeat=1):
    # product('ABCD', 'xy') --> Ax Ay Bx By Cx Cy Dx Dy
    # product(range(2), repeat=3) --> 000 001 010 011 100 101 110 111
    pools = [tuple(pool) for pool in iterable] * repeat
    result = [[]]
    for pool in pools:
        result = [x+[y] for x in result for y in pool]
    for prod in result:
        yield tuple(prod)

factors = [ 2, 3, 5 ]
exp = {}
exp[2] = ( 1, 2, 4, 8 )
exp[3] = ( 1, 3, 9 )
exp[5] = ( 1, 5 )

# for exponents in itertools.product(exp):
print(type(itertools.product( ( 1, 2, 4, 8 ), ( 1, 3, 9 ), ( 1, 5 ) )))
# for exponents in my_iter_product( ( ( 1, 2, 4, 8 ), ( 1, 3, 9 ), ( 1, 5 ) ) ): # works
for factors in my_iter_product( [ [ 1, 2, 4, 8 ], [ 1, 3, 9 ], [ 1, 5 ] ] ):
    print(factors, end="")
    product = 1
    for factor in factors:
        product *= factor
#   for exponent, factor in zip(exponents, factors):
#       print(f"{factor:4d} * {exponent:4d} ")
#       product *= pow(factor,exponent)
    print(f"{product:4d}")

       

# without knowing the number of tuples I wish to pass how do I do this?

# for exponents in itertools.product( exp[2],  exp[3],  exp[5] ): # works
# for exponents in itertools.product( exp.values() ): # doesn't work
# exponents_3_5 = itertools.product( exp[3], exp[5] )
# for exponents in itertools.product( exp[2], exponents_3_5 ): # works

# for exponents in itertools.product(   ( 1, 2, 4, 8 ), ( 1, 3, 9 ), ( 1, 5 )   ):  # works
#      print(tuple(itertools.chain(exponents)))

'''
(1, 1, 1)
(1, 1, 5)
(1, 3, 1)
(1, 3, 5)
(1, 9, 1)
(1, 9, 5)
(2, 1, 1)
(2, 1, 5)
(2, 3, 1)
(2, 3, 5)
(2, 9, 1)
(2, 9, 5)
(4, 1, 1)
(4, 1, 5)
(4, 3, 1)
(4, 3, 5)
(4, 9, 1)
(4, 9, 5)
(8, 1, 1)
(8, 1, 5)
(8, 3, 1)
(8, 3, 5)
(8, 9, 1)
'''
