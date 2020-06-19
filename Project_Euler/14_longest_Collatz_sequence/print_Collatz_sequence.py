#!/opt/local/bin/python
# Python program to find largest common multiple
  
import sys 
import math 
import timeit
import time

def collatz_sequence(start):
    next = start
    print(next, end="")
    while next != 1:
        if next & 1 == 1:
            print(" is odd so (3n+1) ->")
            next = 3 * next + 1
        else:
            print(" is even so (n/2) ->")
            next = int(next / 2)
        print(next, end="")
    print("")

start = 99
if len(sys.argv) == 2:
    start = sys.argv[1]

collatz_sequence(start)
