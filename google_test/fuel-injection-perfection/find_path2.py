import math

def solution(s):
    n = int(s)
    # try to handle big numbers ( 1,000,000 or bigger)
    test = math.log(n,2)
    if test == int(test): # short curciut n == 2^k
        return int(test)
    test = math.log(n+1,2)
    if test == int(test): # short curciut n == 2^k - 1
        return 1+int(test)
    test = math.log(n-1,2)
    if test == int(test): # short curciut n == 2^k + 1
        return 1+int(test)
    # ok that would have been too easy
    # try counting steps as we count steps in this loop.
    # n is even:
    #    div by 2 until we are odd
    #    count N steps
    # n is  odd:
    #    if we can +1 to get to div by 2 twice (EXCEPT for 3!)
    #       count 3 steps
    #    else -1 and div by 2
    #       count 2 steps
    steps=0
    while n != 1:
        if n&1 == 0:
            i = 0
            while n&1 == 0:
                i += 1
                n //= 2
            # now number is odd
            steps += i
        elif n != 3 and n%4 == 3: # we can +1 then div 2 twice, let's do that
            steps += 3
            n = (n+1)/4
        else:
            steps += 2
            n = (n-1)/2
    return steps

solutions = [ 0, 0, 1, 2, 2, 3, 3, 4, 3, 4, 4, 5, 4, 5, 5, 5, 4, 5, 5, 6, 5, 6, 6, 6, 5, 6, 6, 7, 6, 7, 6, 6, 5, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
for s in ['15', '4', '235', '1', '91', '1000000', '10000000', '100000000', '1000000000', str(pow(2,50)), '393530540239137101141',
        '11665337198842730263320011877960647281883570298097132994270776567519749329063338257192070277456287061',
        '3571695357287557736494750163533339368538016039018445358145834627901170170416453741643994596052319527091982243058510489417290484285641046811994859191566191601311522591608076995140358201687457047292651394051015491661193980422466255853055181315359020971523732159228847389220143277217541462279068556023125',
        '59923104495410530257643506359634157787265899298076885757810027052577558601833654377569492440802512007040037959957131119219596589604805540830949143546491374792589297808288495092100739867082031373151027650695001922946050227447487627157971036846942412387783503561528766079982415312826572101611785443208074712405' ]:
    sol = solution(s)
    i = int(s)
    if i < 33:
        print("{0:24d}: {1:d} vs answer of {2:d}  mine is {3: d}".format(i, sol, solutions[i], sol - solutions[i] ))
    else: 
        print("{0:24d}: {1:d}".format(i, sol ))
