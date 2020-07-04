import math
  
# Initialize table[ 0 .. n+1 ] to 0
# each table entry will have the min steps to get to 1
# via one of three options
# 1) n -> n/2 (if n is even)
# 2) n -> n-1 
# 3) n -> n+1 
def solution(s):
    n = int(s)
    # try to handle big numbers ( 1,000,000 or bigger)
    if len(s) >= 7:
        test = math.log(n,2)
        if test == int(test): # short curciut n == 2^k
            return int(test)
        test = math.log(n+1,2)
        if test == int(test): # short curciut n == 2^k - 1
            return 1+int(test)
        test = math.log(n-1,2)
        if test == int(test): # short curciut n == 2^k + 1
            return 1+int(test)
        # ok that would have been too easy, try dividing by 2
        # as much as we can then using recursion, until len(n) < million
        if n&1 == 0:
            number = n 
            i = 0
            while number&1 == 0:
                i += 1
                number //= 2
            # now number is odd
            return i + solution(str(number))
        elif n%4 == 3: # we can +1 then div 2 twice, let's do that
            return 3 + solution(str((n+1)/4))
        else: # number is div 2 but not 4, drop to n-1/2 and add 2 steps
            return 2 + solution(str((n-1)/2))        
    debug = False
    if debug:
        print(n,n+2)
    table = [ 0 for i in range(n+2)] 
    if debug:
        print(" 0,    {0:s}".format(table))
    for i in range(int(math.ceil(math.log(n+2,2))) + 1): 
        pow_2 = int(pow(2,i))
        if pow_2 > n+1:
            break
        table[pow_2] = i
    if debug:
        print(" 1,    {0:s}".format(table))
    for i in range(4, n+2, 2): 
        # j will go 2, 1, 4, 3, 6, 5, 8, 7 ....  2i, 2i-1
        j = i
        if table[j] == 0: # even number which is not a power of 2
            table[j] = 1 + table[j//2]
        j = i - 1
        if j%4 == 3:
            table[j] = 1 + min(table[j+1],table[j-1])
        else:
            table[j] = 1 + table[j-1]
        if debug:
            print("{0:2d}, {1:2d} {2:s}".format(i-1, i,table))
    return table[n]


solutions = [ 0, 0, 1, 2, 2, 3, 3, 4, 3, 4, 4, 5, 4, 5, 5, 5, 4, 5, 5, 6, 5, 6, 6, 6, 5, 6, 6, 7, 6, 7, 6, 6, 5, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
for s in ['15', '4', '235', '1', '91', '1000000', '10000000', '100000000', '1000000000', str(pow(2,50)), '393530540239137101141',
        '11665337198842730263320011877960647281883570298097132994270776567519749329063338257192070277456287061',
        '3571695357287557736494750163533339368538016039018445358145834627901170170416453741643994596052319527091982243058510489417290484285641046811994859191566191601311522591608076995140358201687457047292651394051015491661193980422466255853055181315359020971523732159228847389220143277217541462279068556023125',
#       '59923104495410530257643506359634157787265899298076885757810027052577558601833654377569492440802512007040037959957131119219596589604805540830949143546491374792589297808288495092100739867082031373151027650695001922946050227447487627157971036846942412387783503561528766079982415312826572101611785443208074712405'
]:
    sol = solution(s)
    i = int(s)
    if i < 33:
        print("{0:24d}: {1:d} vs answer of {2:d}  mine is {3: d}".format(i, sol, solutions[i], sol - solutions[i] ))
    else: 
        print("{0:24d}: {1:d}".format(i, sol ))
