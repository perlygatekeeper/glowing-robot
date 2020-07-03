import math

def solution(n):
    steps = int(math.ceil(math.log(n,2)))
    if n & 1 == 1:
        steps += 1
    if n > 1:
        if int(math.log(n+1,2)) == math.log(n+1,2):
            steps -= 1
        if int(math.log(n-1,2)) == math.log(n+1,2):
            steps -= 1
    return steps

solutions = [ 0, 0, 1, 2, 2, 3, 3, 4, 3, 4, 4, 5, 4, 5, 5, 5, 4, 5, 5, 6, 5, 6, 6, 6, 5, 6, 6, 7, 6, 7, 6, 6, 5, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
for i in range(1,41):
    s = solution(i)
    print("{0:4d}: {1:d} vs {2:d}   {3:d}".format(i, s, solutions[i], s - solutions[i] ))

# solution(4) returns 2: 4 -> 2 -> 1
# solution(15) returns 5: 15 -> 16 -> 8 -> 4 -> 2 -> 1
#            0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 24
# soltions = [ 0, 0, 1, 2, 2, 3, 3, 4, 3, 4, 4, 5, 4, 5, 5, 5, 4, 5, 5, 6, 5, 6, 6, 6, 5, 6, 6, 7, 6, 7, 6, 6, 5]
# solution( 0) returns 0
# solution( 1) returns 0
# solution( 2) returns 1: 2 -> 1
# solution( 3) returns 2: 3 -> 2 -> 1
# solution( 4) returns 2: 4 -> 2 -> 1
# solution( 5) returns 3: 5 -> 4 -> 2 -> 1
# solution( 6) returns 3: 6 -> 3 -> 2 -> 1
#                         6 -> 5 -> 4 -> 2 -> 1
#                         6 -> 7 -> 8 -> 4 -> 2 -> 1
# solution( 7) returns 4: 7 -> 6 -> 3 -> 2 -> 1
#                         7 -> 8 -> 4 -> 2 -> 1
# solution( 8) returns 3: 8 -> 4 -> 2 -> 1
# solution( 9) returns 4: 9 ->  8 -> 4 -> 2 -> 1
#                         9 -> 10 -> 5 -> 4 -> 2 -> 1
# solution(10) returns 4: 10 ->  5 -> 4 -> 2 -> 1
#                         10 ->  9 -> 8 -> 4 -> 2 -> 1
# solution(11) returns 5: 11 -> 10 -> 5 -> 4 -> 2 -> 1
#                         11 -> 12 -> 6 -> 3 -> 2 -> 1
# solution(12) returns 4: 12 ->  6 -> 3 -> 2 -> 1
# solution(13) returns 5: 13 -> 12 -> 6 -> 3 -> 2 -> 1
#                         13 -> 14 -> 7 -> 8 -> 4 -> 2 -> 1
#                         13 -> 14 -> 7 -> 6 -> 3 -> 2 -> 1
# solution(14) returns 5: 14 ->  7 -> 6 -> 3 -> 2 -> 1
#                         14 -> 15 -> 16 -> 8 -> 4 -> 2 -> 1
# solution(15) returns 5: 15 -> 16 -> 8 -> 4 -> 2 -> 1
#                         15 -> 14 -> 7 -> 6 -> 3 -> 2 -> 1
# solution(16) returns 4: 16 -> 8 -> 4 -> 2 -> 1
# solution(17) returns 5: 17 -> 16 -> 8 -> 4 -> 2 -> 1
# solution(18) returns 5: 18 -> 17 -> 16 -> 8 -> 4 -> 2 -> 1
#                         18 -> 9 -> 8 -> 4 -> 2 -> 1
# solution(19) returns 6: 19 -> 18 ->  9 -> 8 -> 4 -> 2 -> 1
#                         19 -> 20 -> 10 -> 5 -> 4 -> 2 -> 1
# solution(20) returns 5: 20 -> 10 -> 5 -> 4 -> 2 -> 1
# solution(21) returns 6: 21 -> 20 -> 10 -> 5 -> 4 -> 2 -> 1
#                         21 -> 22 -> 11 -> 10 -> 5 -> 4 -> 2 -> 1
# solution(22) returns 6: 22 -> 11 -> 10 -> 5 -> 4 -> 2 -> 1
# solution(23) returns 6: 23 -> 24 -> 12 ->  6 -> 3 -> 2 -> 1
#                         23 -> 22 -> 11 -> 10 -> 5 -> 4 -> 2 -> 1
# solution(24) returns 5: 24 -> 12 -> 6 -> 3 -> 2 -> 1
# solution(25) returns 6: 25 -> 24 -> 12 ->  6 -> 3 -> 2 -> 1
#                         25 -> 26 -> 13 -> 12 -> 6 -> 3 -> 2 -> 1
# solution(26) returns 6: 26 -> 13 -> 12 -> 6 -> 3 -> 2 -> 1
# solution(27) returns 7: 27 -> 26 -> 13 -> 12 -> 6 -> 3 -> 2 -> 1
#                         27 -> 28 -> 14 ->  7 -> 6 -> 3 -> 2 -> 1
# solution(28) returns 6: 28 -> 14 ->  7 ->  6 -> 3 -> 2 -> 1
# solution(29) returns 7: 29 -> 30 -> 15 -> 16 -> 8 -> 4 -> 2 -> 1
#                         29 -> 28 -> 14 ->  7 -> 6 -> 3 -> 2 -> 1
# solution(30) returns 6: 30 -> 15 -> 16 -> 8 -> 4 -> 2 -> 1
#                         30 -> 31 -> 32 -> 16 -> 8 -> 4 -> 2 -> 1
# solution(31) returns 6: 31 -> 32 -> 16 -> 8 -> 4 -> 2 -> 1
# 
# solution(32) returns 5: 32 -> 16 -> 8 -> 4 -> 2 -> 1
# solution(33) returns 6: 33 -> 32 -> 16 -> 8 -> 4 -> 2 -> 1
# solution(34) returns 6: 34 -> 17 -> 16 -> 8 -> 4 -> 2 -> 1
# solution(35) returns 7: 35 -> 36 -> 18 ->  9 -> 8 -> 4 -> 2 -> 1
#                         35 -> 34 -> 17 -> 16 -> 8 -> 4 -> 2 -> 1
# solution(36) returns 6: 
# solution(37) returns 6: 
# solution(38) returns 6: 
# solution(39) returns 6: 
# solution(40) returns 6: 
# solution(41) returns 6: 
# solution(42) returns 6: 
# solution(43) returns 6: 
# 
# solution(64) returns 6: 64 -> 32 -> 16 -> 8 -> 4 -> 2 -> 1
# solution(128) returns 7: 128 -> 64 -> 32 -> 16 -> 8 -> 4 -> 2 -> 1
# solution(256) returns 8: 256 -> 128 -> 64 -> 32 -> 16 -> 8 -> 4 -> 2 -> 1
# solution(2^N) returns N: 
