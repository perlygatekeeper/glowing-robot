from db_module import get_number_db, get_prime_db, get_primefactor_db
prime_db = get_prime_db()
primefactor_db = get_primefactor_db(prime_db)
number_db = get_number_db()

def modify_prime_factor_without_checking(Numbers_to_add):
    for num in Numbers_to_add:
        primefactor_db.insert_primefactors(num, Numbers_to_add[num]['primefactors'])
        number_db.insert_number(num, Numbers_to_add[num]['total_factors'], Numbers_to_add[num]['unique_factors'])
    if num % 200 == 0:
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
WHERE n.number BETWEEN 2500001 AND 5000000
ORDER BY n.number;
"""
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
modify_prime_factor_without_checking(EvenNumbers)


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
