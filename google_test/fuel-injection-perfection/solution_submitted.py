import math

def solution(n):
    table = [ 0 for i in range(n+2)]
    for i in range(int(math.ceil(math.log(n+2,2))) + 1):
        pow_2 = int(pow(2,i))
        if pow_2 > n+1:
            break
        table[pow_2] = i
    for i in range(4, n+2, 2):
        j = i
        if table[j] == 0:
            table[j] = 1 + table[j//2]
        j = i - 1
        if j%4 == 3:
            table[j] = 1 + min(table[j+1],table[j-1])
        else:
            table[j] = 1 + table[j-1]
    return table[n]

print(solution(4))
print(solution(15))
