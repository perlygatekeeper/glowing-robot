import math
from db_module import get_number_db, get_prime_db, get_primefactor_db
prime_db = get_prime_db()
primefactor_db = get_primefactor_db(prime_db)
number_db = get_number_db()

def factorize_number(n, prime_lookup):
    """
    Factorizes a number into its prime factors using the primes in prime_lookup.
    Returns a dictionary {prime_id: exponent}.
    """
    factors = {}
    original_n = n
    root_n = math.isqrt(n)
    for prime in sorted(prime_lookup.keys()):  # Iterate over known primes
        if prime > root_n:  # Stop if prime is greater than sqrt(n)
            break
        exponent = 0
        while n % prime == 0:
            n //= prime
            exponent += 1
        if exponent > 0:
            factors[prime_lookup[prime]] = exponent  # Store prime_id, exponent
    if n > 1:  # If there's a remaining prime factor (n itself is prime)
        factors[prime_lookup[n]] = 1  
    return factors

def process_numbers(start, end):
    for num in range(start, end + 1):
        # Check if the number is already in the database
        number_entry = number_db.get_number(num)

        # Check if number is prime
        if num in primefactor_db.prime_ids:
            continue

        if number_entry['total_factors'] != 0:
            continue  # Skip if the number is already processed

        else:
            # Factorize and insert into PrimeFactors
            factors = factorize_number(num, prime_db.prime_ids)
            total_factors = sum(factors.values())
            # print(f"{factors}")
            if not isinstance(factors, dict):
                    print(f"Unexpected return type from factorize_number: {type(factors)} -> {factors}")
            unique_factors = len(factors)
            # print("total factors: ", total_factors) 
            # print("unique factors: ", unique_factors) 
            # print("factors: ", factors) 
            if factors:  # If the number has prime factors, insert them
                number_id = number_db.insert_number(num, total_factors, unique_factors)
                primefactor_db.insert_primefactors(num, factors)
 
process_numbers(10000, 20000)
