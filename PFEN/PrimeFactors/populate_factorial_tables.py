from db_module import get_number_db, get_inv_factorial_db

def populate_factorial_table():
    number_db = get_number_db()
    inv_db = get_inv_factorial_db()
    factorial = 1
    for inv in range(2,11):
        factorial *= inv
        print(f"inv is {inv}; factorial is {factorial}")
        number_entry = number_db.get_number(factorial)
        number_id = number_entry['number_id']
        inv_db.insert_inv_factorial_value(number_id, inv)

populate_factorial_table()
