import itertools

def solution(bunnies,keys_required):
    answer = []
    for i in range(bunnies):
        answer.append([])
#   if keys_required > bunnies:
#       return None
    if keys_required == 0:
        return [[0]]
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
