from db_module import get_number_db, get_prime_db, get_primefactor_db

def modify_prime_factor(number, prime_id_to_modify, prime_to_modify):
    prime_db = get_prime_db()
    primefactor_db = get_primefactor_db(prime_db)
    number_db = get_number_db()

    # Retrieve number details
    number_entry = number_db.get_number(number)
    if not number_entry:
        print(f"Number {number} not found in the database.")
        return

    number_id = number_entry['number_id']

    # Retrieve prime factors for the number
    prime_factors = primefactor_db.get_primefactors(number_id)

    new_number = number * prime_to_modify
    new_number_entry = number_db.get_number( new_number )

    # Retrieve number details
    if number_entry['total_factors'] != 0:
        print(f"Number {new_number} already in the database.")
        return
    else:
        new_number_id = new_number_entry['number_id']

    # Convert result to a dictionary {prime_id: exponent}
    factors_dict = {factor['prime_id']: factor['exponent'] for factor in prime_factors}

    # Modify the prime factorization
    if prime_id_to_modify in factors_dict:
        factors_dict[prime_id_to_modify] += 1  # Increment exponent for prime_id_to_modify, eg. 2
    else:
        factors_dict[prime_id_to_modify] = 1  # Add prime_id_to_modify^1 if not present

    # Update the prime_factors table with modified factors
    primefactor_db.insert_primefactors(new_number_id, factors_dict)

    # Recalculate total_factors and unique_factors
    total_factors = sum(factors_dict.values())  # Sum of all exponents
    unique_factors = len(factors_dict)  # Number of distinct prime factors

    # Update the numbers table
    number_db.insert_number(new_number_id, total_factors, unique_factors)

    if ( number % 100 == 0 ):
        print(f"Inserted prime factors for {new_number_id}: Added or incremented factor of {prime_to_modify} from {number_id}.")
        print(f"Updated numbers table: total_factors={total_factors}, unique_factors={unique_factors}.")

# Get prime_id_to_modify
prime_to_modify = 11
prime_db = get_prime_db()
prime_id_to_modify = prime_db.prime_ids.get(prime_to_modify)
if not prime_id_to_modify:
    print("Error: Prime number {prime_id_to_modify} not found in the primes table.")
# Example usage
for number in range(909090, 181818, -1):
    modify_prime_factor(number, prime_id_to_modify, prime_to_modify)
