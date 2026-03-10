import random
import time
import sys
sys.set_int_max_str_digits(10**6)  # Increase the limit to 1 million digits

def time_primality_test(test_function, n, k=5):
    """ Wrapper function to time primality test functions. """
    start_time = time.time()
    result = test_function(n, k) if 'k' in test_function.__code__.co_varnames else test_function(n)
    elapsed_time = time.time() - start_time
    print(f"{test_function.__name__} took {elapsed_time:.6f} seconds for {n}.")
    return result

def fermat_primality_test(n, k=5):
    """ Perform the Fermat primality test on n using k iterations. """
    for _ in range(k):
        a = random.randint(2, n - 2)  # Choose a random integer in range [2, n-2]
        if pow(a, n - 1, n) != 1:  # Compute (a^(n-1)) % n
            return False  # Definitely composite
    return True  # Probably prime

def miller_rabin_primality_test(n, k=5):
    """ Perform the Miller-Rabin primality test on n using k iterations. """
    if n < 2:
        return False
    if n in (2, 3):
        return True
    if n % 2 == 0:
         return False
    
    r, d = 0, n - 1
    while d % 2 == 0:
        r += 1
        d //= 2
    
    for _ in range(k):
        a = random.randint(2, n - 2)
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True

def baillie_psw_primality_test(n):
    """ Perform the Baillie-PSW primality test on n. """
    if n < 2:
        return False
    if n in (2, 3):
        return True
    if n % 2 == 0:
        return False
    
    if not miller_rabin_primality_test(n, 1):
        return False
    
    return True  # Approximation, full implementation requires advanced Lucas sequence

def aks_primality_test(n):
    """ Perform the AKS primality test on n (not optimized for large numbers). """
    if n < 2:
        return False
    if n in (2, 3):
        return True
    if n % 2 == 0:
        return False
    return True  # Normally would involve polynomial calculations


def read_last_line(filepath):
    print(f"attempting to open {filepath}")
    with open(filepath, 'rb') as f:
        #print(f"f is of type {type(f)}")
        f.seek(0, 2)  # Move to the end of the file

        if f.tell() == 0:
            return None  # Empty file
        f.seek(-2, 2)  # Start at second last byte

        while f.tell() > 0:
            byte = f.read(1)
            if byte == b'\n':
                break
            f.seek(-2, 1)
        last_line = f.readline().decode().strip()
        return int(last_line)  # <-- Must return inside the 'with' block


# ✅Example Usage:
primes_file = "11_digit_probable_primes.txt"
last_line = read_last_line(primes_file)
print(f"Last line of {primes_file} is {last_line}")
# exit()

# The 48 Possible prime residues mod 210
wheel_residues = [  1,  11,  13,  17,  19,  23 , 29,  31,  37,  41,  43,  47,
                   53,  59,  61,  67,  71 , 73,  79,  83,  89,  97, 101, 103,
                  107, 109, 113, 121, 127, 131, 137, 139, 143, 149, 151, 157,
                  163, 167, 169, 173, 179, 181, 187, 191, 193, 197, 199, 209 ]

some_primes = [  11,   13,   17,   19,   23,   29,   31,   37,   41,   43,   47,   53,   59,
                 61,   67,   71,   73,   79,   83,   89,   97,  101,  103,  107,  109,  113,
                127,  131,  137,  139,  149,  151,  157,  163,  167,  173,  179,  181,  191,
                193,  197,  199,  211,  223,  227,  229,  233,  239,  241,  251,  257,  263,
                269,  271,  277,  281,  283,  293,  307,  311,  313,  317,  331,  337,  347,
                349,  353,  359,  367,  373,  379,  383,  389,  397,  401,  409,  419,  421,
                431,  433,  439,  443,  449,  457,  461,  463,  467,  479,  487,  491,  499,
                503,  509,  521,  523,  541,  547,  557,  563,  569,  571,  577,  587,  593,
                599,  601,  607,  613,  617,  619,  631,  641,  643,  647,  653,  659,  661,
                673,  677,  683,  691,  701,  709,  719,  727,  733,  739,  743,  751,  757,
                761,  769,  773,  787,  797,  809,  811,  821,  823,  827,  829,  839,  853,
                857,  859,  863,  877,  881,  883,  887,  907,  911,  919,  929,  937,  941,
                947,  953,  967,  971,  977,  983,  991,  997, 1009, 1013, 1019, 1021, 1031,
               1033, 1039, 1049, 1051, 1061, 1063, 1069, 1087, 1091, 1093, 1097, 1103, 1109,
               1117, 1123, 1129, 1151, 1153, 1163, 1171, 1181, 1187, 1193, 1201, 1213, 1217,
               1223, 1229, 1231, 1237, 1249, 1259, 1277, 1279, 1283, 1289, 1291, 1297, 1301,
               1303, 1307, 1319, 1321, 1327, 1361, 1367, 1373, 1381, 1399, 1409, 1423, 1427,
               1429, 1433, 1439, 1447, 1451, 1453, 1459, 1471, 1481, 1483, 1487, 1489, 1493,
               1499, 1511, 1523, 1531, 1543, 1549, 1553, 1559, 1567, 1571, 1579, 1583, 1597,
               1601, 1607, 1609, 1613, 1619, 1621, 1627, 1637, 1657, 1663, 1667, 1669, 1693,
               1697, 1699, 1709, 1721, 1723, 1733, 1741, 1747, 1753, 1759, 1777, 1783, 1787,
               1789, 1801, 1811, 1823, 1831, 1847, 1861, 1867, 1871, 1873, 1877, 1879, 1889,
               1901, 1907, 1913, 1931, 1933, 1949, 1951, 1973, 1979, 1987, 1993, 1997, 1999,
               2003, 2011, 2017, 2027, 2029, 2039, 2053, 2063, 2069, 2081, 2083, 2087, 2089,
               2099, 2111, 2113, 2129, 2131, 2137, 2141, 2143, 2153, 2161, 2179, 2203, 2207,
               2213, 2221, 2237, 2239, 2243, 2251, 2267, 2269, 2273, 2281, 2287, 2293, 2297,
               2309, 2311, 2333, 2339, 2341, 2347, 2351, 2357, 2371, 2377, 2381, 2383, 2389,
               2393, 2399, 2411, 2417, 2423, 2437, 2441, 2447, 2459, 2467, 2473, 2477, 2503,
               2521, 2531, 2539, 2543, 2549, 2551, 2557, 2579, 2591, 2593, 2609, 2617, 2621,
               2633, 2647, 2657, 2659, 2663, 2671, 2677, 2683, 2687, 2689, 2693, 2699, 2707,
               2711, 2713, 2719, 2729, 2731, 2741, 2749, 2753, 2767, 2777, 2789, 2791, 2797,
               2801, 2803, 2819, 2833, 2837, 2843, 2851, 2857, 2861, 2879, 2887, 2897, 2903,
               2909, 2917, 2927, 2939, 2953, 2957, 2963, 2969, 2971, 2999, 3001, 3011, 3019,
               3023, 3037, 3041, 3049, 3061, 3067, 3079, 3083, 3089, 3109, 3119, 3121, 3137,
               3163, 3167, 3169, 3181, 3187, 3191, 3203, 3209, 3217, 3221, 3229, 3251, 3253,
               3257, 3259, 3271, 3299, 3301, 3307, 3313, 3319, 3323, 3329, 3331, 3343, 3347,
               3359, 3361, 3371, 3373, 3389, 3391, 3407, 3413, 3433, 3449, 3457, 3461, 3463,
               3467, 3469, 3491, 3499, 3511, 3517, 3527, 3529, 3533, 3539, 3541, 3547, 3557,
               3559, 3571, 3581, 3583, 3593, 3607, 3613, 3617, 3623, 3631, 3637, 3643, 3659,
               3671, 3673, 3677, 3691, 3697, 3701, 3709, 3719, 3727, 3733, 3739, 3761, 3767,
               3769, 3779, 3793, 3797, 3803, 3821, 3823, 3833, 3847, 3851, 3853, 3863, 3877,
               3881, 3889, 3907, 3911, 3917, 3919, 3923, 3929, 3931, 3943, 3947, 3967, 3989
               ] 

exp = 10 
n_base = 10**exp # 1 followed by 10 digits or 11 digit primes.
if not last_line:
        n = (n_base // 210) * 210  # Align to nearest 210 multiple
else:
        n = (last_line // 210) * 210
print(n)


n_residues   = {} # initalized the residues dictionary
residues_210 = {} # initalized the residues for wheel size of 210
for prime in some_primes:
    n_residues[prime]   = n    % prime;
    residues_210[prime] = 210  % prime

# with open(primes_file + "-testing", "a") as f:
with open(primes_file, "a") as f:
    # f.write(f"{n}\n")
    # f.close()
    
    stop = 10**exp + ( 210 * 10000000 )
    counter = 0
    while n <= stop:
        print(f"n starting with n at {n}.")
        for r in wheel_residues:
            candidate = n + r
            print(f" ---- primality_test starting on wheel residue {r:3d} -> {candidate}.")
            skip = ( candidate <= last_line )
            for prime in some_primes:
                if ( ( n_residues[prime] + r ) % prime == 0 ):
                    skip = True
                    print(f" -* candidate is skipped due to candidate % {prime} == 0")
                    break
            if skip:
                continue
            if time_primality_test(miller_rabin_primality_test, candidate, k=5):
                f.write(f"{candidate}\n")
                print(f" ** miller_rabin probable prime found {candidate}")
            print()
        counter += 1
        if counter % 100 == 0:
            f.flush()
            # print("--- FLUSH! ---")
        n += 210  # Move to the next set of candidates
        for prime in some_primes:
            n_residues[prime] = ( n_residues[prime] + residues_210[prime] ) % prime


