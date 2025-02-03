_HiStOrY_V2_
DROP DATABASE IF EXISTS PFEN;
CREATE database PFEN;
SHOW DATABASES;

CREATE USER 'PFEN_Read'@'localhost'   INDENTIFIED BY  "f02d355930305028e28373caa299cc54";
CREATE USER 'PFEN_Modify'@'localhost' INDENTIFIED BY  "f02d355930305028e28373caa299cc54";
GRANT SELECT, INSERT, UPDATE, DELETE ON PFEN.* TO 'PFEN_Modify'@'localhost';
GRANT SELECT                         ON PFEN.* TO 'PFEN_Read'@'localhost';
SELECT User, Host from mysql.USER;
FLUSH PRIVILEGES;

USE mysql;
SELECT * from USER where USER = 'PFEN_Modify';
SELECT * from USER where USER = 'PFEN_Read';

USE PFEN;
DROP TABLE IF EXISTS Primes;
DROP TABLE IF EXISTS Numbers;
DROP TABLE IF EXISTS PrimeFactors;
CREATE TABLE Primes  (
    prime_id  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sequence  INT UNSIGNED,
    prime_gap INT UNSIGNED
    prime     BIGINT UNSIGNED
); 
CREATE TABLE Numbers (
    number_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    number BIGINT UNSIGNED,
    total_factors INT UNSIGNED NOT NULL DEFAULT 0,
    unique_factors INT UNSIGNED NOT NULL DEFAULT 0;
);
CREATE TABLE PrimeFactors (
    primefactor_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    prime_id  INT UNSIGNED,
    number_id INT UNSIGNED,
    exponent  INT UNSIGNED,
    FOREIGN KEY (prime_id) REFERENCES Primes(prime_id),
    FOREIGN KEY (number_id) REFERENCES Numbers(number_id)
);
ALTER TABLE primes AUTO_INCREMENT = 1;
ALTER TABLE numbers AUTO_INCREMENT = 1;
ALTER TABLE PrimeFactors AUTO_INCREMENT = 1;
INSERT INTO Numbers (number) VALUES (1);
DESCRIBE Numbers;
DESCRIBE Primes;
DESCRIBE PrimeFactors;

UPDATE Numbers n SET n.total_factors= (
    SELECT COALESCE(SUM(pf.exponent), 0)
    FROM PrimeFactors pf
    WHERE pf.number_id = n.number_id
);
UPDATE Numbers n SET n.unique_factors = (
    SELECT COALESCE(COUNT(pf.prime_id), 0)
    FROM PrimeFactors pf
    WHERE pf.number_id = n.number_id
);

UPDATE Primes p1
JOIN Primes p2 ON p2.prime_id = p1.prime_id + 1
SET p1.prime_gap = p2.prime - p1.prime;


UPDATE Primes p1
JOIN Primes p2 ON p2.prime_id = p1.prime_id + 1
SET p1.prime_gap = p2.prime - p1.prime;


SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization
  FROM Numbers n
  JOIN PrimeFactors pf ON n.number_id = pf.number_id
  JOIN Primes p ON pf.prime_id = p.prime_id
  WHERE pf.prime_id > 5132 and pf.prime_id < 5175
  GROUP BY n.number, n.number_id,pf.prime_id LIMIT 35;
