#!/opt/local/bin/python
# Python program to find largest common multiple
  
import sys 
import math 
import timeit
import time

def find_longest_collatz_sequence(limit=1000000):
    sequence = {}
    lengths = {}
    longest_sequence_length = 0
    for start in range(1, limit):
        sequence[start] = []
        sequence[start].append(start)
        lengths[start] = 1
        next = start
        while next != 1:
            if next & 1 == 1:
                next = 3 * next + 1
            else:
                next = int(next / 2)
            if next in sequence:
                sequence[start].append(sequence[next])
                lengths[start] += lengths[next]
                break
            else:
                sequence[start].append(next)
                lengths[start] += 1
        if lengths[start] > longest_sequence_length:
            longest_sequence_length = lengths[start]
            longest_sequence_start = start
        print(" %7d - %d" % ( start, lengths[start] ) )
    longest_collatz_sequence = max(lengths)
#   for i in sequence.keys():
#       print(i)
    return ( longest_sequence_start, longest_sequence_length, sequence[longest_sequence_start] )

start_time = timeit.default_timer()

limit = 100
limit = 1000000
( longest_sequence_start, longest_sequence_length, longest_sequence ) = find_longest_collatz_sequence(limit)

print ("Longest Collatz sequence below %d starts with %d and is %d long."
% ( limit, longest_sequence_start, longest_sequence_length ) )
print( timeit.default_timer() - start_time )
