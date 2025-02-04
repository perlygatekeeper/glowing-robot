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

# Function to easily get database instances
def get_number_db():
    return NumberDB()

def get_prime_db():
    return PrimeDB()

