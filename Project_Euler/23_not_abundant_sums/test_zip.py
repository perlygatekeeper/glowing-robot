#!/opt/local/bin/python
# Python program to find sum of all non-abundant numbers

import sys 
import math 
import timeit
import time


# a = dict( zip( [ range(1,11) ], False * 10 ) ) 
my_dict = { i: False for i in range(21) }

for key in my_dict:
    print(key, my_dict[key])

