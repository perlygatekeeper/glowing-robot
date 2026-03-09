def primorial(p):
    """Product of all primes <= p, using a sieve."""
    limit = int(p)
    sieve = bytearray([1]) * (limit + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            sieve[i*i::i] = bytearray(len(sieve[i*i::i]))
    result = gmpy2.mpz(1)
    for i in range(2, limit + 1):
        if sieve[i]:
            result *= i
    return result

