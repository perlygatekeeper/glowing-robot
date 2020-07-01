class Solution:
    def __inti__(self):
        pass
    
    def solution(self,s):
        length = len(s)
        factors = []
        small_factors = []
        factors.append(1)
        for possible_factor in range(2,int(pow(length,0.5))+1):
            if length/possible_factor == int(length/possible_factor):
                factors.append(possible_factor)
        small_factors = factors.copy()
        small_factors.reverse()
        for factor in small_factors:
            if factor != int(length/factor):
                factors.append(int(length/factor))
        pieces = []
        for factor in factors:
            piece = s[0:factor]
            if len(s.replace(piece,"")) == 0:
                pieces.append(factor)
        return "%5s" % int(length/min(pieces))
