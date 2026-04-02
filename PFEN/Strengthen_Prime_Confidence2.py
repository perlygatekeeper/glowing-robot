#!/usr/bin/env python3

import sys
import time
import random

# allow printing very large integers if needed (Python 3.11+)
if hasattr(sys, "set_int_max_str_digits"):
    sys.set_int_max_str_digits(10**7)


def read_bigint(filename):
    with open(filename, "r") as f:
        s = f.read().strip()
    return int(s)


def miller_rabin(n, rounds=20):
    if n < 2:
        return False
    small_primes = [
        2,3,5,7,11,13,17,19,23,29,
        31,37,41,43,47
    ]
    for p in small_primes:
        if n % p == 0:
            return n == p
    d = n - 1
    s = 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for _ in range(rounds):
        a = random.randrange(2, n - 2)
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(s - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True


def jacobi(a, n):
    if n <= 0 or n % 2 == 0:
        return 0
    result = 1
    a = a % n
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3,5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


def lucas_test(n):
    # --- Correct Selfridge D selection ---
    D = 5
    while jacobi(D, n) != -1:
        D = -(D + 2) if D > 0 else -(D - 2)

    P = 1
    Q = (1 - D) // 4

    # n + 1 = d * 2^s
    d = n + 1
    s = 0
    while d % 2 == 0:
        d //= 2
        s += 1

    # Lucas sequence
    U = 1
    V = P
    Qk = Q

    # --- Correct bit handling ---
    bits = bin(d)[2:]  # full binary
    for bit in bits[1:]:  # skip leading 1
        # doubling step
        U = (U * V) % n
        V = (V * V - 2 * Qk) % n
        Qk = (Qk * Qk) % n

        # addition step
        if bit == "1":
            U_temp = (P * U + V) % n
            V_temp = (D * U + P * V) % n

            # divide by 2 modulo n (safe since n is odd)
            inv2 = (n + 1) // 2
            U = (U_temp * inv2) % n
            V = (V_temp * inv2) % n

            Qk = (Qk * Q) % n

    if U == 0:
        return True

    for _ in range(s):
        V = (V * V - 2 * Qk) % n
        Qk = (Qk * Qk) % n
        if V == 0:
            return True

    return False


def baillie_psw(n):
    if not miller_rabin(n, rounds=1):
        return False
    return lucas_test(n)


def main():

    if len(sys.argv) < 2:
        print("Usage: python verify_large_prime_fixed.py number.txt")
        # testing lucas 
        print("\nWill test lucas on several small primes...")
        print("prime: 101 ")
        print(lucas_test(101))
        print("prime: 1009 ")
        print(lucas_test(1009))
        print("prime: 10007 ")
        print(lucas_test(10007))
        return

    filename = sys.argv[1]

    print("Reading number...")
    n = read_bigint(filename)

    digits = len(str(n))
    print("Digits:", digits)

    start = time.time()

    print("\nRunning Miller-Rabin (25 rounds)...")
    mr = miller_rabin(n, rounds=25)

    mid = time.time()

    print("Result:", "Probable Prime" if mr else "Composite")
    print("MR time:", mid - start, "seconds")

    print("\nRunning Baillie-PSW test...")
    bpsw = baillie_psw(n)

    end = time.time()

    print("Result:", "Probable Prime" if bpsw else "Composite")
    print("BPSW time:", end - mid, "seconds")

    print("\nTotal time:", end - start, "seconds")


if __name__ == "__main__":
    main()
