#!/opt/local/bin/python
# Program to find all combination of 8 coins that add to a value of 200p
# 1p, 2p, 5p, 10p, 20p, 50p, £1 (100p), and £2 (200p).

import timeit
import time
import sys
import math

values = {}
values['L2']   = 200
values['L1']   = 100
values['p50']  =  50
values['p20']  =  20
values['p10']  =  10
values['p5']   =   5
values['p2']   =   2
values['p1']   =   1

start_time = timeit.default_timer()
combinations = 0;

for L2 in range(0,2):
    v1 = values['L2'] * L2
    if ( v1 > 200 ):
        break
    for L1 in range(0,3):
        v2 = values['L1'] * L1
        if ( ( v1 + v2 ) > 200 ):
            break
        for p50 in range(0,5):
            v3 = values['p50'] * p50
            if ( ( v1 + v2 + v3 ) > 200 ):
                break
            for p20 in range(0,11):
                v4 = values['p20'] * p20
                if ( ( v1 + v2 + v3 + v4 ) > 200 ):
                    break
                for p10 in range(0,21):
                    v5 = values['p10'] * p10
                    if ( ( v1 + v2 + v3 + v4 + v5 ) > 200 ):
                        break
                    for p5 in range(0,41):
                        v6 = values['p5'] * p5
                        if ( ( v1 + v2 + v3 + v4 + v5 + v6 ) > 200 ):
                            break
                        for p2 in range(0,101):
                            v7 = values['p2'] * p2
                            if ( ( v1 + v2 + v3 + v4 + v5 + v6 + v7 ) > 200 ):
                                break
                            for p1 in range(0,201):
                                v8 = values['p1'] * p1
                                value = ( v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 )
                                if ( value == 200 ):
                                    # print ("%1d:%1d:%2d:%2d:%2d:%2d:%3d:%3d" % (L2, L1, p50, p20, p10, p5, p2, p1 ) )
                                    combinations += 1
                                    break
                                elif ( value > 200 ):
                                    value -= values['p1'] * p1
                                    break

print("\nFound %d combinations of coins that have a value of 200p and this took %f seconds to find."
% ( combinations, ( timeit.default_timer() - start_time ) ) )

