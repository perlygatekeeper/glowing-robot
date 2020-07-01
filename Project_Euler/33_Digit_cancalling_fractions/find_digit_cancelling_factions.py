#!/opt/local/bin/python
# Python the digit-cancelling factions of 2-digits
  
import sys 
import math 
import timeit
import time
import re


start_time = timeit.default_timer()

numbers_containing = { 1:[], 2:[], 3:[], 4:[], 5:[], 6:[], 7:[], 8:[], 9:[] }
numbers = []
for tens in range(1,10):
  for ones in range(1,10):
      number = tens * 10 + ones
      numbers_containing[tens].append(number)
      numbers.append(number)
      if tens != ones:
          numbers_containing[ones].append(number)

# print( len(numbers_containing) )
# for digit in sorted(numbers_containing.keys()):
#   print("%d:" % (digit),end="")
#   for number in numbers_containing[digit]:
#       print(" %2d" % (number),end="")
#   print("")

for i in range(len(numbers)-1):
    numerator = numbers[i]
    tens = int( numerator / 10 )
    ones =      numerator % 10
    for j in range(i+1,len(numbers)):
        demoninator = numbers[j]
        if ( demoninator in numbers_containing[tens] ): # numerator_tens digit is in demoninator
            print("%2d / %2d" % ( numerator, demoninator ), end="") 
            faction = ( numerator / demoninator )
            digit_cancelled_numerator   = ones
            digit_cancelled_demoninator = int(str(demoninator).replace(str(tens),'',1))
            print("   %1d / %1d" % ( digit_cancelled_numerator, digit_cancelled_demoninator ), end="") 
            new_faction = ( digit_cancelled_numerator / digit_cancelled_demoninator )
#           if (faction - new_faction) < 0.00000001:
            if faction == new_faction:
                print("    <----")
            else:
                print("")

        if ( demoninator in numbers_containing[ones] ): # numerator_ones digit is in demoninator
            print("%2d / %2d" % ( numerator, demoninator ), end="") 
            faction = ( numerator / demoninator )
            digit_cancelled_numerator   = tens
            digit_cancelled_demoninator = int(str(demoninator).replace(str(ones),'',1))
            print("   %1d / %1d" % ( digit_cancelled_numerator, digit_cancelled_demoninator ), end="") 
            new_faction = ( digit_cancelled_numerator / digit_cancelled_demoninator )
#           if (faction - new_faction) < 0.00000001:
            if faction == new_faction:
                print("    <----")
            else:
                print("")

# print ("%d digit-cancelling factions found in: %f seconds" % ( len(dgf), ( timeit.default_timer() - start_time ) ) )
