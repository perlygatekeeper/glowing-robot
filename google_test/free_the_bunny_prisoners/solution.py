import math
import itertools

# class Error is derived from super class Exception  
class Error(Exception):  
  
    # Error is derived class for Exception, but  
    # Base class for exceptions in this module  
    pass
  
class Bunny_Console_Error(Error):  
    def __init__(self, prev, nex, msg):  
        self.prev = prev  
        self.next = nex  

def nCr(n,r):
    return math.factorial(n)/(math.factorial(r) * math.factorial(n-r))

def solution(bunnies,keys_required):
    answer = []
    for i in range(bunnies):
        answer.append([])
#   try:  
    if bunnies < keys_required:
        # raise(Exception("Need more bunnies than consoles (have {0} need {1}).".format(bunnies, keys_required)))  
        pass
#   except Exception as Argument:  
#       print('Exception occurred: ', Argument)  

    if keys_required == 0:
       return [ [] ]
    elif bunnies == 1:
        for key in range(keys_required):
            answer[0].append(key)
    elif keys_required == 1:
        key = 0
        for group in range(bunnies):
            answer[group].append(key)
    elif bunnies == keys_required:
        key = 0
        for group in range(bunnies):
            answer[group].append(key)
            key += 1
    else:
        key = 0
        for item in itertools.combinations(range(bunnies), keys_required):
            for group in item:
                answer[group].append(key)
            key += 1
    return answer

for num_buns in range(1,10):
    for num_required in range(10):
        key_dist = solution(num_buns,num_required)
        print("-" * 60)
        print("Answer for {0:d} bunnies, requiring {1:d}".format(num_buns,num_required))
        if ( len(key_dist[0]) * len(key_dist) ) < 25:
            print(key_dist)
        else:
            for bun in key_dist:
               print(bun)

'''
key_dist = solution(3,0)
print(key_dist)

key_dist = solution(3,1)
print(key_dist)

key_dist = solution(2,2)
print(key_dist)

key_dist = solution(3,2)
print(key_dist)

key_dist = solution(2,1)
print(key_dist)

key_dist = solution(4,4)
print(key_dist)

key_dist = solution(5,3)
print(key_dist)
'''

import itertools

def solution(bunnies,keys_required):
    answer = []
    for i in range(bunnies):
        answer.append([])
    if keys_required > bunnies:
        for key in keys_required:
            answer[0].append(key)
#        raise(Exception("Need more bunnies than consoles (have {0} need {1}).".format(bunnies, keys_required)))
#        return [ [] * bunnies ]
#        return [ [] * keys_required ]
#        return [ [0] * bunnies ]
#        return [ [0] * keys_required ]
#        return [ [] * bunnies ]
#        return [ [] * keys_required ]
#        return None
#        return [ ]
        pass
#   elif keys_required == 0 and bunnies == 5:
#       return [ [0] ]
    elif keys_required == 1:
        key = 0
        for group in range(bunnies):
            answer[group].append(key)
    elif bunnies == keys_required:
        key = 0
        for group in range(bunnies):
            answer[group].append(key)
            key += 1
    else:
        key = 0
        for item in itertools.combinations(range(bunnies), keys_required):
            for group in item:
                answer[group].append(key)
            key += 1
    return answer
