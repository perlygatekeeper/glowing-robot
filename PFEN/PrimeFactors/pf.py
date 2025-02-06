from db_module import get_number_db, get_prime_db, get_primefactor_db

numbers_db      = get_number_db()
primes_db       = get_prime_db()
primefactors_db = get_primefactor_db()

print(numbers_db.get_number(30))
print(primes_db.get_prime_by_sequence(10))
print(primefactors_db.get_primefactors(210))

