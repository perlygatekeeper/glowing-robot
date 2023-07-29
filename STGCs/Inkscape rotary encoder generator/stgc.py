#!/usr/bin/env python

import math
import sys
import string

"""

stgc.py - an exploration of single-track Gray codes, bitshift codes, and
          other single-track codes.
Copyright 2009, Benjamin C. Wiley Sittler <bsittler@gmail.com>

LICENSE

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

Author contact information:

        Benjamin C. W. Sittler <bsittler@gmail.com>
        2806 Foothill Boulevard
        Oakland, California 94601
        U.S.A.

NOTES

Wikipedia has a good discussion of Gray codes generally, and
single-track Gray codes specifically:

http://en.wikipedia.org/wiki/Gray_code#Single-track_Gray_code

An example of a 126-position single-track Gray code may be found here:

http://www.quirkfactory.com/gray-code/

The paper cited by Wikipedia:

Hiltgen, Alain P.; Kenneth G. Paterson, Marco Brandestini
(1996). "Single-Track Gray Codes". IEEE Transactions on Information
Theory 42: 1555-1561. doi:10.1109/18.532900.

http://ieeexplore.ieee.org/iel1/18/11236/00532900.pdf

"""

# see http://code.activestate.com/recipes/219300/#c4
try:
    if bin(0): pass
except NameError, ne:
    bin = lambda x: (
        lambda: '-' + bin(-x),
        lambda: '0b' + '01'[x & 1],
        lambda: bin(x >> 1) + '01'[x & 1]
        )[1 + (x > 1) - (x < 0)]()
    def bin(x):
        """
        bin(number) -> string
        
        Stringifies an int or long in base 2.
        """
        if x < 0: return '-' + bin(-x)
        out = []
        if x == 0: out.append('0')
        while x > 0:
            out.append('01'[x & 1])
            x >>= 1
            pass
        try: return '0b' + ''.join(reversed(out))
        except NameError, ne2: out.reverse()
        return '0b' + ''.join(out)
    pass

def mybin(x, zero='-', one = 'x'):
    """

    like bin(x), but omits the "0b" prefix and allows the digit
    representations to be specified.

    """
    return bin(x)[2:].translate(string.maketrans('01', zero + one))

def stgc(length):
    """

    Searches for single-track codes of the given length and yields
    them, along with the corresponding head configurations; if the
    length is negated, this looks only for single-track Gray codes
    with evenly-spaced heads.

    This should print only one form of a given code; others can be
    obtained by some combinations of bit-inversion, rotation, and (in
    the case of a symmetric head configuration) reflection.

    This should likewise only consider one reflection and rotation of
    each possible head configuration.

    """
    onlyGrayCodesWithEvenHeadSpacing = False
    if length < 0:
        length = abs(length)
        onlyGrayCodesWithEvenHeadSpacing = True
        pass
    numcodes = (1 << length)
    codemask = numcodes - 1
    bits = int(math.ceil(math.log(length, 2)))
    mincode = ((1<<(length//2))-1)
    allcodes = lambda: xrange(mincode, numcodes)
    if onlyGrayCodesWithEvenHeadSpacing:
        tested = {}
        good = {}
        next = {}
        for encoding in xrange(1 << bits):
            if not tested.has_key(encoding):
                suitable = True
                versions = {}
                for bit in xrange(bits):
                    version = ((encoding << bit) | (encoding >> (bits - bit))) & ((1 << bits) - 1)
                    if not tested.has_key(version):
                        versions[version] = True
                        pass
                    else:
                        suitable = False
                        pass
                    pass
                if len(versions) != bits:
                    suitable = False
                    pass
                versions = versions.keys()
                for version in versions:
                    tested[version] = encoding
                    if suitable:
                        good[version] = sorted(versions)
                        next[version] = sorted([ version ^ (1 << bit) for bit in xrange(bits) ])
                        pass
                    pass
                pass
            pass
        zones = length // (1, bits)[bits != 0]
        def stgc2(encoding, unavail):
            if (len(encoding) * bits) == length:
                for successor in next[encoding[-1]]:
                    if (((successor << 1) | (successor >> (bits - 1))) & ((1 << bits) - 1)) == encoding[0]:
                        code = 0
                        for position in encoding:
                            for bit in xrange(bits):
                                if position & (1 << bit):
                                    code |= 1 << (bit * zones)
                                    pass
                                pass
                            code = (((code & 1) << (length - 1)) | (code >> 1))
                            pass
                        yield code
                        break
                    pass
                pass
            elif len(encoding) < zones:
                for successor in next[encoding[-1]]:
                    if good.has_key(successor) and not unavail.has_key(successor):
                        for version in good[successor]:
                            unavail[version] = True
                            pass
                        for answer in stgc2(encoding + [ successor ], unavail):
                            yield answer
                            pass
                        for version in good[successor]:
                            del unavail[version]
                            pass
                        pass
                    pass
                pass
            pass
        def stgc2codes():
            unavail = {}
            yielded = {}
            for encoding in xrange(1 << bits):
                if good.has_key(encoding) and not unavail.has_key(encoding):
                    for version in good[encoding]:
                        unavail[version] = True
                        pass
                    for code in stgc2([encoding], unavail):
                        revcode = sum(1 << (length - 1 - pos) for pos in xrange(length) if code & (1 << pos))
                        canoncode = min(
                            min(((code << pos) | (code >> (length - pos))) & codemask for pos in xrange(length)),
                            min((((code << pos) | (code >> (length - pos))) ^ codemask) & codemask for pos in xrange(length)),
                            min(((revcode << pos) | (revcode >> (length - pos))) & codemask for pos in xrange(length)),
                            min((((revcode << pos) | (revcode >> (length - pos))) ^ codemask) & codemask for pos in xrange(length)))
                        if not yielded.has_key(canoncode):
                            #print mybin(canoncode | numcodes)[1:]
                            yield canoncode
                            yielded[canoncode] = True
                            pass
                        pass
                    pass
                pass
            pass
        allcodes = stgc2codes
        pass
    #print 'length', length, 'bits', bits
    #sys.stdout.flush()
    gaps = [ 0 for bit in xrange(bits) ]
    if onlyGrayCodesWithEvenHeadSpacing:
        for bit in xrange(1, bits):
            gaps[bit] = int((bit * length // bits) - bit - sum(gaps))
            pass
        pass
    while True:
        bit = 0
        heads = []
        for gap in gaps:
            bit += gap
            heads.append(1<<bit)
            bit += 1
            pass
        sumheads = sum(heads)
        allsumheads = [((sumheads << position) | (sumheads >> (length - position))) % numcodes for position in xrange(length)]
        revsumheads = sum(1 << (length - 1 - position) for position in xrange(length) if sumheads & (1 << position))
        allrevsumheads = [((revsumheads << position) | (revsumheads >> (length - position))) % numcodes for position in xrange(length)]
        minsumheads = min(allsumheads)
        minrevsumheads = min(allrevsumheads)
        heads_are_symmetric = minsumheads == minrevsumheads
        heads_are_revminimal = minsumheads <= minrevsumheads
        heads_are_minimal = True
        for mask in allsumheads:
            if (mask & 1) and (mask < sumheads):
                heads_are_minimal = False
                break
            pass
        #print 'heads', mybin(sumheads | numcodes)[1:]
        #sys.stdout.flush()
        if (heads_are_revminimal
            and
            heads_are_minimal):
            #print 'heads', mybin(sumheads | numcodes)[1:]
            #sys.stdout.flush()
            #print 'considering', numcodes
            #sys.stdout.flush()
            for code in allcodes():
                suitable = True
                if suitable:
                    code_inverse = code ^ codemask
                    code_reverse = sum(1 << (length - 1 - position) for position in xrange(length) if code & (1 << position))
                    code_reverse_inverse = code_reverse ^ codemask
                    codes = [((code << position) | (code >> (length - position))) % numcodes for position in xrange(length)]
                    codes_inverse = [((code_inverse << position) | (code_inverse >> (length - position))) % numcodes for position in xrange(length)]
                    codes_reverse_inverse = [((code_reverse_inverse << position) | (code_reverse_inverse >> (length - position))) % numcodes for position in xrange(length)]
                    codes_reverse = [((code_reverse << position) | (code_reverse >> (length - position))) % numcodes for position in xrange(length)]
                    pass
                if (suitable
                    and
                    ((length < 2)
                     or
                     (code == min(codes)))
                    and
                    (code
                     <=
                     min(codes_inverse))
                    and
                    ((not heads_are_symmetric)
                     or
                     ((code
                       <=
                       min(codes_reverse))
                      and
                      (code
                       <=
                       min(codes_reverse_inverse))))):
                    #print ' code', mybin(code | numcodes)[1:]
                    #print '~code', mybin(code_inverse | numcodes)[1:]
                    #print ' edoc', mybin(code_reverse | numcodes)[1:]
                    #print '~edoc', mybin(code_reverse_inverse | numcodes)[1:]
                    #sys.stdout.flush()
                    encodings = {}
                    prevencoding = 0
                    firstencoding = 0
                    isGrayCode = True
                    for position in xrange(length):
                        encoding = sum(1 << bit for bit in xrange(bits) if codes[position] & heads[bit])
                        if encodings.has_key(encoding):
                            #nonsolution = ' '.join([ mybin(e | (1<<bits), '-', 'x')[1:] for (p,e) in sorted((p,e) for (e,p) in encodings.iteritems()) ])
                            #print 'heads', mybin(sumheads | numcodes)[1:],
                            #print 'code', mybin(code | numcodes)[1:], 'digits', nonsolution,
                            #print 'broken by', mybin(encoding | (1 << bits))[1:]
                            #sys.stdout.flush()
                            break
                        if position:
                            diff = encoding ^ prevencoding
                            while not (diff & 1):
                                diff >>= 1
                                pass
                            isGrayCode = isGrayCode and (diff == 1)
                            pass
                        else:
                            firstencoding = encoding
                            pass
                        prevencoding = encoding
                        encodings[encoding] = position
                        pass
                    else:
                        if length > 1:
                            diff = firstencoding ^ prevencoding
                            while not (diff & 1):
                                diff >>= 1
                                pass
                            isGrayCode = isGrayCode and (diff == 1)
                            pass
                        if isGrayCode or not onlyGrayCodesWithEvenHeadSpacing:
                            #print ('/', '=')[heads_are_symmetric],
                            yield {
                                'heads': sumheads,
                                'code': code,
                                'bits': bits,
                                'length': length,
                                'encoding': [ e for (p,e) in sorted((p,e) for (e,p) in encodings.iteritems()) ],
                                'isBitshiftCode': (sum(gaps) == 0),
                                'isGrayCode': isGrayCode,
                                }
                            pass
                        pass
                    pass
                pass
            pass
        if onlyGrayCodesWithEvenHeadSpacing:
            break
        while True:
            for bit in xrange(1, bits):
                gaps[bit] += 1
                if bits + sum(gaps) > length:
                    gaps[bit] = 0
                    continue
                break
            #if bits and (gaps[-1] > gaps[0]):
                #continue
            break
        if not sum(gaps):
            break
        pass
    pass

if __name__ == '__main__':
    (length,) = sys.argv[1:]
    for answer in stgc(int(length)):
        solution = ' '.join([ mybin(e | (1 << answer['bits']), '-', 'x')[1:] for e in answer['encoding'] ])
        print 'heads', mybin(answer['heads'] | (1 << answer['length']), '=', 'V')[1:],
        print 'code', mybin(answer['code'] | (1 << answer['length']))[1:],
        print 'digits', solution,
        print (('single-track', 'bitshift')[answer['isBitshiftCode']], 'single-track Gray')[answer['isGrayCode']]
        sys.stdout.flush()
        pass
    pass
