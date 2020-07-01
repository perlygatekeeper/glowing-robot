#  we will need to find length of string and find all factors of number
def solution(s):
    length = len(s)
    factors = []
    small_factors = []
    factors.append(1)
    for possible_factor in range(2,int(pow(length,0.5))+1):
        if length/possible_factor == int(length/possible_factor):
            factors.append(possible_factor)
    small_factors = factors[:]
    small_factors.reverse()
    for factor in small_factors:
        if factor != int(length/factor): # don't want to duplicate sqrt(len)
            factors.append(int(length/factor))
    # now we subsring s into # parts equal to each factor
    # until they don't all match,  returning the last factor
    # where all the pieces DO match.
    pieces = []
    for factor in factors:
        piece = s[0:factor]
        if len(s.replace(piece,"")) == 0:
            pieces.append(factor)
    return int(length/min(pieces))



print("abcabcabcabc",solution("abcabcabcabc"))
print("abccbaabccba",solution("abccbaabccba"))
print("aaaaaaaaaaaa",solution("aaaaaaaaaaaa"))
