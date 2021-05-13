import math
import itertools

def nCr(n,r):
    return math.factorial(n)/(math.factorial(r) * math.factorial(n-r))

#print("-" * 20)
#for item in itertools.combinations(range(10), 5):
#    print(item)

def solution(bunnies,keys_required):
#print("")
#print("-" * 20)
number_unique_keys = nCr(bunnies,keys_required)
for key in number_unique_keys:
    for item in itertools.combinations(range(5), 3):
        # print("{0:2d} {1}".format(i,item))
        # i += 1
