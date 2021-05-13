from itertools import combinations

def solution(num_buns, num_required):
    keyrings = [[] for num in range(num_buns)]
    copies_per_key = num_buns - num_required + 1
    if copies_per_key < 0:
        return [[]]
    for key, bunnies in enumerate(combinations(range(num_buns), copies_per_key)):
        for bunny in bunnies:
            keyrings[bunny].append(key)
    return keyrings

# assert all([all([x == y for x, y in zip(a, b)])
#     for a, b in zip([[0, 1, 2, 3, 4, 5], [0, 1, 2, 6, 7, 8], [0, 3, 4, 6, 7, 9], [1, 3, 5, 6, 8, 9], [2, 4, 5, 7, 8, 9]], solution(5, 3))])
# assert all([all([x == y for x, y in zip(a, b)])
#     for a, b in zip([[0], [1], [2], [3]], solution(4, 4))])


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
