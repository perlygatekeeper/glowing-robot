#!/opt/local/bin/python
# Python program to find largest common multiple
  
import sys 
import math 
import timeit
import time

def find_lattice_paths(grid_size=2):
    grid = [] * grid_size
    for row in range(grid_size):
        this_row = []
        for col in range(grid_size):
            this_row.append(0)
        grid.append(this_row)

#   print(type(grid))
#   print(type(grid[0]))
#   print(type(grid[0][0]))
    i = 0
    for row in range(len(grid)-1, -1, -1):
#       print(row)
        for col in range(len(grid[row])-1, -1, -1):
#           print(f" {col}")
            if (col+1) < grid_size:
                grid[row][col] += grid[row][col+1]
            if (row+1) < grid_size:
                grid[row][col] += grid[row+1][col]
            if grid[row][col] == 0:
                 grid[row][col] = 1
#           print(f"Grid[{row}][{col}] is now {grid[row][col]}")
    for row in range(len(grid)):
        for col in range(len(grid)):
            if grid[row][col] > 9999999:
                print(" %7.1e" % (grid[row][col]), end="")
            else:
                print(" %7d" % (grid[row][col]), end="")
#           print("row:%d col:%d -> %6d" % (row, col, grid[row][col]))
        print("")
    print("")
    return (grid[0][0])

start_time = timeit.default_timer()

grid = 4
grid = 20
number_of_paths = find_lattice_paths(grid)

print ("Number of paths from top left, to bottom right is %d and took %f seconds."
% ( number_of_paths, ( timeit.default_timer() - start_time ) ) )
