from db_module import get_number_db, get_prime_db, get_inv_primeorial_db

def populate_primeorial_table():
    number_db = get_number_db()
    primeDB = get_prime_db()
    inv_db = get_inv_primeorial_db(primeDB)
    primeorial = 1
    for prime in (2, 3, 5, 7, 11, 13, 17, 19):
        primeorial *= prime
        print(f"prime is {prime}; primeorial is {primeorial}")
        number_entry = number_db.get_number(primeorial)
        number_id = number_entry['number_id']
        inv_db.insert_inv_primeorial_value(number_id, prime)

populate_primeorial_table()
