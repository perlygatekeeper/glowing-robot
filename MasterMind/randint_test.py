from numpy import random

min_x = 100
max_x = 0

i = 1
while i < 10000:
    i += 1
    x = random.randint(100)
    if x < min_x:
        min_x = x
    if x > max_x:
        max_x = x
    print("min is %2d  max is %2d" % ( min_x, max_x))
else:
    print("final:\nmin is %2d  max is %2d" % ( min_x, max_x))
  
