#!/usr/bin/env python3

import gmpy2

n = gmpy2.mpz(open('Data/100K_digit_probable_prime.txt').read())

print(gmpy2.is_prime(n, 50))

