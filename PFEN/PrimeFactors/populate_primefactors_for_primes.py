from db_module import get_number_db, get_prime_db, get_primefactor_db

# THIS SCRIPT will populate the primefactors table for all the primes in the 
# given rane - AND - update the numbers table to reflect the
# total_factors = 1 and unique_factors = 1 for the primes

def populate_prime_numbers(start, end):
    prime_db = get_prime_db()
    number_db = get_number_db()
    primefactor_db = get_primefactor_db(prime_db)

    # Fetch prime numbers in range
    primes = [p for p in prime_db.prime_ids.keys() if start <= p <= end]

    for prime in primes:
        # Insert the prime number into the numbers table
        number_db.insert_number(prime, total_factors=1, unique_factors=1)

        # Get number_id for the inserted prime
        number_entry = number_db.get_number(prime)
        if number_entry:
            number_id = number_entry['number_id']

            # Insert prime factor (itself with exponent 1)
            primefactor_db.insert_primefactors(number_id, {prime_db.prime_ids[prime]: 1})

    print(f"Inserted {len(primes)} prime numbers into the database.")

# Example usage: Populate primes between 100 and 2000
populate_prime_numbers(100000, 10000000)

