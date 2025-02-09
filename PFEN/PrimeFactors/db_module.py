import mysql.connector
import os

class DatabaseConnection:
    def __init__(self, db_config=None):
        self.db_config = db_config or self.get_default_db_config()
        self.conn = None

    def connect(self):
        if self.conn is None or not self.conn.is_connected():
            self.conn = mysql.connector.connect(**self.db_config)
        return self.conn
    
    def query(self, sql, params=None, commit=False):
        conn = self.connect()
        cursor = conn.cursor(dictionary=True)
        # print(sql,"\n")
        cursor.execute(sql, params or ())
        if commit:
            conn.commit()
        result = cursor.fetchall()
        cursor.close()
        return result
    
    def close(self):
        if self.conn and self.conn.is_connected():
            self.conn.close()
            self.conn = None

    @staticmethod
    def get_default_db_config():
        return {
            'host': os.getenv('DB_HOST', 'localhost'),
            'user': os.getenv('DB_USER', 'PFEN_Modify'),
            'password': os.getenv('DB_PASSWORD', ''),
            'database': os.getenv('DB_NAME', 'PFEN'),
            'unix_socket': os.getenv('DB_SOCKET', '/opt/local/var/run/mysql57/mysqld.sock'),
            'raise_on_warnings': True
        }

class NumberDB(DatabaseConnection):
    def get_number(self, number):
        sql = "SELECT * FROM numbers WHERE number = %s"
        result = self.query(sql, (number,))
        return result[0] if result else None
    
    def insert_number(self, number, total_factors, unique_factors):
        sql = """
        INSERT INTO numbers (number, total_factors, unique_factors)
        VALUES (%s, %s, %s) ON DUPLICATE KEY UPDATE total_factors = VALUES(total_factors), unique_factors = VALUES(unique_factors)
        """
        self.query(sql, (number, total_factors, unique_factors), commit=True)

class PrimeDB(DatabaseConnection):
    def __init__(self):
        super().__init__()
        self.prime_ids = self.select_primes_from_db(99999)  # Initialize once

    def select_primes_from_db(self, limit):
        # Select and store  primes and their prime_ids  into prime_ids dictionary
        prime_lookup = dict()
        sql = "SELECT prime, prime_id FROM Primes WHERE prime < %s"
        primes_query_result = self.query(sql, (limit,))
        for row in primes_query_result:
            prime_lookup[row['prime']] = row['prime_id']
        return prime_lookup

    def get_prime_by_sequence(self, sequence):
        sql = "SELECT * FROM primes WHERE sequence = %s"
        result = self.query(sql, (sequence,))
        return result[0] if result else None
    
    def insert_prime(self, sequence, prime, prime_gap):
        sql = """
        INSERT INTO primes (sequence, prime, prime_gap)
        VALUES (%s, %s, %s) ON DUPLICATE KEY UPDATE prime = VALUES(prime), prime_gap = VALUES(prime_gap)
        """
        self.query(sql, (sequence, prime, prime_gap), commit=True)

class PrimeFactorDB(DatabaseConnection):
    def __init__(self, prime_db):
        super().__init__()
        self.prime_ids = prime_db.prime_ids # Store prime_id lookup

    def get_primefactors(self, number_id):
        sql = """
          SELECT n.number_id, n.number, pf.prime_id, p.prime, pf.exponent FROM Numbers n
          JOIN PrimeFactors pf ON n.number_id = pf.number_id
          JOIN Primes p ON pf.prime_id = p.prime_id
          WHERE pf.number_id = %s
        """
        result = self.query(sql, (number_id,))
        """ RETURN ALL FACTORS INSTEAD OF THIS ..."""
        return result if result else None
    
    def insert_primefactors(self, number_id, factors):
        sql = """
          INSERT INTO PrimeFactors (number_id, prime_id, exponent)
          VALUES (%s, %s, %s)
        """
        for prime_id, exponent in factors:
            self.query(sql, (number_id, prime_id, exponent), commit=True)

    def find_number_by_primefactors(self, prime_factors):
        # Convert prime numbers to their corresponding prime_id using self.prime_ids
        primeid_factors = [(self.prime_ids[pf[0]], pf[1]) for pf in prime_factors]
        # Build the GivenFactors dynamically using SELECT ... UNION ALL
        given_factors_sql = " UNION ALL ".join(
            "SELECT %s AS prime_id, %s AS exponent" for _ in primeid_factors
        )
        values = [val for pair in primeid_factors for val in pair]  # Flatten values
        sql = f"""
        SELECT mn.number_id
        FROM (
            SELECT pf.number_id
            FROM PrimeFactors pf
            JOIN (
                {given_factors_sql}
            ) AS GivenFactors ON pf.prime_id = GivenFactors.prime_id AND pf.exponent = GivenFactors.exponent
            GROUP BY pf.number_id
            HAVING COUNT(*) = (SELECT COUNT(*) FROM ( {given_factors_sql} ) AS GF)
        ) AS mn
        WHERE NOT EXISTS (
            SELECT 1 FROM PrimeFactors pf
            WHERE pf.number_id = mn.number_id
            AND (pf.prime_id, pf.exponent) NOT IN (SELECT prime_id, exponent FROM ( {given_factors_sql} ) AS GF2)
        );
        """
        result = self.query(sql, values * 3)  # Triple values to replace all occurrences
        return result or None

    def find_number_by_primefactor_ids(self, prime_factors):
        # Convert prime numbers to their corresponding prime_id using self.prime_ids
        primeid_factors = [(pf[0], pf[1]) for pf in prime_factors]
        # Build the GivenFactors dynamically using SELECT ... UNION ALL
        given_factors_sql = " UNION ALL ".join(
            "SELECT %s AS prime_id, %s AS exponent" for _ in primeid_factors
        )
        values = [val for pair in primeid_factors for val in pair]  # Flatten values
        sql = f"""
        SELECT mn.number_id
        FROM (
            SELECT pf.number_id
            FROM PrimeFactors pf
            JOIN (
                {given_factors_sql}
            ) AS GivenFactors ON pf.prime_id = GivenFactors.prime_id AND pf.exponent = GivenFactors.exponent
            GROUP BY pf.number_id
            HAVING COUNT(*) = (SELECT COUNT(*) FROM ( {given_factors_sql} ) AS GF)
        ) AS mn
        WHERE NOT EXISTS (
            SELECT 1 FROM PrimeFactors pf
            WHERE pf.number_id = mn.number_id
            AND (pf.prime_id, pf.exponent) NOT IN (SELECT prime_id, exponent FROM ( {given_factors_sql} ) AS GF2)
        );
        """
        result = self.query(sql, values * 3)  # Triple values to replace all occurrences
        return result or None



        """
        ADD MODULE FOR CONVERTING PRIME FACTORS INTO A STRING
    def primefactors(self, number_id, ):
        ADD MODULE TO ADD TWO PRIME FACTORS
    def primefactors(self, number_id, ):
        ADD MODULE TO SUBTRACT TWO PRIME FACTORS
    def primefactors(self, number_id, ):
        ADD MODULE FIND INTERSECTION OF TWO PRIME FACTORS
    def primefactors(self, number_id, ):
        ADD MODULE FIND UNION OF TWO PRIME FACTORS
    def primefactors(self, number_id, ):
        pfen_asjson   = for storage into database
        gcd           = Greatest Common Divisor (Intersection)
        lcm           = Lowest Common Multiple (Union)
        mult          = Multiplication (Vector Addition)
        div           = Multiplication (Vector Subtraction)
        exp           = Exponentation (Vector Multiplication)
        root          = Exponentation (Vector Division)
        is_root       = are all numbers in vector multiple of power of the root, sqrt => are all exponents even
        is_prime      = single point vector
        are_coprime   = ( number, number)
        prime_factors = list each prime and exponent
        prime_factoral = a vector of all ones, followed by all zeros
        """

# Function to easily get database instances
def get_number_db():
    return NumberDB()

def get_prime_db():
    return PrimeDB()

def get_primefactor_db(primeDB):
    return PrimeFactorDB(primeDB)
