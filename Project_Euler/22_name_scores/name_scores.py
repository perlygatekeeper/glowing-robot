#!/opt/local/bin/python

import timeit
import time
import sys

def find_score(name):
    score = 0
    for character in name:
        score += ( ord(character) - 64 )
    return score

start_time = timeit.default_timer()

total = 0
cardinal_position = 0
import csv
with open('p022_names.txt', newline='') as csvfile:
    names_reader = csv.reader(csvfile, dialect='unix')
    for row in names_reader:
        for name in sorted(row):
            cardinal_position += 1
            name_score = find_score(name)
            total += cardinal_position * name_score
            print("%3d - %20s: %6d %7d" % ( cardinal_position, name, name_score, total) )

print( "Ran in %f seconds." % ( timeit.default_timer() - start_time) )
