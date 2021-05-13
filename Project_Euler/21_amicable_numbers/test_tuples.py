#!/opt/local/bin/python
# Python program to find first triangle number with 500 factors

import sys 
import math 
import timeit
import time
import itertools

tuple_2 = tuple(map(lambda x: pow(2,x), range(4)))
for factor in tuple_2:
    print (factor)
tuple_3 = tuple(map(lambda x: pow(3,x), range(3)))
for factor in tuple_3:
    print (factor)
tuple_5 = tuple(map(lambda x: pow(5,x), range(2)))
for factor in tuple_5:
    print (factor)

print(tuple_2)
print(tuple_3)
print(tuple_5)
