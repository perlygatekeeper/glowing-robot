from db_module import get_number_db, get_prime_db, get_primefactor_db

numbers_db      = get_number_db()
primes_db       = get_prime_db()
primefactors_db = get_primefactor_db(primes_db)

print("numbers_db.get_number(30):")
print(numbers_db.get_number(30))
print()

print("primes_db.get_prime_by_squence(10):")
print(primes_db.get_prime_by_sequence(10))
print()

print("primefactors_db.get_primefactors(210):")
print(primefactors_db.get_primefactors(210))
print()

primefactors    = [(2, 1), (3, 1), (5, 1)]
matching_number = primefactors_db.find_number_by_primefactors( primefactors )
print("Matching Number IDs:", matching_number)
print()

primefactor_ids = [(1, 1), (2, 1), (3, 1), (4, 1), (5,1)]
matching_number = primefactors_db.find_number_by_primefactor_ids( primefactor_ids )
print("Matching Number IDs:", matching_number)
