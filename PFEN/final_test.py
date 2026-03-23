import gmpy2

n = gmpy2.mpz(open("100K_digit_probable_primes.txt").read())

print(gmpy2.is_prime(n, 50))
