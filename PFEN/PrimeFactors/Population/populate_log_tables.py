from db_module import get_number_db, get_log_db

def populate_log_table():
    number_db = get_number_db()
    # for base in (2,3,5,7,10):
    for base in (5, 7, 10):
        log_db = get_log_db(base)  # Get the LogBASE table interface
        exponent = 0
        while 1:
            exponent += 1
            number = base ** exponent
            print(f"base is {base}; exponent is {exponent}; number is {number}")
            if number > 10000000:
                break
            else:
                print(f'Adding {number} in log{base} with {exponent}')
            # Ensure the number exists in the numbers table
            number_entry = number_db.get_number(number)
            number_id = number_entry['number_id']
            # Insert log10 value into the log10 table
            log_db.insert_log_value(number_id, exponent)

populate_log_table()
