import gmpy2

n = gmpy2.mpz(open("25K").read())

print(gmpy2.is_prime(n, 50))
