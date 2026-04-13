#!/usr/bin/env python3 -u
import sys
import time
import random

if hasattr(sys, "set_int_max_str_digits"):
    sys.set_int_max_str_digits(10**7)


def read_bigint(filename):
    print(f"Reading number from file: '{filename}' ...")
    with open(filename, "r") as f:
        s = f.read().strip()
    n = int(s)
    digits = len(s)
    print(f"  Read complete: {digits} digits")
    print(f"  First 20 digits : {s[:20]}...")
    print(f"  Last  20 digits : ...{s[-20:]}")
    return n


def miller_rabin(n, rounds=20):
    if n < 2:
        return False
    small_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    for p in small_primes:
        if n % p == 0:
            return n == p

    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1

    print(f"  Miller-Rabin parameters: n-1 = d * 2^s,  s={s},  d has {len(bin(d))-2} bits")

    for i in range(rounds):
        a = random.randrange(2, n - 2)
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(s - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            print(f"  Miller-Rabin: COMPOSITE witness found at round {i+1}")
            return False

    print(f"  Miller-Rabin: passed all {rounds} rounds — probable prime")
    return True


def jacobi(a, n):
    if n <= 0 or n % 2 == 0:
        return 0
    result = 1
    a = a % n
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


def lucas_test(n):
    # Early exits for small/even values that break the D search
    if n < 2:
        return False
    if n in (2, 3, 5):
        return True
    if n % 2 == 0:
        return False

    # --- Selfridge D selection ---
    # Sequence: 5, -7, 9, -11, 13, -15, ...
    D = 5
    sign = 1
    iterations = 0
    while True:
        Ds = sign * D
        j = jacobi(Ds, n)
        if j == -1:
            break
        if j == 0:
            # gcd(D, n) > 1 → composite
            print(f"  Lucas: Jacobi(D={Ds}, n) == 0 → composite (shared factor)")
            return False
        D    += 2
        sign  = -sign
        iterations += 1
        if iterations > 1000:
            raise ValueError("Lucas: failed to find suitable D after 1000 iterations")

    P = 1
    Q = (1 - Ds) // 4
    print(f"  Lucas: Selfridge parameters  D={Ds},  P={P},  Q={Q}  (found in {iterations+1} step(s))")

    # --- Write n+1 = d * 2^s ---
    d = n + 1
    s = 0
    while d % 2 == 0:
        d //= 2
        s += 1
    print(f"  Lucas: n+1 = d * 2^s,  s={s},  d has {len(bin(d))-2} bits")

    # --- Binary ladder: compute U_d, V_d, Q^d (mod n) ---
    U  = 1
    V  = P
    Qk = Q % n

    bits = bin(d)[2:]
    print(f"  Lucas: running binary ladder over {len(bits)} bits of d ...")

    for bit in bits[1:]:
        # Doubling step
        U  = (U * V) % n
        V  = (V * V - 2 * Qk) % n
        Qk = (Qk * Qk) % n

        if bit == "1":
            # Addition step — divide by 2 mod n via inv2 = (n+1)//2
            inv2  = (n + 1) // 2
            U_new = (P * U + V) % n
            V_new = (Ds * U + P * V) % n
            U     = (U_new * inv2) % n
            V     = (V_new * inv2) % n
            Qk    = (Qk * Q) % n

    print(f"  Lucas: ladder complete — checking strong Lucas conditions ...")

    # Condition (a): U_d ≡ 0 (mod n)
    if U % n == 0:
        print(f"  Lucas: U_d ≡ 0 (mod n)  → probable prime  [condition a]")
        return True
    # Condition (b): V_d ≡ 0 (mod n)
    if V % n == 0:
        print(f"  Lucas: V_d ≡ 0 (mod n)  → probable prime  [condition b]")
        return True

    # Condition (c): V_{d*2^r} ≡ 0 for r = 1 .. s-1
    for r in range(1, s):
        V  = (V * V - 2 * Qk) % n
        Qk = (Qk * Qk) % n
        if V % n == 0:
            print(f"  Lucas: V_{{d*2^{r}}} ≡ 0 (mod n)  → probable prime  [condition c, r={r}]")
            return True

    print(f"  Lucas: no strong Lucas condition satisfied → COMPOSITE")
    return False


def baillie_psw(n):
    print("  BPSW step 1: single Miller-Rabin round ...")
    if not miller_rabin(n, rounds=1):
        return False
    print("  BPSW step 2: strong Lucas-Selfridge test ...")
    return lucas_test(n)


def self_test():
    print("--- Self-test on small known values ---")
    test_cases = [
        (2,    True),  (3,    True),  (5,    True),
        (101,  True),  (1009, True),  (10007, True),
        (7919, True),  (7920, False), (561,  False),   # 561 = Carmichael
        (1105, False),                                  # 1105 = Carmichael
    ]
    all_ok = True
    for val, expected in test_cases:
        got = baillie_psw(val)
        status = "OK" if got == expected else "FAIL"
        if got != expected:
            all_ok = False
        print(f"  n={val:<6}  expected={'prime' if expected else 'composite':<9}  "
              f"got={'prime' if got else 'composite':<9}  [{status}]")
    print("--- Self-test", "PASSED" if all_ok else "FAILED", "---\n")
    return all_ok


def main():
    if len(sys.argv) < 2:
        print("Usage: python verify_prime.py <number_file.txt>")
        print()
        self_test()
        return

    filename = sys.argv[1]
    print("=" * 60)
    n = read_bigint(filename)
    print("=" * 60)

    # ---- Miller-Rabin (standalone, 25 rounds) ----
    # print(f"\n[Test 1]  Miller-Rabin  (25 rounds)")
    # print("-" * 40)
    # t0 = time.time()
    # mr_result = miller_rabin(n, rounds=1)
    # t1 = time.time()
    # print(f"  Verdict : {'Probable Prime' if mr_result else 'COMPOSITE'}")
    # print(f"  Time    : {t1 - t0:.3f} s")

    # ---- Baillie-PSW ----
    print(f"\n[Test 2]  Baillie-PSW  (MR x1 + Lucas-Selfridge)")
    print("-" * 40)
    t2 = time.time()
    bpsw_result = baillie_psw(n)
    t3 = time.time()
    print(f"  Verdict : {'Probable Prime' if bpsw_result else 'COMPOSITE'}")
    print(f"  Time    : {t3 - t2:.3f} s")

    # ---- Summary ----
    print("\n" + "=" * 60)
    # print(f"  Miller-Rabin (25 rounds) : {'Probable Prime' if mr_result else 'COMPOSITE'}")
    print(f"  Baillie-PSW              : {'Probable Prime' if bpsw_result else 'COMPOSITE'}")
    print(f"  Total wall time          : {t3 - t0:.3f} s")
    print("=" * 60)


if __name__ == "__main__":
    main()
