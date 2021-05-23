#!/opt/local/bin/python
# Python program to find decimal representions of fractions between 1/2 and 1/999

import sys 
import math 
import timeit
import time
# import itertools

start_time = timeit.default_timer()

limit = 999
limit = 7

for denominator in range(2,limit+1):
    print("looking at 1 / %3d:" % denominator )
    digits = {1: 1}
    decimal = []
    last_numerator = 1
    repeating = ""
    done = False
    digit = 0
    while (not done):
        digit += 1
        if (digit >= 10): # safety net
            done = True
        numerator = 10 * last_numerator
        if numerator < denominator: # quotient will be 0
            digits[last_numerator] = digit
            decimal.append('0')
            continue
        else:
            quotient  = numerator//denominator
            remainder = numerator%denominator
            print("%5d:%5d" % ( quotient, remainder ) )
            if remainder == 0:
                decimal.append(str(quotient))
                done = True
            else:
                if remainder in digits:
                    # we have a repeating decimal
                    decimal.append(str(quotient))
                    repeating = " last %d digits repeating" % (digit - digits[remainder] + 1)
                    break
                else:
                    # remember remainder in digits as this digit
                    digits[remainder] = digit+1
                    # append quotient to decimal
                    decimal.append(str(quotient))
        last_numerator = remainder
        print(digits)
    print ("0.", "".join(decimal), repeating)
            
    # loop ( quotient, remainder ) = quotient_and_remainder (last_numerator*10, denomiator)
    # if quotient = 0 mark a 0 for the digit and loop again
    # if remainder = 0 we have a terminating decimal representation of the faction
    # if remainder has been seen before, we have a repeating fraction
    #    determine which digit was the first occurance of remainder
    # if remainder has NOT been seen before, record it in a dictionary,   memory[remainder] = which digit we are on


print("this took %f seconds ." % ( ( timeit.default_timer() - start_time ) ) )


'''

1 / 3:
    10 / 3 = 3 with 1 left over
    
1 / 7:
Digit
 1:   1 -> 10 / 7 = 1 ( 7) -> 3 left over
 2:   3 -> 30 / 7 = 4 (28) -> 2 left over
 3:   2 -> 20 / 7 = 2 (14) -> 6 left over
 4:   6 -> 60 / 7 = 8 (56) -> 4 left over
 5:   4 -> 40 / 7 = 5 (35) -> 5 left over
 6:   5 -> 50 / 7 = 7 (49) -> 1 left over  WE'VE SEEN A 1 BEFORE AT FIRST DIGIT
                                           6 - 1 +1 = 6 (six repeating digits)
                                     
1 / 101:
Digit
1:    1 ->   10 / 101 = 0 ->  10 left over
2:   10 ->  100 / 101 = 0 -> 100 left over
3:  100 -> 1000 / 101 = 9 ->  91 left over
3:   91 ->  910 / 101 = 9 ->   1 left over  WE'VE SEEN A 1 BEFORE AT FIRST DIGIT
                                            3 - 1 +1 = 3 (three repeating digits)

'''
