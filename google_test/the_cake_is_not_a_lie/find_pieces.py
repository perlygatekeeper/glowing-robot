
#  we will need to find length of string and find all factors of number
def solution(s):
    length = len(s)
    factors = []
    factors.append(1)
    for possible_factor in range(2,int(pow(length,0.5))+1):
#       print(f">{possible_factor}")
        if length/possible_factor == int(length/possible_factor):
            factors.append(possible_factor)
    small_factors = factors.copy()
    small_factors.reverse()
    for factor in small_factors:
        if factor != int(length/factor): # don't want to duplicate sqrt(len)
#           print("<%d" % int(length/factor))
            factors.append(int(length/factor))
    factors.reverse()
    print(factors)
    pieces_work = []
    for factor in factors:
        if factor == length:
            continue
        piece = s[0:factor]
        print("factor: %d  piece '%s'" % (factor, piece))
        if len(s.replace(piece,"")) == 0:
            best_factor = factor
            pieces_work.append(factor)
    return int(length/min(pieces_work))

print("abcabcabcabc",solution("abcabcabcabc"))
print("abccbaabccba",solution("abccbaabccba"))
print("aaaaaaaaaaaa",solution("aaaaaaaaaaaa"))
