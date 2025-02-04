from db_module import get_number_db, get_prime_db

numbers_db = get_number_db()
primes_db = get_prime_db()

print(numbers_db.get_number(30))
print(primes_db.get_prime_by_sequence(10))

