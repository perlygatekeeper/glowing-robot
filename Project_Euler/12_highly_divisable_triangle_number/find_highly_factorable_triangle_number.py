#!/opt/local/bin/python
# Python program to find first triangle number with 500 factors

import sys 
import math 
import timeit
import time

start_time = timeit.default_timer()

record = (grid)

print("Found product %d starting at (%d,%d) and moving %s, which took %f seconds"
        % ( record["product"], record["row"]+1, record["column"]+1, record["direction"], ( timeit.default_timer() - start_time ) ) )
