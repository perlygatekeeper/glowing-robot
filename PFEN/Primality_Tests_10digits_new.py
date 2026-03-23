import random
import time
import math
import sys
import gmpy2
import inspect
import os

# generate all 10-digit prime_numbers
# 
# Modded to use Lucas test conditionally, now set to False and up the number of Trail Primes from
# 10_000 to 1_000_000

sys.set_int_max_str_digits(10**6)  # Required to print/convert 100,000-digit integers

VERBOSE    = False  # Set to True for detailed per-candidate output
USE_LUCAS  = False  # Set to True to run full Baillie-PSW (MR + Lucas-Selfridge)
                    # Set to False for Miller-Rabin k=5 only (faster, still extremely reliable)

# Confirm gmpy2 is actually being used — sanity check at startup:
print(f"gmpy2 version: {gmpy2.version()}")
n_test = gmpy2.mpz(123)
print(f"Type check: {type(n_test)}")  # Should show <class 'mpz'>

# ---------------------------------------------------------------------------
# Utility
# ---------------------------------------------------------------------------

def time_primality_test(test_function, n, **kwargs):
    """Wrapper to time a primality test function. Passes any keyword args to the function."""
    start_time = time.time()
    sig = inspect.signature(test_function)
    valid_kwargs = {k: v for k, v in kwargs.items() if k in sig.parameters}
    result = test_function(n, **valid_kwargs)
    elapsed_time = time.time() - start_time
    if VERBOSE:
        print(f"  {test_function.__name__} took {elapsed_time:.6f}s -> {'probable prime' if result else 'composite'}")
    return result, elapsed_time


# ---------------------------------------------------------------------------
# Primality tests
# ---------------------------------------------------------------------------

def fermat_primality_test(n, k=5):
    """
    Fermat primality test on n using k iterations.
    WARNING: Susceptible to Carmichael numbers — use Miller-Rabin or BPSW in practice.
    Included for reference/comparison only.
    """
    if n < 2:
        return False
    if n in (2, 3):
        return True
    if n % 2 == 0:
        return False
    n = gmpy2.mpz(n)
    for _ in range(k):
        a = gmpy2.mpz(random.randint(2, int(n) - 2))
        if gmpy2.powmod(a, n - 1, n) != 1:
            return False
    return True


def miller_rabin_primality_test(n, k=5):
    """
    Miller-Rabin primality test on n using k random bases.
    Uses gmpy2.mpz throughout for maximum GMP-accelerated performance.
    """
    if n < 2:
        return False
    if n in (2, 3):
        return True
    if n % 2 == 0:
        return False

    n = gmpy2.mpz(n)

    # Write n-1 as 2^r * d
    r, d = 0, n - 1
    while d % 2 == 0:
        r += 1
        d //= 2

    for _ in range(k):
        a = gmpy2.mpz(random.randint(2, int(n) - 2))
        x = gmpy2.powmod(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = gmpy2.powmod(x, 2, n)
            if x == n - 1:
                break
        else:
            return False  # Definitely composite
    return True  # Probably prime


def lucas_selfridge_test(n):
    """
    Strong Lucas probable prime test using Selfridge's parameter selection.
    This is the second half of the Baillie-PSW test.

    All big-integer arithmetic is done via gmpy2.mpz so GMP handles
    Karatsuba/FFT multiplication — critical for 100,000-digit numbers.

    Algorithm:
      1. Find D via Selfridge's sequence 5,-7,9,-11,... until Jacobi(D,n)=-1
      2. Set P=1, Q=(1-D)/4
      3. Compute strong Lucas sequence U, V at index delta = n+1
         using the binary ladder method (double-and-add)
      4. Check strong Lucas conditions
    """
    n = gmpy2.mpz(n)

    # Step 1: Find D via Selfridge's sequence 5, -7, 9, -11, 13, ...
    D = gmpy2.mpz(5)
    sign = 1
    D_signed = gmpy2.mpz(0)
    for _ in range(100):
        D_signed = gmpy2.mpz(sign * D)
        j = gmpy2.jacobi(D_signed, n)
        if j == -1:
            break
        if j == 0 and abs(D_signed) < n:
            return False  # GCD(D, n) > 1 => composite
        D += 2
        sign = -sign
    else:
        return False  # Could not find suitable D (astronomically unlikely)

    P  = gmpy2.mpz(1)
    Q  = gmpy2.mpz((1 - int(D_signed)) // 4)  # Selfridge: Q = (1 - D) / 4

    # delta = n - Jacobi(D,n) = n + 1  (since Jacobi = -1)
    delta = n + 1

    # Write delta = 2^s * d_odd
    s = 0
    d_odd = delta
    while d_odd % 2 == 0:
        s += 1
        d_odd //= 2

    # --- Binary ladder (double-and-add) entirely in gmpy2.mpz ---
    # State: (U_k, V_k, Q^k mod n)

    def lucas_double(U, V, Qk):
        """Double index: (U_k, V_k, Qk) -> (U_{2k}, V_{2k}, Q^{2k})"""
        U2  = U * V % n
        V2  = (V * V - 2 * Qk) % n
        Qk2 = Qk * Qk % n
        return U2, V2, Qk2

    def lucas_add1(U, V, Qk):
        """Increment index by 1: (U_k, V_k, Qk) -> (U_{k+1}, V_{k+1}, Q^{k+1})"""
        U1 = (P * U + V) % n
        if U1 % 2 != 0:
            U1 += n
        U1 = gmpy2.divexact(U1, gmpy2.mpz(2))

        V1 = (D_signed * U + P * V) % n
        if V1 % 2 != 0:
            V1 += n
        V1 = gmpy2.divexact(V1, gmpy2.mpz(2))

        Qk1 = Qk * Q % n
        return U1, V1, Qk1

    # Initialise at index 1
    U  = gmpy2.mpz(1)
    V  = gmpy2.mpz(P)
    Qk = gmpy2.mpz(Q) % n

    # Walk the bits of d_odd from MSB-1 down to 0
    nbits = int(d_odd).bit_length()
    for i in range(nbits - 2, -1, -1):
        U, V, Qk = lucas_double(U, V, Qk)
        if (d_odd >> i) & 1:
            U, V, Qk = lucas_add1(U, V, Qk)

    # Strong Lucas primality conditions
    if U % n == 0 or V % n == 0:
        return True  # Probable prime

    for _ in range(s - 1):
        U, V, Qk = lucas_double(U, V, Qk)
        if V % n == 0:
            return True  # Probable prime

    return False  # Composite


def is_probable_prime(n):
    """
    Primality test dispatcher controlled by USE_LUCAS flag.

    USE_LUCAS=False : Miller-Rabin k=5 only
                      Fast; no known pseudoprimes at 100K-digit scale.
    USE_LUCAS=True  : Full Baillie-PSW — MR k=3 + Lucas-Selfridge
                      Slower; no known counterexamples to BPSW at any scale.
    """
    if n < 2:
        return False
    if n in (2, 3, 5):
        return True
    if n % 2 == 0 or n % 3 == 0 or n % 5 == 0:
        return False

    if not USE_LUCAS:
        return miller_rabin_primality_test(n, k=5)

    # Full Baillie-PSW: MR first to cheaply eliminate most composites
    if not miller_rabin_primality_test(n, k=3):
        return False
    return lucas_selfridge_test(n)


# ---------------------------------------------------------------------------
# Wheel factorisation — mod 210 = 2 x 3 x 5 x 7
# The 48 residues coprime to 210.
# Note: 121=11², 143=11×13, 169=13², 187=11×17 are coprime to 210 but
# composite — they are filtered by TRIAL_PRIMES before any MR/Lucas call.
# ---------------------------------------------------------------------------
WHEEL_RESIDUES = [
      1,  11,  13,  17,  19,  23,  29,  31,  37,  41,  43,  47,
     53,  59,  61,  67,  71,  73,  79,  83,  89,  97, 101, 103,
    107, 109, 113, 121, 127, 131, 137, 139, 143, 149, 151, 157,
    163, 167, 169, 173, 179, 181, 187, 191, 193, 197, 199, 209
]

def build_trial_primes(limit):
    sieve = bytearray([1]) * (limit + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            sieve[i*i::i] = bytearray(len(sieve[i*i::i]))
    return [i for i in range(11, limit + 1) if sieve[i]]


# ---------------------------------------------------------------------------
NUM_DIGITS   = 10
OUTPUT_FILE  = f"10_digit_primes_{os.getpid()}.txt"
REPORT_EVERY = 210*100
run_start_time = time.time()

exp = 10 
n_base = 2 * 10**(exp-1)
stop   = 3 * 10**(exp-1)
n = ( (n_base // 210) ) * 210  # Align n to a multiple of 210

# stop = n_base + 5000   # this is for testing
TRIAL_PRIMES = build_trial_primes( int(math.sqrt(stop)) + 1 )
# TRIAL_PRIMES = build_trial_primes(999_999)

print("start:{} -> end:{stop}")
wheel_steps         = 0
START_RESIDUE       = 1
candidates_tested   = 0
candidates_sieved   = 0
candidates_rejected = 0
primes_found        = 2
time_total          = 0.0

n_residues   = {} # initalized the residues dictionary
residues_210 = {} # initalized the residues for wheel size of 210
n_residues       = {p: int(n   % p) for p in TRIAL_PRIMES}
residues_210     = {p: int(210 % p) for p in TRIAL_PRIMES}
sieve_hit_counts = {p: 0            for p in TRIAL_PRIMES}

test_label = "Baillie-PSW (MR k=3 + Lucas-Selfridge)" if USE_LUCAS else "Miller-Rabin k=5"
print(f"Target:  find all {exp}-digit prime numbers")
print(f"Sieve:   {len(TRIAL_PRIMES)} trial primes (11..{TRIAL_PRIMES[-1]})")
print(f"Wheel:   mod 210, {len(WHEEL_RESIDUES)} residues per cycle")
print(f"Test:    {test_label}")
print(f"Verbose: {'ON' if VERBOSE else 'OFF'}")
print()

with open("Data/10_digit_probable_primes_2.txt", "w") as f:
    while n <= stop:
        print(f"n: {n} found {primes_found} primes so far.")
        for r in WHEEL_RESIDUES:
            candidate = n + r
            if (candidate <= n_base):
                continue
            candidates_tested += 1
            if VERBOSE:
                print(f" -- primality_test starting on wheel residue {r} -> {candidate}.")
            sieved_out = False
            for prime in TRIAL_PRIMES:
                if ( ( n_residues[prime] + r ) % prime == 0 ):
                    sieved_out = True
                    if VERBOSE:
                        print(f" -* candidate is skipped due to {candidate} % {prime} == 0")
                    break
            if sieved_out:
                continue
            primes_found += 1
            if primes_found % 9 != 0:
                f.write(f"{candidate} ")
            else:
                f.write(f"{candidate}\n")
            # if time_primality_test(miller_rabin_primality_test, candidate, k=5):
            #     print(f" ** miller_rabin probable prime found {candidate}")
            #     if candidates_tested % 7 == 0:
            #         f.write(f"{candidate} ")
            #     else:
            #         f.write(f"{candidate}\n")
            # else:
            #     print(f" @@ miller_rabin REJECTED {candidate}")
        n += 210  # Move to the next set of candidates
        for prime in TRIAL_PRIMES:
            n_residues[prime] = ( n_residues[prime] + residues_210[prime] ) % prime

#           result, elapsed = time_primality_test(is_probable_prime, candidate)
#           test_time_total += elapsed
#           elapsed_total = time.time() - run_start_time
#           print(f"\n*** Probable prime found!")
#           print(f"    Test             : {test_label}")

    print(f"Search complete: found {primes_found} primes")

# ---------------------------------------------------------------------------

