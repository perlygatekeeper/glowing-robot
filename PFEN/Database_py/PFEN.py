import mysql.connector
import os

class Number:
    def __init__(self, value, db_config):
        self.value = value
        self.db_config = db_config
        self.is_prime = False
        self.prime_factors = []
        self._load_from_db()

    def _load_from_db(self):
        """Loads number properties from the database."""
        conn = mysql.connector.connect(**self.db_config)
        cursor = conn.cursor()
        
        # Check if the number exists in the numbers table
        cursor.execute("SELECT is_prime FROM numbers WHERE value = %s", (self.value,))
        row = cursor.fetchone()
        if row:
            self.is_prime = bool(row[0])
        
        # Fetch prime factors from prime_factors table
        cursor.execute("""
            SELECT p.value FROM prime_factors pf
            JOIN primes p ON pf.prime_id = p.id
            WHERE pf.number_id = (SELECT id FROM numbers WHERE value = %s)
        """, (self.value,))
        
        self.prime_factors = [r[0] for r in cursor.fetchall()]
        
        cursor.close()
        conn.close()
    
    def __repr__(self):
        return f"Number({self.value}, is_prime={self.is_prime}, prime_factors={self.prime_factors})"

class Prime:
    def __init__(self, value, db_config):
        self.value = value
        self.db_config = db_config
        self.is_prime = True
        self._load_from_db()


# Example usage
if __name__ == "__main__":
    # Database connection setup
    db_config = {
        'host':        os.getenv('DB_HOST', 'localhost'),
        'user':        os.getenv('DB_USER', 'PFEN_Modify'),
        'password':    os.getenv('DB_PASSWORD', ''),
        'database':    os.getenv('DB_NAME', 'PFEN'),
        'unix_socket': os.getenv('DB_SOCKET', '/opt/local/var/run/mysql57/mysqld.sock' ),
        'raise_on_warnings': True
    }
    #print("db_config:")
    #for key, value in db_config.items():
    #        print("   ", key, ":", value)
    
    num = Number(30, db_config)  # Assumes the database is populated with relevant data
    print(num)

def select_primes_from_db(cursor, limit):
    # Select and store  primes and their prime_ids  into prime_ids dictionary
    prime_lookup = dict()
    query = "SELECT prime, prime_id FROM Primes WHERE prime < %s"
    cursor.execute(query, ( limit, ) )
    prime_ids = cursor.fetchall()
    print(f"Primes below {limit}:")
    for prime, prime_id in prime_ids:
        if prime_id <= 10:
            print(f"ID: {prime_id}, Prime: {prime}")
        prime_lookup[prime] = prime_id
    return prime_lookup

# DATABASE CONNECTION
try:
    conn = mysql.connector.connect(**db_config)
    print("Connected to MySQL database")
    cursor = conn.cursor()
    limit = 50000
    # PRELOAD FIRST PRIMES BELOW 50000 into prime_ids, a list of tuples
    # should be moved into a dictionary for quick lookup of prime_ids
    # with the prime
    prime_ids = select_primes_from_db(cursor, limit)
    # OPEN PRIME FACTORS COMPRESSED FILE
except mysql.connector.Error as err:
    print(f"Error: {err}")
    exit
finally:
    if conn:
        conn.commit()
        conn.close()

