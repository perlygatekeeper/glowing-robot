from db_module import get_number_db, get_prime_db, get_primefactor_db
prime_db = get_prime_db()
primefactor_db = get_primefactor_db(prime_db)
number_db = get_number_db()

def modify_prime_factor_without_checking(number, prime_id_to_modify, prime_to_modify):
    base_number = number / prime_to_modify
    base_prime_factors = primefactor_db.get_primefactors(base_number)
    factors_dict = {factor['prime_id']: factor['exponent'] for factor in base_prime_factors}

    if prime_id_to_modify in factors_dict:
        factors_dict[prime_id_to_modify] += 1  # Increment exponent for prime_id_to_modify, eg. 2
    else:
        factors_dict[prime_id_to_modify] = 1  # Add prime_id_to_modify^1 if not present

    # Recalculate total_factors and unique_factors
    total_factors  = sum(factors_dict.values())  # Sum of all exponents
    unique_factors = len(factors_dict)  # Number of distinct prime factors

    primefactor_db.insert_primefactors(number, factors_dict)
    number_db.insert_number(number, total_factors, unique_factors)

    print(f"Inserted prime factors for {number}: Added or incremented factor of {prime_to_modify} from {base_number}.")
    print(f"Updated numbers table: total_factors={total_factors}, unique_factors={unique_factors}.")

# Get prime_id_to_modify
prime_to_modify = 19
prime_db = get_prime_db()
prime_id_to_modify = prime_db.prime_ids.get(prime_to_modify)
if not prime_id_to_modify:
    print("Error: Prime number {prime_id_to_modify} not found in the primes table.")

sql = f"""
SELECT n.number FROM numbers n
WHERE n.number BETWEEN 2000000 AND 10000000
AND n.number % {prime_to_modify} = 0 AND n.total_factors = 0;
"""
print(sql)
numbers_needed = number_db.query(sql);
# print(numbers_needed)
# exit()

# Example usage
# for number in range(1428571, 285714, -1):
#    modify_prime_factor(number, prime_id_to_modify, prime_to_modify)
for number in numbers_needed:
    modify_prime_factor_without_checking(number['number'], prime_id_to_modify, prime_to_modify)
