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
        try:
            conn = self.connect()
            cursor = conn.cursor(dictionary=True)
            # print(sql,"\n")
            cursor.execute(sql, params or ())
            if commit:
                conn.commit()
            result = cursor.fetchall()
            cursor.close()
            return result
        except mysql.connector.Error as err:
            print(f"SQL Error: {err}")
            print(f"Query: {sql}")
            print(f"Params: {params}")
            return None
    
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
        self.prime_ids = self.select_primes_from_db(10000000)  # Initialize once

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
        # print(f"attempting to insert factors ( {number_id} )")
        sql = """
          INSERT INTO PrimeFactors (number_id, prime_id, exponent)
          VALUES (%s, %s, %s)
        """
        # print("factors is a ", type(factors))
        # print("factors: ", factors)
        if not isinstance(factors, dict):
            print(f"Unexpected return type from factorize_number: {type(factors)} -> {factors}")
            exit()
        for prime_id, exponent in factors.items():
            # print(f"Expected return type from factorize_number: {type(factors)} -> {factors}")
            # print(f"inserting ( {number_id}, {prime_id}, {exponent} )")
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

    def union_prime_factors(self, factors1, factors2):
        """
        Returns the union of two prime factor dictionaries.
        The union keeps the highest exponent when a prime is in both.
        :param factors1: Dictionary of prime factors for number 1 {prime_id: exponent}
        :param factors2: Dictionary of prime factors for number 2 {prime_id: exponent}
        :return: Dictionary representing the union of both sets of prime factors.
        """
        union_factors = factors1.copy()  # Start with factors1
        for prime, exponent in factors2.items():
            if prime in union_factors:
                union_factors[prime] = max(union_factors[prime], exponent)  # Keep max exponent
            else:
                union_factors[prime] = exponent  # Add new prime
        return union_factors

    def intersect_prime_factors(self, factors1, factors2):
        """
        Returns the intersection (GCD) of two prime factor dictionaries.
        Keeps only primes that appear in both, with the minimum exponent.
        :param factors1: Dictionary of prime factors for number 1 {prime_id: exponent}
        :param factors2: Dictionary of prime factors for number 2 {prime_id: exponent}
        :return: Dictionary representing the intersection of both sets of prime factors.
        """
        return {prime: min(factors1[prime], factors2[prime]) for prime in factors1 if prime in factors2}


    def multiply_prime_factors(self, factors1, factors2):
        """
        Returns the product (multiplication) of two prime factor dictionaries.
        Keeps all primes, summing their exponents when they appear in both.
        :param factors1: Dictionary of prime factors for number 1 {prime_id: exponent}
        :param factors2: Dictionary of prime factors for number 2 {prime_id: exponent}
        :return: Dictionary representing the product of both sets of prime factors.
        """
        product_factors = factors1.copy()  # Start with factors1
        for prime, exponent in factors2.items():
            if prime in product_factors:
                product_factors[prime] += exponent  # Sum exponents
            else:
                product_factors[prime] = exponent  # Add new prime
        return product_factors

class LogBaseDB(DatabaseConnection):
    def __init__(self, base):
        super().__init__()
        self.base = base
        self.table_name = f'log{base}'
    
    def insert_log_value(self, number_id, log_value):
        sql = f"""
        INSERT INTO {self.table_name} (number_id, log{self.base}_value)
        VALUES (%s, %s)
        """
        self.query(sql, (number_id, log_value), commit=True)
    
    def get_log_value(self, number_id):
        sql = f"SELECT log{self.base}_value FROM {self.table_name} WHERE number_id = %s"
        result = self.query(sql, (number_id,))
        return result[0]['log_value'] if result else None

class InvPrimeorialDB(DatabaseConnection):
    def __init__(self, prime_db):
        super().__init__()
        self.prime_ids = prime_db.prime_ids # Store prime_id lookup
    
    def insert_inv_primeorial_value(self, number_id, inv_value):
        sql = f"""
        INSERT INTO inv_primeorial (number_id, inv_primorial_value)
        VALUES (%s, %s)
        ON DUPLICATE KEY UPDATE inv_primeorial_value = VALUES(inv_primeorial_value)
        """
        self.query(sql, (number_id, inv_value), commit=True)
    
    def get_inv_primeoria_value(self, number_id):
        sql = f"SELECT inv_primeorial_value FROM inv_primeorial WHERE number_id = %s"
        result = self.query(sql, (number_id,))
        return result[0]['inv_primeorial_value'] if result else None

class InvFactorialDB(DatabaseConnection):
    
    def insert_inv_factorial_value(self, number_id, inv_value):
        sql = f"""
        INSERT INTO inv_factorial (number_id, inv_factorial_value)
        VALUES (%s, %s)
        ON DUPLICATE KEY UPDATE inv_primeorial_value = VALUES(inv_primeorial_value)
        """
        self.query(sql, (number_id, inv_value), commit=True)
    
    def get_inv_factoria_value(self, number_id):
        sql = f"SELECT inv_factorial_value FROM inv_factorial WHERE number_id = %s"
        result = self.query(sql, (number_id,))
        return result[0]['inv_factorial_value'] if result else None

# Function to easily get database instances
def get_number_db():
    return NumberDB()

def get_prime_db():
    return PrimeDB()

def get_primefactor_db(primeDB):
    return PrimeFactorDB(primeDB)

def get_log_db(base):
        return LogBaseDB(base)

def get_inv_primeorial_db(primeDB):
        return InvPrimeorialDB(primeDB)

def get_inv_factorial_db():
        return InvFactorialDB()
