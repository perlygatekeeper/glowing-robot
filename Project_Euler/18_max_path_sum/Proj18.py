import math

triangle_string ='''
75
95  64
17  47  82
18  35  87  10
20  04  82  47  65
19  01  23  75  03  34
88  02  77  73  07  63  67
99  65  04  28  06  16  70  92
41  41  26  56  83  40  80  70  33
41  48  72  33  47  32  37  16  94  29
53  71  44  65  25  43  91  52  97  51  14
70  11  33  28  77  73  17  78  39  68  17  57
91  71  52  38  17  14  91  43  58  50  27  29  48
63  66  04  68  89  53  67  30  73  16  69  87  40  31
04  62  98  27  23  09  70  98  73  93  38  53  60  04  23'''

def extractTriangle(triangle_string):
    triangle_string = triangle_string.replace("\n","",1)
    #print(triangle_string)
    #print(" ")
    triangle=[]
    for row_string in triangle_string.splitlines():
        row=[]
        for number in row_string.split():
            row.append(int(number))
        triangle.append(row)
#       triangle.append(row_string.split())
#   print (type(triangle[0]))
#   print (triangle[0])
    return triangle


triangle = extractTriangle(triangle_string)

solution = triangle.copy()


for row in range(len(solution)-2,-1,-1):
   # print(row)
   for node in range(len(solution[row])):
        # print(solution[row][node])
        solution[row][node] += max(solution[row+1][node], solution[row+1][node+1])

print(solution[0][0])

indent = 15
for row in triangle_string.splitlines():
    for i in range(indent):
      print("  ",end="")
    indent -= 1
    print(row, end="")
    print("")
print("")
print("")

indent = len(solution)
for row in solution:
    for i in range(indent):
      print("   ",end="")
    indent -= 1
    for node in row:
        print(" %5d" % (node), end="" )
    print("")
