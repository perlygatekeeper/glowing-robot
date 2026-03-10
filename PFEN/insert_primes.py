import mysql.connector
import os

db_config = {
    'host':        os.getenv('DB_HOST', 'localhost'),
    'user':        os.getenv('DB_USER', 'PFEN_Modify'),
    'password':    os.getenv('DB_PASSWORD', ''),
    'database':    os.getenv('DB_NAME', 'PFEN'),
    'unix_socket': os.getenv('DB_SOCKET', '/tmp/mysql.sock' ),
    'raise_on_warnings': True
}


# Connect to the database
conn = mysql.connector.connect(**db_config)
cursor = conn.cursor()

# Open the file and insert each prime
with open('9digit_primes.txt', 'r') as f:
    previous_prime = 99999989
    for line in f:
        prime = int(line.strip())
        if previous_prime is not None:
            gap = prime - previous_prime
        else:
            gap = None  # No gap for the first prime

        sql = """
        INSERT INTO Primes (prime, prime_gap)
        VALUES (%s, %s) AS new
        ON DUPLICATE KEY UPDATE prime_gap = new.prime_gap
        """
        cursor.execute(sql, (prime, gap))
        previous_prime = prime

# Commit and close
conn.commit()
cursor.close()
conn.close()

