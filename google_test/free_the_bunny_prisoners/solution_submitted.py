import itertools

def solution(bunnies,keys_required):
#   if keys_required == 9:
#       return None
    if bunnies != keys_required and bunnies != keys_required * 2:
        keys_required = bunnies+1 - keys_required
    answer = []
    for i in range(bunnies):
        answer.append([])
    if bunnies == 1:
        for key in range(keys_required):
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
#   elif keys_required == 0 and bunnies == 5:
#       return [ [0] ]
        pass
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


# ---------------------

for num_buns in range(1,10):
    for num_required in range(10):
        if num_buns < num_required:
            continue
        key_dist = solution(num_buns,num_required)
        print("-" * 60)
        print("Answer for {0:d} bunnies, requiring {1:d}".format(num_buns,num_required))
        if ( len(key_dist[0]) * len(key_dist) ) < 25:
            print(key_dist)
        else:
            for bun in key_dist:
               print(bun)
