def pathFinder(x, y, m, steps, lastX, lastY):
    # count possible moves
    options = []
    if x-1 >= 0: # East
        options.append([-1, 0])
    if x+1 <= lastX: # West
        options.append([ 1, 0])
    if y-1 >= 0: # North
        options.append([ 0,-1])
    if y+1 <= lastY: # South
        options.append([ 0, 1])
    # increment step
    steps += 1
    for option in options:
        # new x and y 
        newX = x + option[0]
        newY = y + option[1]
        # if statements
        if m[newY][newX] == 0:
            m[newY][newX] = steps
            if newX != 0 or newY != 0:
                pathFinder(newX, newY, m, steps, lastX, lastY)
        elif m[newY][newX] > 1 and steps < m[newY][newX]:
            m[newY][newX] = steps
            if newX != 0 or newY != 0:
                pathFinder(newX, newY, m, steps, lastX, lastY)
    # print("I'm working with list at:", id(m))
    return m[0][0]

def solution(map):
    steps = 1
    lastX = len(map[0]) - 1
    lastY = len(map) - 1
    x = lastX
    y = lastY
    solutions = []
    print("\nGiven map")
    print(id(map[0][0]))
    for row in map:
        print(row)

    # first find solution with no walls removed
    print("\ntestMap after path equal to 1 in testMap")
    testMap = []
    for row in map:
        testMap.append(row[:])
    testMap[0][0] = 8
    print(id(testMap[0][0]))
    for row in testMap:
        print(row)

    print("\nmap after escape path equal to 1 in testMap")
    print(id(map[0][0]))
    for row in map:
        print(row)

    return 0

    print("------------------------------------------------------------------------")
    print("map with NO removed walls")
    print(id(testMap))
    for row in testMap:
        print(row)
    solutions.append(pathFinder(x, y, testMap, steps, lastX, lastY))
    map[5][5] = "Z"
    print("testMap after call to pathFinder with NO wall removed")
    print(id(testMap))
    for row in testMap:
        print(row)
    print("map after call to pathFinder with NO wall removed")
    print(id(map))
    for row in map:
        print(row)

    return 0

    for possible_one_x in range(len(map[0])):
        for possible_one_y in range(len(map)):
            if map[possible_one_y][possible_one_x] == 1:
                # remove a wall at [possible_one_y][possible_one_x]
                x = lastX
                y = lastY
                testMap = list(map)
                testMap[possible_one_y][possible_one_x] = 0
                testMap[y][x] = 1
                print("------------------------------------------------------------------------")
                print(id(testMap))
                print("removed wall at {0:2d}:{1:2d} and {2}".format(possible_one_x,possible_one_y,solutions))
                for row in testMap:
                    print(row)
                solutions.append(pathFinder(x, y, testMap, steps, lastX, lastY))
                print("map after call to pathFinder with wall removed")
                for row in testMap:
                    print(row)
                testMap[possible_one_y][possible_one_x] = 1

    return min(solutions)



#print(solution([[0, 1], [0, 0]]))
#print(solution([[0, 1, 1, 0], [0, 0, 0, 1], [1, 1, 0, 0], [1, 1, 1, 0]]))
print(solution([[0, 0, 0, 0, 0, 0], [1, 1, 1, 1, 1, 0], [0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1], [0, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0]]))
#print(solution([[0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 0], [0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1], [0, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0]]))

