def solution(h,q):
    ionTree = {1:-1}
    treeTop = 1
    for x in range (2,h+1):
        for node in range (1,treeTop+1):
            if ionTree[node] == -1:
                ionTree[node] = pow(2,x) - 1
                ionTree[node+treeTop] = pow(2,x) - 1
                ionTree[pow(2,x) - 1] = -1
            else:
                ionTree[node+treeTop] = ionTree[node] + treeTop
        treeTop = pow(2,x) - 1
    return [ ionTree[node] for node in q ]

print(solution( 3, [7, 3, 5, 1]  ))
print(solution( 5, [19, 14, 28]  ))
