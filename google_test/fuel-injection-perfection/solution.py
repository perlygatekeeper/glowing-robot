def getMinSteps(n, mem): 
    print(n,mem)
    # base case 
    if (n == 1): 
        return 0
    if (mem[n] != -1): 
        return mem[n] 
    # store temp value for n as min(f(n-1), f(n//2), f(n+1)) + 1 
    res = getMinSteps(n-1, mem) 
    if (n&1 == 0): 
        res = min(res, getMinSteps(n//2, mem)) 
    else: 
        res = min(res, getMinSteps(n+1, mem), getMinSteps(n-1, mem), ) 
    # store mem[n] and return 
    mem[n] = 1 + res 
    return mem[n] 
  
# Initialize mem[] and call getMinSteps(n, mem) 
def solution(n): 
    mem = [ 0 for i in range(n+2)] 
    for i in range(n+2): 
        mem[i] = -1
    i = 0
    while pow(2,i) < n+1:
        mem[int(pow(2,i))] = i
        i += 1
    return getMinSteps(n, mem) 


solutions = [ 0, 0, 1, 2, 2, 3, 3, 4, 3, 4, 4, 5, 4, 5, 5, 5, 4, 5, 5, 6, 5, 6, 6, 6, 5, 6, 6, 7, 6, 7, 6, 6, 5, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
for i in range(2,33):
    s = solution(i)
    print("{0:4d}: {1:d} vs {2:d}   {3:d}".format(i, s, solutions[i], s - solutions[i] ))
