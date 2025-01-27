import gzip
import re
import mysql.connector
import os

# Define the file name
prime_factor_file = __file__.replace('.py', '.txt.gz')

# Database connection setup
db_config = {
    'host':        os.getenv('DB_HOST', 'localhost'),
    'user':        os.getenv('DB_USER', 'PFEN_Modify'),
    'password':    os.getenv('DB_PASSWORD', ''),
    'database':    os.getenv('DB_NAME', 'PFEN'),
    'unix_socket': os.getenv('DB_SOCKET', '/opt/local/var/run/mysql57/mysqld.sock' ),
    'raise_on_warnings': True
}
print("db_config:")
for key, value in db_config.items():
        print("   ", key, ":", value)

def select_primes_from_db(cursor, limit):
    # Select and store  primes and their prime_ids  into prime_ids dictionary
    query = "SELECT prime, prime_id FROM Primes WHERE prime < %s"
    cursor.execute(query, ( limit, ) )
    prime_ids = cursor.fetchall()
    print(f"Primes below {limit}:")
    for prime, prime_id in prime_ids:
        print(f"ID: {prime_id}, Prime: {prime}")
        break
    return prime_ids

def insert_prime_to_db(cursor, prime, prime_sequence):
    # Insert prime into the Primes table
    query = "INSERT INTO Primes (prime) VALUES (%s,%s)"
    cursor.execute(query, (prime,prime_sequence))
    # Retrieve the last inserted ID
    prime_id = cursor.lastrowid
    print(f"Inserted prime {prime} as the {prime_sequence}-th prime into the database with ID {prime_id}.")
    return prime_id

def insert_number_to_db(cursor, number):
    # Insert number into the Numbers table
    query = "INSERT INTO Numbers (number) VALUES (%s)"
    cursor.execute(query, (number,))
    conn.commit()
    # Retrieve the last inserted ID
    number_id = cursor.lastrowid
    print(f"Inserted number {number} into the database with ID {number_id}.")
    return number_id

def insert_prime_factors_to_db(number, factors):
    # Insert into PrimeFactors table
    query = "INSERT INTO PrimeFactors (number_id, prime_id, exponent) VALUES (%s, %s, %s)"
    for prime, exponent in factors.items():
        cursor.execute(query, (number, prime, exponent))
    conn.commit()
    print(f"Inserted prime factors for number {number} into the database.")


# DATABASE CONNECTION
try:
    conn = mysql.connector.connect(**db_config)
    print("Connected to MySQL database")
    cursor = conn.cursor()
    limit = 50000
    # PRELOAD FIRST PRIMES BELOW 50000
    prime_ids = select_primes_from_db(cursor, limit)
    # OPEN PRIME FACTORS COMPRESSED FILE
    try:
        with gzip.open(prime_factor_file, 'rt') as z:
            for line in z:
                # SKIP LINES THAT DO NOT CONTAIN AN EQUALS SIGN
                if '=' not in line:
                    continue
                line = line.strip()
                print(line)
                # Extract number and Right Hand Side (RHS)
                match = re.match(r'(^\d+)=(.*)', line)
                if match:
                    number, RHS = match.groups()
                    number = int(number)
                    # Insert the number into the Numbers table
                    number_id = insert_number_to_db(cursor, number)
                    # Check if the number is a prime
                    prime_match = re.search(r'\((\d+)\)', line)
                    if prime_match:
                        prime = number
                        prime_sequence = int(prime_match.group(1))
                        print(f" {number} is the {prime_sequence}-th prime.")
                        # Ensure that this number is in the preloaded primes
                        if prime in prime_ids:
                            print("{prime} is a prime its id is:", prime_ids[prime])
                        else:
                            print("{prime} NOT found in list of primes")
                        # Insert the prime into the database
                        # prime_id = insert_prime_to_db(prime, prime_sequence)
                    # Check for prime factor sequence
                    if ';' in RHS:
                        prime_factor_sequence = int(RHS.split(';')[-1])
                        print(f" {number} is a prime factor sequence: {prime_factor_sequence}")
                        RHS = RHS.split(';')[0]
                    # Parse factorization if it's a product of primes
                    if re.match(r'^[0-9x^]+$', RHS):
                        def parse_factorization(factorization_string):
                            factors = factorization_string.split('x')
                            factor_exponents = {}
                            for prime_factor in factors:
                                factor, _, exponent = prime_factor.partition('^')
                                factor = int(factor)
                                exponent = int(exponent) if exponent else 1
                                factor_exponents[factor] = exponent
                            print(" ", ", ".join(factors))
                            return factor_exponents
                        factors = parse_factorization(RHS)
                        # Insert prime factors into the database
                        insert_prime_factors_to_db(number_id, factors)
    
    except FileNotFoundError:
        print(f"Cannot read from '{prime_factor_file}': File not found.")
    except OSError as e:
        print(f"Error reading gzip file: {e}")
except mysql.connector.Error as err:
    print(f"Error: {err}")
    exit
finally:
    if conn:
        conn.commit()
        conn.close()

