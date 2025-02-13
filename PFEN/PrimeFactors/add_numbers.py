import math
from db_module import get_number_db, get_prime_db, get_primefactor_db

def factorize_number(n, prime_lookup):
    """
    Factorizes a number into its prime factors using the primes in prime_lookup.
    Returns a dictionary {prime_id: exponent}.
    """
    factors = {}
    original_n = n

    for prime in sorted(prime_lookup.keys()):  # Iterate over known primes
        if prime > math.isqrt(n):  # Stop if prime is greater than sqrt(n)
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
    prime_db = get_prime_db()
    primefactor_db = get_primefactor_db(prime_db)
    number_db = get_number_db()

    for num in range(start, end + 1):
        # Check if the number is already in the database
        existing_entry = number_db.get_number(num)
        if existing_entry:
            continue  # Skip if the number is already processed

        # Check if number is prime
        if num in prime_db.prime_ids:
            # Insert as a prime
            prime_id = prime_db.prime_ids[num]
            number_id = number_db.insert_number(num, 1, 1) # total_factors = 1 unique_factors = 1
            primefactor_db.insert_primefactors(num, {prime_id: 1})
        else:
            # Factorize and insert into PrimeFactors
            factors = factorize_number(num, prime_db.prime_ids)
            total_factors = sum(factors.values())
            if not isinstance(factors, dict):
                    print(f"Unexpected return type from factorize_number: {type(factors)} -> {factors}")
            unique_factors = len(factors)
            print("total factors: ", total_factors) 
            print("unique factors: ", unique_factors) 
            print("factors: ", factors) 
            if factors:  # If the number has prime factors, insert them
                number_id = number_db.insert_number(num, total_factors, unique_factors)
                primefactor_db.insert_primefactors(number_id, factors)
 
# Run the function for numbers 100000 to 200000
process_numbers(100000, 999999)
