import sys
import time
import random
import gmpy2

mpz = gmpy2.mpz

if hasattr(sys, "set_int_max_str_digits"):
    sys.set_int_max_str_digits(10**7)


def read_bigint(filename):
    print("Reading number from file...")
    with open(filename, "r") as f:
        s = f.read().strip()

    print("Digits:", len(s))
    print("Converting to GMP integer...")
    n = mpz(s)

    print("Conversion complete\n")
    return n


def miller_rabin_verbose(n, rounds=25):

    print("Preparing Miller–Rabin")

    d = n - 1
    s = 0

    while d % 2 == 0:
        d //= 2
        s += 1

    print(f"n-1 = d * 2^{s}")
    print()

    start = time.time()

    for i in range(1, rounds + 1):

        a = mpz(random.randrange(2, int(n-2)))

        print(f"[MR {i}/{rounds}] base last digits: {a % 1000000}")

        x = gmpy2.powmod(a, d, n)

        if x == 1 or x == n - 1:
            print("  passed initial check")
            continue

        for j in range(s - 1):

            x = gmpy2.powmod(x, 2, n)

            if x == n - 1:
                print(f"  passed loop step {j+1}")
                break
        else:
            print("  composite detected")
            return False

    end = time.time()

    print("\nMiller–Rabin finished")
    print("Time:", end - start, "seconds\n")

    return True


def lucas_verbose(n):

    print("Starting Lucas test (Baillie–PSW)")

    start = time.time()

    D = 5
    attempts = 0

    while gmpy2.jacobi(D, n) != -1:

        attempts += 1
        D = -D + 2 if D > 0 else -D + 2

        if attempts % 10 == 0:
            print("  searching for D parameter...", attempts)

    print("Lucas parameter D =", D)

    P = mpz(1)
    Q = mpz((1 - D) // 4)

    d = n + 1
    s = 0

    while d % 2 == 0:
        d //= 2
        s += 1

    print("n+1 decomposition computed")

    U = mpz(1)
    V = P
    Qk = Q

    bits = bin(d)[3:]
    total_bits = len(bits)

    for i, bit in enumerate(bits, 1):

        if i % 5000 == 0:
            print(f"  Lucas progress: {i}/{total_bits} bits")

        U = (U * V) % n
        V = (V * V - 2 * Qk) % n
        Qk = (Qk * Qk) % n

        if bit == "1":
            U, V = (P*U + V) % n, (D*U + P*V) % n
            Qk = (Qk * Q) % n

    if U == 0:
        print("Lucas condition satisfied")
        return True

    for r in range(s):

        V = (V * V - 2 * Qk) % n
        Qk = (Qk * Qk) % n

        if V == 0:
            print("Lucas condition satisfied in doubling step")
            return True

    end = time.time()

    print("Lucas test finished")
    print("Time:", end - start, "seconds\n")

    return False


def main():

    if len(sys.argv) < 2:
        print("Usage:")
        print("python verify_large_prime_gmpy2_verbose.py candidate.txt")
        return

    n = read_bigint(sys.argv[1])

    print("===== Miller–Rabin =====\n")

    start = time.time()

    if not miller_rabin_verbose(n, 25):
        print("\nFINAL RESULT: COMPOSITE")
        return

    mid = time.time()

    print("Passed Miller–Rabin\n")

    print("===== Baillie–PSW Lucas Test =====\n")

    lucas = lucas_verbose(n)

    end = time.time()

    if lucas:
        print("\nFINAL RESULT: strong probable prime")
    else:
        print("\nFINAL RESULT: composite")

    print("\nTiming summary")
    print("  Miller–Rabin:", mid - start)
    print("  Lucas:", end - mid)
    print("  Total:", end - start)


if __name__ == "__main__":
    main()