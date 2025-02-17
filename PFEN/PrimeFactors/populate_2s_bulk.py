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
prime_to_modify = 2
prime_db = get_prime_db()
prime_id_to_modify = prime_db.prime_ids.get(prime_to_modify)
if not prime_id_to_modify:
    print("Error: Prime number {prime_id_to_modify} not found in the primes table.")
sql = f"""
SELECT n.number, n.total_factors, n.unique_factors, pf.prime_id, pf.exponent
FROM Numbers n
JOIN PrimeFactors pf ON n.number_id = pf.number_id
WHERE n.number BETWEEN 12 AND 15
ORDER BY n.number;
"""
# WHERE n.number BETWEEN 2500001 AND 10000000
prime_factors = number_db.query(sql);
BaseNumbers = {}
for row in prime_factors:
    num = row['number']
    # If the number is NOT already in the dictionary, initialize it
    if num not in BaseNumbers:
        BaseNumbers[num] = {
            'total_factors':  row['total_factors'],
            'unique_factors': row['unique_factors'],
            'primefactors': {}
        }
    # Add prime factors
    BaseNumbers[num]['primefactors'][row['prime_id']] = row['exponent']
from pprint import pprint
# pprint(BaseNumbers)
# print()

EvenNumbers = {}
for num, num_details in BaseNumbers.items():
   even_num = num * prime_to_modify
   EvenNumbers[even_num] = BaseNumbers[num]
   if num % prime_to_modify == 0:
      EvenNumbers[even_num]['total_factors'] = num_details['total_factors'] + 1
      EvenNumbers[even_num]['primefactors'][prime_id_to_modify] += 1 
   else:
      EvenNumbers[even_num]['total_factors']  = num_details['total_factors'] + 1
      EvenNumbers[even_num]['unique_factors'] = num_details['unique_factors'] + 1
      EvenNumbers[even_num]['primefactors'][prime_id_to_modify] = 1
# pprint(EvenNumbers)
# exit()


"""
1) Get the primefactors in batches of 1000 or more, for numbers between 2,500,001 and 5,000,000
   here-after called the "Base Numbers"
2) Modify the numbers and primefactors all to add a factor of 2. ( essentually doubling them)
   here-after called the "Even Numbers"
3) Modify the total_factors and the unique_factors for the new Even number.
3) Insert the new numbers and their modified prime factors into the primefactors table
Store result of query in 
Numbers{number_id} =
{
    'total_factors':  total_factors,
    'unique_factors': unique_factors,
    'primefactors':  {
       prime_id: exponent,
       prime_id: exponent,
       prime_id: exponent,
       .
       .
       .
    } 
}
"""
