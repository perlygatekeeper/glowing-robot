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
    
def insert_prime_to_db(conn, cursor, prime, prime_sequence):
    # Insert prime into the Primes table
    query = "INSERT INTO Primes (prime, sequence) VALUES (%s,%s)"
    cursor.execute(query, (prime,prime_sequence))
    conn.commit()
    
    # Retrieve the last inserted ID
    prime_id = cursor.lastrowid
    print(f"Inserted prime {prime} as the {prime_sequence}-th prime into the database with ID {prime_id}.")
    return prime_id

try:
    conn = mysql.connector.connect(**db_config)
    print("Connected to MySQL database")
    cursor = conn.cursor()
    try:
        with gzip.open(prime_factor_file, 'rt') as z:
            prime_sequence = 0
            for line in z:
                if re.search(r'[^\d\s]', line) or not re.search(r'\d', line):
                    continue
    
                line = line.strip()
                # print(line)
                # continue
                for prime in line.split():
                    prime_sequence += 1
                    prime_id = insert_prime_to_db(conn, cursor, prime, prime_sequence)
    
    except FileNotFoundError:
        print(f"Cannot read from '{prime_factor_file}': File not found.")
    except OSError as e:
        print(f"Error reading gzip file: {e}")
except mysql.connector.Error as err:
    print(f"Error: {err}")
    exit
finally:
    if conn:
        conn.close()
