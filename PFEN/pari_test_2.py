import time
import cypari2
pari = cypari2.Pari()

import sys
sys.set_int_max_str_digits(10**6)

# Time just the conversion, no primality test
n = 10**100000 + 1  # dummy 100K digit number
t0 = time.time()
pn = pari(str(n))
print(f"str(n) + pari() conversion: {time.time()-t0:.2f}s")

# Now time the actual test on a number already converted
t0 = time.time()
pari.ispseudoprime(pn)
print(f"ispseudoprime on pre-converted: {time.time()-t0:.2f}s")
