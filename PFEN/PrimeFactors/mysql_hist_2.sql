_HiStOrY_V2_
show tables;
show tables;

show tables;

show databases;
use mysql
show tables;
select * from user;

flush privileges;
select * from user;

show databases;
create database PFEN;
use PFEN
show tables;
create table Primes ( prime_id INT NOT NULL, sequence INT UNSIGNED, prime BIGINT(255) UNSIGNED, PRIMARY KEY (prime_id) ); 
create table Primes ( number_id INT UNSIGNED NOT NULL, number BIGINT UNSIGNED, number BIGINT(255) UNSIGNED, PRIMARY KEY (number_id) );
create table Numbers ( number_id INT UNSIGNED NOT NULL, number BIGINT UNSIGNED, number BIGINT(255) UNSIGNED, PRIMARY KEY (number_id) );
create table Numbers ( number_id INT UNSIGNED NOT NULL, number BIGINT UNSIGNED, number BIGINT UNSIGNED, PRIMARY KEY (number_id) );
create table Numbers ( number_id INT UNSIGNED NOT NULL, number BIGINT UNSIGNED, PRIMARY KEY (number_id) );
CREATE TABLE PrimeFactors (
    prime_id INT,
    number_id INT,
    PRIMARY KEY (prime_id, number_id),
    FOREIGN KEY (prime_id) REFERENCES Primes(prime_id),
    FOREIGN KEY (number_id) REFERENCES Numbers(number_id)
);
CREATE TABLE PrimeFactors (     prime_id INT,     number_id INT,     PRIMARY KEY (prime_id, number_id),     FOREIGN KEY (prime_id) REFERENCES Primes(prime_id),     FOREIGN KEY (number_id) REFERENCES Numbers(number_id) );
CREATE TABLE PrimeFactors (     prime_id INT,     number_id UNSIGNED INT,     PRIMARY KEY (prime_id, number_id),     FOREIGN KEY (prime_id) REFERENCES Primes(prime_id),     FOREIGN KEY (number_id) REFERENCES Numbers(number_id) );
CREATE TABLE PrimeFactors ( prime_id INT, number_id INT UNSIGNED, PRIMARY KEY (prime_id, number_id), FOREIGN KEY (prime_id) REFERENCES Primes(prime_id),     FOREIGN KEY (number_id) REFERENCES Numbers(number_id) );

DROP DATABASE IF EXISTS PFEN;
create database PFEN;
use PFEN;

drop table if exists Primes;
drop table if exists Numbers;
drop table if exists PrimeFactors;
create table Primes  ( prime_id  INT UNSIGNED NOT NULL, sequence INT UNSIGNED,   prime BIGINT(255) UNSIGNED, PRIMARY KEY (prime_id) ); 
create table Numbers ( number_id INT UNSIGNED NOT NULL, number BIGINT UNSIGNED, PRIMARY KEY (number_id) );
create table PrimeFactors (
    primefactor_id INT UNSIGNED,
    prime_id INT UNSIGNED,
    number_id INT UNSIGNED,
    exponent INT UNSIGNED,
    PRIMARY KEY (primefactor_id),
    FOREIGN KEY (prime_id) REFERENCES Primes(prime_id),
    FOREIGN KEY (number_id) REFERENCES Numbers(number_id)
);
create table PrimeFactors (     primefactor_id INT UNSIGNED,     prime_id INT UNSIGNED,     number_id INT UNSIGNED,     exponent INT UNSIGNED,     PRIMARY KEY (primefactor_id),     FOREIGN KEY (prime_id) REFERENCES Primes(prime_id),     FOREIGN KEY (number_id) REFERENCES Numbers(number_id) );
describe Numbers;
describe Primes;
describe PrimeFactors;
show tables;
quit
use mysql
show tables;
select * from user;
flush privileges;
quit
use PFEN;
describe primes;
quit
use PFEN;
describe primes;
select * from primes;
quit
use mysql;
show tables;
select * from USER;
quit
use mysql;
select * from USER;
quit
ALTER USER PFEN_Modify INDENTIFIED BY "f02d355930305028e28373caa299cc54";
ALTER USER PFEN_Modify@localehost  INDENTIFIED BY  "f02d355930305028e28373caa299cc54";
ALTER USER 'PFEN_Modify'@'localehost' INDENTIFIED BY  "f02d355930305028e28373caa299cc54";
SELECT User, Host from mysql.user;
ALTER USER 'PFEN_Modify'@'localhost' INDENTIFIED BY  "f02d355930305028e28373caa299cc54";
flush privileges;
quit
use PFEN;
show tables;
describe tables;
l describe tables;
describe tables;
describe Primes;
select * from primes;
quit
use mysql;
select * from user where user = 'PFEN_Modify';
show tables;
select * from general_log;
select * from db;
quit
use PFEN;
show tables;
describe table Numbers;
describe Numbers;
INSERT INTO Numbers (number) VALUES (2);
describe Numbers;
select * from numbers;
quit
use PFEN;
describe primes;
quit
use PFEN;
select * from primes;
quit
use PFEN;
DROP TABLE primes;
drop table if exists Primes;
drop table if exists Numbers;
drop table if exists PrimeFactors;
drop table if exists Primes;
drop table if exists Numbers;
show tables;
create table Primes  ( prime_id  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, sequence INT UNSIGNED,   prime BIGINT(255) UNSIGNED );
create table Numbers ( number_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, number BIGINT UNSIGNED );
create table PrimeFactors (
    primefactor_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    prime_id BIGINT UNSIGNED,
    number_id BIGINT UNSIGNED,
    exponent INT UNSIGNED,
    FOREIGN KEY (prime_id) REFERENCES Primes(prime_id),
    FOREIGN KEY (number_id) REFERENCES Numbers(number_id)
);
create table PrimeFactors (     primefactor_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,     prime_id BIGINT UNSIGNED,     number_id BIGINT UNSIGNED,     exponent INT UNSIGNED,     FOREIGN KEY (prime_id) REFERENCES Primes(prime_id),     FOREIGN KEY (number_id) REFERENCES Numbers(number_id) );
show tables;
quit
use PFEN;
select * from numbers;
select * from prime_factors;
select * from primefactors;
quit
DROP DATABASE IF EXISTS PFEN;
create database PFEN;
use mysql;
select * from user;
select * from db;
GRANT DELETE ON PFEN TO 'PFEN_Modify'@'localhost';
GRANT DELETE ON PFEN.* TO 'PFEN_Modify'@'localhost';
flush privileges;
select * from db;
select * from tables;
show tables;
select * from tables_priv;
show tables;
select * from tables_priv;
select * from user;
show tables;
select * from tables_priv;
create table Primes  ( prime_id  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, sequence INT UNSIGNED UNIQUE,   prime BIGINT(255) UNSIGNED UNIQUE );
create table Numbers ( number_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, number BIGINT UNSIGNED UNIQUE );
create table PrimeFactors (
    primefactor_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    prime_id BIGINT UNSIGNED,
    number_id BIGINT UNSIGNED,
    exponent INT UNSIGNED,
    FOREIGN KEY (prime_id) REFERENCES Primes(prime_id),
    FOREIGN KEY (number_id) REFERENCES Numbers(number_id)
);
create table PrimeFactors (     primefactor_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,     prime_id BIGINT UNSIGNED,     number_id BIGINT UNSIGNED,     exponent INT UNSIGNED,     FOREIGN KEY (prime_id) REFERENCES Primes(prime_id),     FOREIGN KEY (number_id) REFERENCES Numbers(number_id) );
describe Numbers;
describe Primes;
describe PrimeFactors;
ALTER TABLE primes AUTO_INCREMENT = 1;
ALTER TABLE numbers AUTO_INCREMENT = 1;
ALTER TABLE PrimeFactors AUTO_INCREMENT = 1;
use PFEN;
INSERT INTO Numbers (number) VALUES (1);
show tables;
use PFEN;
show tables;
use mysql
show tables;
drop table Numbers;
drop PrimeFactors;
drop table PrimeFactors;
drop table Primes;
drop table Numbers;
use PFEN;
create table Numbers ( number_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, number BIGINT UNSIGNED UNIQUE );
create table Primes  ( prime_id  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, sequence INT UNSIGNED UNIQUE,   prime BIGINT(255) UNSIGNED UNIQUE );
create table PrimeFactors (     primefactor_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,     prime_id BIGINT UNSIGNED,     number_id BIGINT UNSIGNED,     exponent INT UNSIGNED,     FOREIGN KEY (prime_id) REFERENCES Primes(prime_id),     FOREIGN KEY (number_id) REFERENCES Numbers(number_id) );
ALTER TABLE primes AUTO_INCREMENT = 1;
ALTER TABLE numbers AUTO_INCREMENT = 1;
ALTER TABLE primefactors AUTO_INCREMENT = 1;
flush privileges;
INSERT INTO Numbers (number) VALUES (1);
quit
use PFEN;
select * from numbers;
ALTER TABLE numbers AUTO_INCREMENT = 2;
quit
use PFEN;
ALTER TABLE numbers AUTO_INCREMENT = 2;
delect from numbers where number_id = 2;
select * from numbers;
delete from numbers where number_id = 2;
quit
use PFEN;
ALTER TABLE numbers AUTO_INCREMENT = 2;
select * from numbers;
delete from numbers where number_id = 2;
SELECT AUTO_INCREMENT
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'database_name' 
AND TABLE_NAME = 'numbers';
SELECT AUTO_INCREMENT FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'database_name'  AND TABLE_NAME = 'numbers';
user PFEN;
use PFEN;
show table status numbers;
show table status like numbers;
show table status like 'numbers';
select * from numbers;
delete from numbers where number = 2;
select * from numbers;
show table status like 'numbers';
ALTER TABLE numbers AUTO_INCREMENT = 2;
show table status like 'numbers';
flush privileges;
quit
select max(number) from numbers;
use PFEN;
select max(number) from numbers;
quit
use PFEN;
ALTER TABLE Numbers 
ADD COLUMN total_factor INT UNSIGNED NOT NULL DEFAULT 0,
ADD COLUMN unique_factors INT UNSIGNED NOT NULL DEFAULT 0;
ALTER TABLE Numbers  ADD COLUMN total_factor INT UNSIGNED NOT NULL DEFAULT 0, ADD COLUMN unique_factors INT UNSIGNED NOT NULL DEFAULT 0;
describe numbers;
ALTER TABLE Numbers RENAME COLUMN total_factor to total_factors;
ALTER TABLE Numbers CHANGE COLUMN total_factor total_factors INT UNSIGNED NOT NULL DEFAULT 0;;
describe numbers;
quit
use PFEN;
UPDATE Numbers n
SET n.total_factors= (
    SELECT COALESCE(SUM(pf.exponent), 0)
    FROM PrimeFactors pf
    WHERE pf.number_id = n.number_id
);
UPDATE Numbers n SET n.total_factors= (     SELECT COALESCE(SUM(pf.exponent), 0)     FROM PrimeFactors pf     WHERE pf.number_id = n.number_id );
UPDATE Numbers n
SET n.unique_factors = (
    SELECT COALESCE(COUNT(pf.prime_id), 0)
    FROM PrimeFactors pf
    WHERE pf.number_id = n.number_id
);
UPDATE Numbers n SET n.unique_factors = (     SELECT COALESCE(COUNT(pf.prime_id), 0)     FROM PrimeFactors pf     WHERE pf.number_id = n.number_id );
select * Numbers WHERE number_id < 40;
SELECT * FROM Numbers WHERE number_id < 40;
SELECT * FROM Numbers WHERE total_factors = 0;
SELECT * FROM Numbers WHERE total_factors = 0 LIMIT 100;
SELECT * FROM Numbers WHERE total_factors = 0 LIMIT 10;
SELECT * FROM Numbers WHERE number_id > 49999 AND number_id < 50023;
SELECT * FROM Numbers WHERE number_id > 49999 AND number_id < 50029;
SELECT * FROM Numbers WHERE total_factors = 0 LIMIT 10;
SELECT * FROM Numbers WHERE number_id < 40;
SELECT * FROM Numbers WHERE total_factors = 0 LIMIT 10;
SELECT * FROM Numbers WHERE number_id < 40;
SELECT * FROM Numbers WHERE total_factors = 0 LIMIT 40;
select * from primes where prime > 50020 and prime < 50388;
select * from prime_factors where prime_id > 5132 and prime_id < 5175;
select * from primefactors where prime_id > 5132 and prime_id < 5175;
select * from primefactors where prime_id > 5132 and prime_id < 5175 LIMIT 100;
select * from primefactors where prime_id > 5132 and prime_id < 5175 LIMIT 40;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization
FROM Numbers n
JOIN PrimeFactors pf ON n.number_id = pf.number_id
JOIN Primes p ON pf.prime_id = p.prime_id
GROUP BY n.number_value
ORDER BY n.number_value
WHERE prime_id > 5132 and prime_id < 5175;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id GROUP BY n.number_value ORDER BY n.number_value WHERE prime_id > 5132 and prime_id < 5175;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id GROUP BY n.number_value ORDER BY n.number_value WHERE pf.prime_id > 5132 and pf.prime_id < 5175;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id WHERE pf.prime_id > 5132 and pf.prime_id < 5175;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id GROUP BY n.number_value  WHERE pf.prime_id > 5132 and pf.prime_id < 5175;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id > 5132 and pf.prime_id < 5175 GROUP BY n.number_value;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id > 5132 and pf.prime_id < 5175 GROUP BY n.number;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id > 5132 and pf.prime_id < 5175 GROUP BY n.number LIMIT 35;
SELECT n.nubmer_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id > 5132 and pf.prime_id < 5175 GROUP BY n.number LIMIT 35;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id > 5132 and pf.prime_id < 5175 GROUP BY n.number LIMIT 35;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id > 5132 and pf.prime_id < 5175 GROUP BY n.number, n.number_id LIMIT 35;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id > 5132 and pf.prime_id < 5175 GROUP BY n.number, n.number_id,pf.prime_id LIMIT 35;
select * from primes where prime_id=5147 or prime=5147;
uit
quit;
uit quit;
quit
use mysql;
show tables;
select * from db;
quit
use PFEN;
DELETE FROM PrimeFactors WHERE 1;
DELETE FROM Numbers WHERE number_id > 1;
ALTER TABLE numbers AUTO_INCREMENT = 2;
quit
ALTER TABLE PrimeFactors AUTO_INCREMENT = 1;
use PFEN;
ALTER TABLE PrimeFactors AUTO_INCREMENT = 1;
ALTER TABLE Numbers AUTO_INCREMENT = 2;
flush privileges;
quit
use PFEN;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id > 5132 and pf.prime_id < 5175 GROUP BY n.number, n.number_id,pf.prime_id LIMIT 35;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id > 5132 and pf.prime_id < 5175 GROUP BY n.number, n.number_id,pf.prime_id;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id > 5132 and pf.prime_id < 5175 GROUP BY n.number, n.number_id,pf.prime_id LIMIT 35;
select max(prime_factor_id) from primefactors;
select max(primefactor_id) from primefactors;
select min(primefactor_id) from primefactors;
delete * from primefactors;
show tables;
delete * from PrimeFactors;
delete from numbers where number > 1;
delete from PrimeFactors;
delete from numbers where number > 1;
ALTER TABLE Numbers AUTO_INCREMENT = 2;
quit
ALTER TABLE PrimeFactors AUTO_INCREMENT = 1;
use PFENl
use PFEN
ALTER TABLE PrimeFactors AUTO_INCREMENT = 1;
ALTER TABLE Numbers AUTO_INCREMENT = 2;
flush privileges;
quit
use PFEN;
select * from primes where prime_id=5147 or prime=5147;
quit
use PFEN;
select * from primes where prime_id=5147 or prime=5147;
select * from numbers;
delete from numbers where number > 1;
ALTER TABLE Numbers AUTO_INCREMENT = 2;
select max(*) from Primes;
select max from Primes;
select max() from Primes;
select max(*) from Primes;
select max(prime) from primes;
select max(prime_id) from primes;
select * from primes where prime_id>664570;
delete from numbers where number > 1;
delete from PrimeFactors;
delete from numbers where number > 1;
ALTER TABLE Numbers AUTO_INCREMENT = 2;
quit
ALTER TABLE Numbers AUTO_INCREMENT = 2;
use PFEN;
ALTER TABLE Numbers AUTO_INCREMENT = 2;
ALTER TABLE PrimeFactors AUTO_INCREMENT = 1;
flush privileges;
quit
show tables;
describe tables;
describe table Numbers;
describe table 'Numbers';
discribe table 'Numbers';
describe numbers;
describe primes;
describe primefactors;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id > 5132 and pf.prime_id < 5175 GROUP BY n.number, n.number_id,pf.prime_id LIMIT 35;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id =4  GROUP BY n.number, n.number_id,pf.prime_id;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id =4  GROUP BY n.number, n.number_id,pf.prime_id LIMIT 3;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.number_id = 77  GROUP BY n.number, n.number_id,pf.prime_id LIMIT 3;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id > 5132 and pf.prime_id < 5175 GROUP BY n.number, n.number_id,pf.prime_id LIMIT 35;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE pf.prime_id > 5147 GROUP BY n.number, n.number_id,pf.prime_id LIMIT 35;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE p.prime_id > 5147 GROUP BY n.number, n.number_id,pf.prime_id LIMIT 35;
SELECT * from Primes p  WHERE p.prime_id = 5147;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE n.number_id > 10348 GROUP BY n.number, n.number_id,pf.prime_id LIMIT 35;
SELECT n.number_id, n.number, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE n.number_id = 10348 GROUP BY n.number, n.number_id,pf.prime_id LIMIT 35;
SELECT n.* p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE n.number_id > 10348 GROUP BY n.number, n.number_id,pf.prime_id LIMIT 35;
SELECT n.*, p.prime_id, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id  WHERE n.number_id > 10348 GROUP BY n.number, n.number_id,pf.prime_id LIMIT 35;
UPDATE Numbers n
SET n.total_factors = (
    SELECT COALESCE(SUM(pf.exponent), 0)
    FROM PrimeFactors pf
    WHERE pf.number_id = n.number_id;
UPDATE Numbers n SET n.total_factors = (     SELECT COALESCE(SUM(pf.exponent), 0)     FROM PrimeFactors pf     WHERE pf.number_id = n.number_id;
UPDATE Numbers n SET n.total_factors = (     SELECT COALESCE(SUM(pf.exponent), 0)     FROM PrimeFactors pf     WHERE pf.number_id = n.number_id);
UPDATE Numbers n
SET n.total_factors = (
    SELECT COALESCE(SUM(pf.exponent), 0)
    FROM PrimeFactors pf
    WHERE pf.number_id = n.number_id
UPDATE Numbers n
SET n.unique_factors = (
    SELECT COALESCE(COUNT(pf.prime_id), 0)
    FROM PrimeFactors pf
    WHERE pf.number_id = n.number_id
);
UPDATE Numbers n SET n.total_factors = (     SELECT COALESCE(SUM(pf.exponent), 0)     FROM PrimeFactors pf     WHERE pf.number_id = n.number_id UPDATE Numbers n SET n.unique_factors = (     SELECT COALESCE(COUNT(pf.prime_id), 0)     FROM PrimeFactors pf     WHERE pf.number_id = n.number_id );
UPDATE Numbers n
SET n.unique_factors = (
    SELECT COALESCE(COUNT(pf.prime_id), 0)
    FROM PrimeFactors pf
    WHERE pf.number_id = n.number_id
);
UPDATE Numbers n SET n.unique_factors = (     SELECT COALESCE(COUNT(pf.prime_id), 0)     FROM PrimeFactors pf     WHERE pf.number_id = n.number_id );
SELECT * FROM Numbers WHERE total_factors = 0;
SELECT * FROM Numbers WHERE total_factors = 0 limit 60;
SELECT * FROM Numbers WHERE total_factors = 0 limit 40;
delete * from PrimeFactors;
use PFEN
delete * from PrimeFactors;
delete from PrimeFactors;
delete from numbers where number > 1;
quit
ALTER TABLE PrimeFactors AUTO_INCREMENT = 1;
use PFEN
ALTER TABLE PrimeFactors AUTO_INCREMENT = 1;
ALTER TABLE Numbers AUTO_INCREMENT = 2;
SELECT * FROM Numbers WHERE total_factors = 0 limit 40;
UPDATE Numbers n
SET n.total_factors = (
    SELECT COALESCE(SUM(pf.exponent), 0)
    FROM PrimeFactors pf
    WHERE pf.number_id = n.number_id
);
UPDATE Numbers n SET n.total_factors = (     SELECT COALESCE(SUM(pf.exponent), 0)     FROM PrimeFactors pf     WHERE pf.number_id = n.number_id );
UPDATE Numbers n
SET n.unique_factors = (
    SELECT COALESCE(COUNT(pf.prime_id), 0)
    FROM PrimeFactors pf
    WHERE pf.number_id = n.number_id
);
UPDATE Numbers n SET n.unique_factors = (     SELECT COALESCE(COUNT(pf.prime_id), 0)     FROM PrimeFactors pf     WHERE pf.number_id = n.number_id );
SELECT * FROM Numbers WHERE total_factors = 0 limit 40;
SELECT * FROM Numbers WHERE total_factors = 1 limit 40;
SELECT * FROM Numbers WHERE total_factors = 2 limit 40;
SELECT * FROM Numbers WHERE total_factors = 3 limit 40;
SELECT * FROM Numbers WHERE total_factors = 5 limit 40;
SELECT * FROM Numbers WHERE unique_factors = 5 limit 40;
SELECT * FROM Numbers WHERE total_factors = 5 and unique_factors = 5 limit 40;
SELECT * FROM Numbers WHERE total_factors = 7 and unique_factors = 7 limit 40;
SELECT * FROM Numbers WHERE total_factors = 6 and unique_factors = 6 limit 40;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization
FROM Numbers n
JOIN PrimeFactors pf ON n.number_id = pf.number_id
JOIN Primes p ON pf.prime_id = p.prime_id
GROUP BY n.number_value
ORDER BY n.number_value;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id GROUP BY n.number_value ORDER BY n.number_value;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id GROUP BY n.number ORDER BY n.number limit 40;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id GROUP BY n.number ORDER BY n.number limit 60;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id GROUP BY n.number ORDER BY n.number limit 150;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id GROUP BY n.number ORDER BY n.number limit 200;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id GROUP BY n.number ORDER BY n.number limit 210;
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id GROUP BY n.number ORDER BY n.number limit 35;
select * from numbers limit 35;
select * from numbers where number > 99990 limit 35;
quit
SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id where number > 99990 GROUP BY n.number ORDER BY n.number;
describe numbers;
describe primes;
describe primefactors;
          SELECT n.number_id, n.number, pf.prime_id, p.prime, pf.exponent FROM Numbers pf
          JOIN PrimeFactors pf ON n.number_id = pf.number_id
          JOIN Primes p ON pf.prime_id = p.prime_id
          WHERE pf.number_id = %s
          WHERE pf.number_id = 210 ;
SELECT n.number_id, n.number, pf.prime_id, p.prime, pf.exponent FROM Numbers pf           JOIN PrimeFactors pf ON n.number_id = pf.number_id           JOIN Primes p ON pf.prime_id = p.prime_id           WHERE pf.number_id = %s           WHERE pf.number_id = 210;
SELECT n.number_id, n.number, pf.prime_id, p.prime, pf.exponent FROM Numbers pf           JOIN PrimeFactors pf ON n.number_id = pf.number_id           JOIN Primes p ON pf.prime_id = p.prime_id           WHERE pf.number_id = 210;
SELECT n.number_id, n.number, pf.prime_id, p.prime, pf.exponent FROM Numbers pf           JOIN PrimeFactors pf ON n.number_id = pf.number_id           JOIN Primes p ON pf.prime_id = p.prime_id           WHERE n.number_id = 210;
SELECT n.number_id, n.number, pf.prime_id, p.prime, pf.exponent FROM Numbers pf JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id WHERE n.number_id = 210;
SELECT n.number_id, n.number, pf.prime_id, p.prime, pf.exponent FROM Numbers n JOIN PrimeFactors pf ON n.number_id = pf.number_id JOIN Primes p ON pf.prime_id = p.prime_id WHERE n.number_id = 210;
MatchingNumbers AS (
    -- Find number_id values that contain at least the given prime factors
    SELECT pf.number_id
    FROM PrimeFactors pf
    JOIN GivenFactors gf ON pf.prime_id = gf.prime_id AND pf.exponent = gf.exponent
    GROUP BY pf.number_id
    HAVING COUNT(*) = (SELECT COUNT(*) FROM GivenFactors)  -- Ensure all given factors exist
) ;
MatchingNumbers AS (          SELECT pf.number_id     FROM PrimeFactors pf     JOIN GivenFactors gf ON pf.prime_id = gf.prime_id AND pf.exponent = gf.exponent     GROUP BY pf.number_id     HAVING COUNT(*) = (SELECT COUNT(*) FROM GivenFactors)   );
MatchingNumbers AS (
    SELECT pf.number_id
    FROM PrimeFactors pf ;
MatchingNumbers AS (     SELECT pf.number_id     FROM PrimeFactors pf;

DELETE FROM Numbers WHERE number_id > 1;
DELETE FROM PrimeFactors WHERE 1;
DELETE FROM Numbers WHERE number_id > 1;

ALTER TABLE Numbers      AUTO_INCREMENT = 2;
ALTER TABLE PrimeFactors AUTO_INCREMENT = 1;
