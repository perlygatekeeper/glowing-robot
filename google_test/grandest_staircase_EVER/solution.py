def solution(n):
    # generate triangle numbers from 1 to 19
    triangle_numbers = [0]
    triangle_indices = [0]
    for i in range(1,20):
           triangle_numbers.append(int( i * (i+1) / 2 ))
    number = 0
    for i in range(0,201):
        if i in triangle_numbers:
            number += 1
        triangle_indices.append(number)
#   triangle numbers and indices done.
    staircases = {}
    for N in range(3,n+1):
        staircases[N] = {}
        smallest_stairway_height = triangle_indices[N]
        for stairway_height in range(smallest_stairway_height,N):
            # m is # of bricks left to build rest of stairway
            m = N - stairway_height
            if stairway_height > smallest_stairway_height:
                staircases[N][stairway_height] = staircases[N][stairway_height-1]
            else:
                staircases[N][stairway_height] = 0
            if m < stairway_height:
                staircases[N][stairway_height] += 1
                if m in staircases:
                    staircases[N][stairway_height] += staircases[m][m-1]
            else:
                staircases[N][stairway_height] += staircases[m][stairway_height-1]
    return staircases[n][n-1]
n = 200
print("%3d: %7d" % (n, solution(n)) )
