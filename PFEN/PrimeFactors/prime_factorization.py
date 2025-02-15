def prime_factorization(n):
    """Finds the prime factorization of a given integer."""
    factors = []
    i = 2
    while i * i <= n:
        if n % i == 0:
            factors.append(i)
            n //= i
        else:
            i += 1
    if n > 1:
           factors.append(n)
    return factors


