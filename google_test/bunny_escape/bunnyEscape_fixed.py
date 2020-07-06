def printMap(the_map,note):
    print(note)
    for row in the_map:
        row_str = ""
        for cell in row:
            row_str += " {0:3d}".format(cell)
        print(row_str)
        

def pathFinder(x, y, the_map, steps, lastX, lastY, wall):
    # count possible moves
    debug = False
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
    if debug:
        printMap(the_map,"({0:2d},{1:2d}) steps:{2:3d} {3:6} before options ---------------------------------".format(x,y,steps,wall))
    for option in options:
        # new x and y 
        newX = x + option[0]
        # print("x({0:2d}) + option[0]({1:2d}) -> newX({2:2d})".format(x,option[0],newX) )
        newY = y + option[1]
        # print("y({0:2d}) + option[1]({1:2d}) -> newY({2:2d})".format(y,option[1],newY) )
        if debug:
            print(" looking at ({0:2d},{1:2d}) with value={2:2d} and with steps:{3:3d} {4:6} from ({5:2d},{6:2d})".format(newX,newY,the_map[newY][newX],steps,wall,x,y))
        # if statements
        if the_map[newY][newX] == 0:
            the_map[newY][newX] = steps
            if newX != 0 or newY != 0:
                pathFinder(newX, newY, the_map, steps, lastX, lastY, wall)
        elif the_map[newY][newX] > 1 and steps <= the_map[newY][newX]:
            the_map[newY][newX] = steps
            if newX != 0 or newY != 0:
                pathFinder(newX, newY, the_map, steps, lastX, lastY, wall)
        elif ( the_map[newY][newX] == 1 or the_map[newY][newX] < 0 ) and not wall and (newX != lastX or newY != lastY):
            if debug:
                print("Removing a wall at {0:2d}:{1:2d}".format(newX,newY))
            wall = True
            the_map[newY][newX] = steps * -1
            pathFinder(newX, newY, the_map, steps, lastX, lastY, wall)
            wall = False
        elif the_map[newY][newX] > 1 and steps < abs(the_map[newY][newX]):
            if(the_map[newY][newX] < 0):
                the_map[newY][newX] = steps * -1
            if(the_map[newY][newX] > 0):
                the_map[newY][newX] = steps
            if newX != 0 or newY != 0:
                pathFinder(newX, newY, the_map, steps, lastX, lastY, wall)
        if debug:
            printMap(the_map,"({0:2d},{1:2d}) steps:{2:3d} {3:6} after options ---------------------------------".format(x,y,steps,wall))

def solution(the_map):
    debug = False
    steps = 1
    lastX = len(the_map[0]) - 1
    lastY = len(the_map) - 1
    x = lastX
    y = lastY
    testMap = the_map[:]
    testMap[y][x] = 1
    pathFinder(x, y, testMap, steps, lastX, lastY, False)
    if debug:
        printMap(the_map,"All done. {0:3d} ------------------------------".format(testMap[0][0]))
    return(testMap[0][0])



#print(solution([[0, 1], [0, 0]]))
#print(solution([[0, 1, 1, 0], [0, 0, 0, 1], [1, 1, 0, 0], [1, 1, 1, 0]]))
print(solution([[0, 0, 0, 0, 0, 0], [1, 1, 1, 1, 1, 0], [0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1], [0, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0]]))
#print(solution([[0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 0], [0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1], [0, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0]]))

