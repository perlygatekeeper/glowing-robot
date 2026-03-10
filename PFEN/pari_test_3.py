import sys
import time
import cypari2

sys.set_int_max_str_digits(10**6)
pari = cypari2.Pari()

n = 10**100000 + 1

# Method 1: decimal string
t0 = time.time()
pn_dec = pari(str(n))
print(f"decimal str conversion : {time.time()-t0:.3f}s")

# Method 2: hex string
t0 = time.time()
pn_hex = pari(f"0x{n:x}")
print(f"hex conversion         : {time.time()-t0:.3f}s")

# Method 3: actual ispseudoprime on already-converted number
t0 = time.time()
pari.ispseudoprime(pn_hex)
print(f"ispseudoprime          : {time.time()-t0:.3f}s")
