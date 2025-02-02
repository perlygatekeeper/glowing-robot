_HiStOrY_V2_
show\040tables
;
show\040tables;
?
show\040tables;
\134s
show\040databases;
use\040mysql
show\040tables
;
select\040*\040from\040user
;
\134s
flush\040privileges;
select\040*\040from\040user;
?
show\040databases;
create\040database\040PFEN
;
use\040PFEN
show\040tables
;
create\040table\040Primes\040(\040prime_id\040INT\040NOT\040NULL,\040sequence\040INT\040UNSIGNED,\040prime\040BIGINT(255)\040UNSIGNED,\040PRIMARY\040KEY\040(prime_id)\040);\040
create\040table\040Primes\040(\040number_id\040INT\040UNSIGNED\040NOT\040NULL,\040number\040BIGINT\040UNSIGNED,\040number\040BIGINT(255)\040UNSIGNED,\040PRIMARY\040KEY\040(number_id)\040);
create\040table\040Numbers\040(\040number_id\040INT\040UNSIGNED\040NOT\040NULL,\040number\040BIGINT\040UNSIGNED,\040number\040BIGINT(255)\040UNSIGNED,\040PRIMARY\040KEY\040(number_id)\040);
show\040tables
;
create\040table\040Numbers\040(\040number_id\040INT\040UNSIGNED\040NOT\040NULL,\040number\040BIGINT\040UNSIGNED,\040number\040BIGINT\040UNSIGNED,\040PRIMARY\040KEY\040(number_id)\040);
create\040table\040Numbers\040(\040number_id\040INT\040UNSIGNED\040NOT\040NULL,\040number\040BIGINT\040UNSIGNED,\040PRIMARY\040KEY\040(number_id)\040);
CREATE\040TABLE\040PrimeFactors\040(
\040\040\040\040prime_id\040INT,
\040\040\040\040number_id\040INT,
\040\040\040\040PRIMARY\040KEY\040(prime_id,\040number_id),
\040\040\040\040FOREIGN\040KEY\040(prime_id)\040REFERENCES\040Primes(prime_id),
\040\040\040\040FOREIGN\040KEY\040(number_id)\040REFERENCES\040Numbers(number_id)
);
CREATE\040TABLE\040PrimeFactors\040(\040\040\040\040\040prime_id\040INT,\040\040\040\040\040number_id\040INT,\040\040\040\040\040PRIMARY\040KEY\040(prime_id,\040number_id),\040\040\040\040\040FOREIGN\040KEY\040(prime_id)\040REFERENCES\040Primes(prime_id),\040\040\040\040\040FOREIGN\040KEY\040(number_id)\040REFERENCES\040Numbers(number_id)\040);
CREATE\040TABLE\040PrimeFactors\040(\040\040\040\040\040prime_id\040INT,\040\040\040\040\040number_id\040UNSIGNED\040INT,\040\040\040\040\040PRIMARY\040KEY\040(prime_id,\040number_id),\040\040\040\040\040FOREIGN\040KEY\040(prime_id)\040REFERENCES\040Primes(prime_id),\040\040\040\040\040FOREIGN\040KEY\040(number_id)\040REFERENCES\040Numbers(number_id)\040);
CREATE\040TABLE\040PrimeFactors\040(\040prime_id\040INT,\040number_id\040INT\040UNSIGNED,\040PRIMARY\040KEY\040(prime_id,\040number_id),\040FOREIGN\040KEY\040(prime_id)\040REFERENCES\040Primes(prime_id),\040\040\040\040\040FOREIGN\040KEY\040(number_id)\040REFERENCES\040Numbers(number_id)\040);
show\040tables;
describe\040tables;
discribe\040tables;
show\040full\040tables;
describe\040table\040Numbers;
describe\040Numbers;
describe\040Primes;
describe\040PrimeFactors;
?
quit
show\040databases;
use;
?
\134P
\134p
\134s
status
use\040mysql;
flush\040privileges;
show\040databases;
DROP\040DATABASE\040IF\040EXISTS\040PFEN;
create\040database\040PFEN;
show\040databases;
flush\040privileges;
use\040PFEN;
drop\040table\040if\040exists\040Primes;
drop\040table\040if\040exists\040Numbers;
drop\040table\040if\040exists\040PrimeFactors;
create\040table\040Primes\040\040(\040prime_id\040\040INT\040UNSIGNED\040NOT\040NULL,\040sequence\040INT\040UNSIGNED,\040\040\040prime\040BIGINT(255)\040UNSIGNED,\040PRIMARY\040KEY\040(prime_id)\040);\040
create\040table\040Numbers\040(\040number_id\040INT\040UNSIGNED\040NOT\040NULL,\040number\040BIGINT\040UNSIGNED,\040PRIMARY\040KEY\040(number_id)\040);
create\040table\040PrimeFactors\040(
\040\040\040\040primefactor_id\040INT\040UNSIGNED,
\040\040\040\040prime_id\040INT\040UNSIGNED,
\040\040\040\040number_id\040INT\040UNSIGNED,
\040\040\040\040exponent\040INT\040UNSIGNED,
\040\040\040\040PRIMARY\040KEY\040(primefactor_id),
\040\040\040\040FOREIGN\040KEY\040(prime_id)\040REFERENCES\040Primes(prime_id),
\040\040\040\040FOREIGN\040KEY\040(number_id)\040REFERENCES\040Numbers(number_id)
);
create\040table\040PrimeFactors\040(\040\040\040\040\040primefactor_id\040INT\040UNSIGNED,\040\040\040\040\040prime_id\040INT\040UNSIGNED,\040\040\040\040\040number_id\040INT\040UNSIGNED,\040\040\040\040\040exponent\040INT\040UNSIGNED,\040\040\040\040\040PRIMARY\040KEY\040(primefactor_id),\040\040\040\040\040FOREIGN\040KEY\040(prime_id)\040REFERENCES\040Primes(prime_id),\040\040\040\040\040FOREIGN\040KEY\040(number_id)\040REFERENCES\040Numbers(number_id)\040);
describe\040Numbers;
describe\040Primes;
describe\040PrimeFactors;
show\040tables;
quit
use\040mysql
show\040tables;
select\040*\040from\040user;
flush\040privileges;
quit
use\040PFEN;
describe\040primes;
quit
use\040PFEN;
describe\040primes;
select\040*\040from\040primes;
quit
use\040mysql;
show\040tables;
select\040*\040from\040USER;
quit
use\040mysql;
select\040*\040from\040USER;
quit
ALTER\040USER\040PFEN_Modify\040INDENTIFIED\040BY\040"f02d355930305028e28373caa299cc54";
ALTER\040USER\040PFEN_Modify@localehost\040\040INDENTIFIED\040BY\040\040"f02d355930305028e28373caa299cc54";
ALTER\040USER\040'PFEN_Modify'@'localehost'\040INDENTIFIED\040BY\040\040"f02d355930305028e28373caa299cc54";
SELECT\040User,\040Host\040from\040mysql.user;
ALTER\040USER\040'PFEN_Modify'@'localhost'\040INDENTIFIED\040BY\040\040"f02d355930305028e28373caa299cc54";
flush\040privileges;
quit
use\040PFEN;
show\040tables
;l
describe\040tables;
l\040describe\040tables;
describe\040tables;
describe\040Primes;
select\040*\040from\040primes
;
quit
use\040mysql;
select\040*\040from\040user\040where\040user\040=\040'PFEN_Modify';
show\040tables;
select\040*\040from\040general_log;
select\040*\040from\040db;
quit
use\040PFEN;
show\040tables;
describe\040table\040Numbers;
describe\040Numbers;
INSERT\040INTO\040Numbers\040(number)\040VALUES\040(2);
describe\040Numbers;
select\040*\040from\040numbers;
quit
use\040PFEN;
describe\040primes;
quit
use\040PFEN;
select\040*\040from\040primes;
quit
use\040PFEN;
DROP\040TABLE\040primes;
drop\040table\040if\040exists\040Primes;
drop\040table\040if\040exists\040Numbers;
drop\040table\040if\040exists\040PrimeFactors;
drop\040table\040if\040exists\040Primes;
drop\040table\040if\040exists\040Numbers;
show\040tables;
create\040table\040Primes\040\040(\040prime_id\040\040BIGINT\040UNSIGNED\040AUTO_INCREMENT\040PRIMARY\040KEY,\040sequence\040INT\040UNSIGNED,\040\040\040prime\040BIGINT(255)\040UNSIGNED\040);
create\040table\040Numbers\040(\040number_id\040BIGINT\040UNSIGNED\040AUTO_INCREMENT\040PRIMARY\040KEY,\040number\040BIGINT\040UNSIGNED\040);
create\040table\040PrimeFactors\040(
\040\040\040\040primefactor_id\040INT\040UNSIGNED\040AUTO_INCREMENT\040PRIMARY\040KEY,
\040\040\040\040prime_id\040BIGINT\040UNSIGNED,
\040\040\040\040number_id\040BIGINT\040UNSIGNED,
\040\040\040\040exponent\040INT\040UNSIGNED,
\040\040\040\040FOREIGN\040KEY\040(prime_id)\040REFERENCES\040Primes(prime_id),
\040\040\040\040FOREIGN\040KEY\040(number_id)\040REFERENCES\040Numbers(number_id)
);
create\040table\040PrimeFactors\040(\040\040\040\040\040primefactor_id\040INT\040UNSIGNED\040AUTO_INCREMENT\040PRIMARY\040KEY,\040\040\040\040\040prime_id\040BIGINT\040UNSIGNED,\040\040\040\040\040number_id\040BIGINT\040UNSIGNED,\040\040\040\040\040exponent\040INT\040UNSIGNED,\040\040\040\040\040FOREIGN\040KEY\040(prime_id)\040REFERENCES\040Primes(prime_id),\040\040\040\040\040FOREIGN\040KEY\040(number_id)\040REFERENCES\040Numbers(number_id)\040);
show\040tables;
quit
use\040PFEN;
select\040*\040from\040numbers
;
select\040*\040from\040prime_factors;
select\040*\040from\040primefactors;
quit
DROP\040DATABASE\040IF\040EXISTS\040PFEN;
create\040database\040PFEN;
use\040mysql;
select\040*\040from\040user;
select\040*\040from\040db;
GRANT\040DELETE\040ON\040PFEN\040TO\040'PFEN_Modify'@'localhost';
GRANT\040DELETE\040ON\040PFEN.*\040TO\040'PFEN_Modify'@'localhost';
flush\040privileges;
select\040*\040from\040db;
select\040*\040from\040tables;
show\040tables;
select\040*\040from\040tables_priv;
show\040tables;
select\040*\040from\040tables_priv;
select\040*\040from\040user;
show\040tables;
select\040*\040from\040tables_priv;
create\040table\040Primes\040\040(\040prime_id\040\040BIGINT\040UNSIGNED\040AUTO_INCREMENT\040PRIMARY\040KEY,\040sequence\040INT\040UNSIGNED\040UNIQUE,\040\040\040prime\040BIGINT(255)\040UNSIGNED\040UNIQUE\040);
create\040table\040Numbers\040(\040number_id\040BIGINT\040UNSIGNED\040AUTO_INCREMENT\040PRIMARY\040KEY,\040number\040BIGINT\040UNSIGNED\040UNIQUE\040);
create\040table\040PrimeFactors\040(
\040\040\040\040primefactor_id\040INT\040UNSIGNED\040AUTO_INCREMENT\040PRIMARY\040KEY,
\040\040\040\040prime_id\040BIGINT\040UNSIGNED,
\040\040\040\040number_id\040BIGINT\040UNSIGNED,
\040\040\040\040exponent\040INT\040UNSIGNED,
\040\040\040\040FOREIGN\040KEY\040(prime_id)\040REFERENCES\040Primes(prime_id),
\040\040\040\040FOREIGN\040KEY\040(number_id)\040REFERENCES\040Numbers(number_id)
);
create\040table\040PrimeFactors\040(\040\040\040\040\040primefactor_id\040INT\040UNSIGNED\040AUTO_INCREMENT\040PRIMARY\040KEY,\040\040\040\040\040prime_id\040BIGINT\040UNSIGNED,\040\040\040\040\040number_id\040BIGINT\040UNSIGNED,\040\040\040\040\040exponent\040INT\040UNSIGNED,\040\040\040\040\040FOREIGN\040KEY\040(prime_id)\040REFERENCES\040Primes(prime_id),\040\040\040\040\040FOREIGN\040KEY\040(number_id)\040REFERENCES\040Numbers(number_id)\040);
describe\040Numbers;
describe\040Primes;
describe\040PrimeFactors;
ALTER\040TABLE\040primes\040AUTO_INCREMENT\040=\0401;
ALTER\040TABLE\040numbers\040AUTO_INCREMENT\040=\0401;
ALTER\040TABLE\040PrimeFactors\040AUTO_INCREMENT\040=\0401;
use\040PFEN;
INSERT\040INTO\040Numbers\040(number)\040VALUES\040(1)
;
show\040tables
;
use\040PFEN;
show\040tables;
use\040mysql
show\040tables;
drop\040table\040Numbers
;
drop\040PrimeFactors;
drop\040table\040PrimeFactors
;
drop\040table\040Primes;
drop\040table\040Numbers
;
use\040PFEN;
create\040table\040Numbers\040(\040number_id\040BIGINT\040UNSIGNED\040AUTO_INCREMENT\040PRIMARY\040KEY,\040number\040BIGINT\040UNSIGNED\040UNIQUE\040);
create\040table\040Primes\040\040(\040prime_id\040\040BIGINT\040UNSIGNED\040AUTO_INCREMENT\040PRIMARY\040KEY,\040sequence\040INT\040UNSIGNED\040UNIQUE,\040\040\040prime\040BIGINT(255)\040UNSIGNED\040UNIQUE\040);
create\040table\040PrimeFactors\040(\040\040\040\040\040primefactor_id\040INT\040UNSIGNED\040AUTO_INCREMENT\040PRIMARY\040KEY,\040\040\040\040\040prime_id\040BIGINT\040UNSIGNED,\040\040\040\040\040number_id\040BIGINT\040UNSIGNED,\040\040\040\040\040exponent\040INT\040UNSIGNED,\040\040\040\040\040FOREIGN\040KEY\040(prime_id)\040REFERENCES\040Primes(prime_id),\040\040\040\040\040FOREIGN\040KEY\040(number_id)\040REFERENCES\040Numbers(number_id)\040);
ALTER\040TABLE\040primes\040AUTO_INCREMENT\040=\0401;
ALTER\040TABLE\040numbers\040AUTO_INCREMENT\040=\0401;
ALTER\040TABLE\040primefactors\040AUTO_INCREMENT\040=\0401;
flush\040privileges;
INSERT\040INTO\040Numbers\040(number)\040VALUES\040(1);
quit
use\040PFEN;
select\040*\040from\040numbers;
ALTER\040TABLE\040numbers\040AUTO_INCREMENT\040=\0402;
quit
use\040PFEN;
ALTER\040TABLE\040numbers\040AUTO_INCREMENT\040=\0402;
delect\040from\040numbers\040where\040number_id\040=\0402;
select\040*\040from\040numbers;
delete\040from\040numbers\040where\040number_id\040=\0402;
quit
use\040PFEN;
ALTER\040TABLE\040numbers\040AUTO_INCREMENT\040=\0402;
select\040*\040from\040numbers;
delete\040from\040numbers\040where\040number_id\040=\0402;
SELECT\040AUTO_INCREMENT
FROM\040INFORMATION_SCHEMA.TABLES
WHERE\040TABLE_SCHEMA\040=\040'database_name'\040
AND\040TABLE_NAME\040=\040'numbers';
SELECT\040AUTO_INCREMENT\040FROM\040INFORMATION_SCHEMA.TABLES\040WHERE\040TABLE_SCHEMA\040=\040'database_name'\040\040AND\040TABLE_NAME\040=\040'numbers';
user\040PFEN;
use\040PFEN;
show\040table\040status\040numbers
;
show\040table\040status\040like\040numbers;
show\040table\040status\040like\040'numbers';
select\040*\040from\040numbers;
delete\040from\040numbers\040where\040number\040=\0402;
select\040*\040from\040numbers;
show\040table\040status\040like\040'numbers';
ALTER\040TABLE\040numbers\040AUTO_INCREMENT\040=\0402;
show\040table\040status\040like\040'numbers';
flush\040privileges;
quit
select\040max(number)\040from\040numbers;
use\040PFEN;
select\040max(number)\040from\040numbers;
quit
use\040PFEN;
ALTER\040TABLE\040Numbers\040
ADD\040COLUMN\040total_factor\040INT\040UNSIGNED\040NOT\040NULL\040DEFAULT\0400,
ADD\040COLUMN\040unique_factors\040INT\040UNSIGNED\040NOT\040NULL\040DEFAULT\0400;
ALTER TABLE Numbers  ADD COLUMN total_factor INT UNSIGNED NOT NULL DEFAULT 0, ADD COLUMN unique_factors INT UNSIGNED NOT NULL DEFAULT 0;
describe\040numbers;
ALTER TABLE Numbers RENAME COLUMN total_factor to total_factors;
ALTER TABLE Numbers CHANGE COLUMN total_factor total_factors INT UNSIGNED NOT NULL DEFAULT 0;;
describe\040numbers;
quit
use\040PFEN;
UPDATE\040Numbers\040n
SET\040n.total_factors=\040(
\040\040\040\040SELECT\040COALESCE(SUM(pf.exponent),\0400)
\040\040\040\040FROM\040PrimeFactors\040pf
\040\040\040\040WHERE\040pf.number_id\040=\040n.number_id
);
UPDATE\040Numbers\040n\040SET\040n.total_factors=\040(\040\040\040\040\040SELECT\040COALESCE(SUM(pf.exponent),\0400)\040\040\040\040\040FROM\040PrimeFactors\040pf\040\040\040\040\040WHERE\040pf.number_id\040=\040n.number_id\040);
UPDATE\040Numbers\040n
SET\040n.unique_factors\040=\040(
\040\040\040\040SELECT\040COALESCE(COUNT(pf.prime_id),\0400)
\040\040\040\040FROM\040PrimeFactors\040pf
\040\040\040\040WHERE\040pf.number_id\040=\040n.number_id
);
UPDATE\040Numbers\040n\040SET\040n.unique_factors\040=\040(\040\040\040\040\040SELECT\040COALESCE(COUNT(pf.prime_id),\0400)\040\040\040\040\040FROM\040PrimeFactors\040pf\040\040\040\040\040WHERE\040pf.number_id\040=\040n.number_id\040);
select\040*\040Numbers\040WHERE\040number_id\040<\04040;
SELECT\040*\040FROM\040Numbers\040WHERE\040number_id\040<\04040;
SELECT\040*\040FROM\040Numbers\040WHERE\040total_factors\040=\0400;
SELECT\040*\040FROM\040Numbers\040WHERE\040total_factors\040=\0400\040LIMIT\040100;
SELECT\040*\040FROM\040Numbers\040WHERE\040total_factors\040=\0400\040LIMIT\04010;
SELECT\040*\040FROM\040Numbers\040WHERE\040number_id\040>\04049999\040AND\040number_id\040<\04050023;
SELECT\040*\040FROM\040Numbers\040WHERE\040number_id\040>\04049999\040AND\040number_id\040<\04050029;
SELECT\040*\040FROM\040Numbers\040WHERE\040total_factors\040=\0400\040LIMIT\04010;
SELECT\040*\040FROM\040Numbers\040WHERE\040number_id\040<\04040;
SELECT\040*\040FROM\040Numbers\040WHERE\040total_factors\040=\0400\040LIMIT\04010;
SELECT\040*\040FROM\040Numbers\040WHERE\040number_id\040<\04040;
SELECT\040*\040FROM\040Numbers\040WHERE\040total_factors\040=\0400\040LIMIT\04040;
select\040*\040from\040primes\040where\040prime\040>\04050020\040and\040prime\040<\04050388;
select\040*\040from\040prime_factors\040where\040prime_id\040>\0405132\040and\040prime_id\040<\0405175;
select\040*\040from\040primefactors\040where\040prime_id\040>\0405132\040and\040prime_id\040<\0405175;
select\040*\040from\040primefactors\040where\040prime_id\040>\0405132\040and\040prime_id\040<\0405175\040LIMIT\040100;
select\040*\040from\040primefactors\040where\040prime_id\040>\0405132\040and\040prime_id\040<\0405175\040LIMIT\04040;
SELECT\040n.number,\040GROUP_CONCAT(CONCAT(p.prime,\040'^',\040pf.exponent)\040SEPARATOR\040'\040x\040')\040AS\040factorization
FROM\040Numbers\040n
JOIN\040PrimeFactors\040pf\040ON\040n.number_id\040=\040pf.number_id
JOIN\040Primes\040p\040ON\040pf.prime_id\040=\040p.prime_id
GROUP\040BY\040n.number_value
ORDER\040BY\040n.number_value
WHERE\040prime_id\040>\0405132\040and\040prime_id\040<\0405175;
SELECT\040n.number,\040GROUP_CONCAT(CONCAT(p.prime,\040'^',\040pf.exponent)\040SEPARATOR\040'\040x\040')\040AS\040factorization\040FROM\040Numbers\040n\040JOIN\040PrimeFactors\040pf\040ON\040n.number_id\040=\040pf.number_id\040JOIN\040Primes\040p\040ON\040pf.prime_id\040=\040p.prime_id\040GROUP\040BY\040n.number_value\040ORDER\040BY\040n.number_value\040WHERE\040prime_id\040>\0405132\040and\040prime_id\040<\0405175;
SELECT\040n.number,\040GROUP_CONCAT(CONCAT(p.prime,\040'^',\040pf.exponent)\040SEPARATOR\040'\040x\040')\040AS\040factorization\040FROM\040Numbers\040n\040JOIN\040PrimeFactors\040pf\040ON\040n.number_id\040=\040pf.number_id\040JOIN\040Primes\040p\040ON\040pf.prime_id\040=\040p.prime_id\040GROUP\040BY\040n.number_value\040ORDER\040BY\040n.number_value\040WHERE\040pf.prime_id\040>\0405132\040and\040pf.prime_id\040<\0405175;
SELECT\040n.number,\040GROUP_CONCAT(CONCAT(p.prime,\040'^',\040pf.exponent)\040SEPARATOR\040'\040x\040')\040AS\040factorization\040FROM\040Numbers\040n\040JOIN\040PrimeFactors\040pf\040ON\040n.number_id\040=\040pf.number_id\040JOIN\040Primes\040p\040ON\040pf.prime_id\040=\040p.prime_id\040WHERE\040pf.prime_id\040>\0405132\040and\040pf.prime_id\040<\0405175;
SELECT\040n.number,\040GROUP_CONCAT(CONCAT(p.prime,\040'^',\040pf.exponent)\040SEPARATOR\040'\040x\040')\040AS\040factorization\040FROM\040Numbers\040n\040JOIN\040PrimeFactors\040pf\040ON\040n.number_id\040=\040pf.number_id\040JOIN\040Primes\040p\040ON\040pf.prime_id\040=\040p.prime_id\040GROUP\040BY\040n.number_value\040\040WHERE\040pf.prime_id\040>\0405132\040and\040pf.prime_id\040<\0405175;
SELECT\040n.number,\040GROUP_CONCAT(CONCAT(p.prime,\040'^',\040pf.exponent)\040SEPARATOR\040'\040x\040')\040AS\040factorization\040FROM\040Numbers\040n\040JOIN\040PrimeFactors\040pf\040ON\040n.number_id\040=\040pf.number_id\040JOIN\040Primes\040p\040ON\040pf.prime_id\040=\040p.prime_id\040\040WHERE\040pf.prime_id\040>\0405132\040and\040pf.prime_id\040<\0405175\040GROUP\040BY\040n.number_value;
SELECT\040n.number,\040GROUP_CONCAT(CONCAT(p.prime,\040'^',\040pf.exponent)\040SEPARATOR\040'\040x\040')\040AS\040factorization\040FROM\040Numbers\040n\040JOIN\040PrimeFactors\040pf\040ON\040n.number_id\040=\040pf.number_id\040JOIN\040Primes\040p\040ON\040pf.prime_id\040=\040p.prime_id\040\040WHERE\040pf.prime_id\040>\0405132\040and\040pf.prime_id\040<\0405175\040GROUP\040BY\040n.number;
SELECT\040n.number,\040GROUP_CONCAT(CONCAT(p.prime,\040'^',\040pf.exponent)\040SEPARATOR\040'\040x\040')\040AS\040factorization\040FROM\040Numbers\040n\040JOIN\040PrimeFactors\040pf\040ON\040n.number_id\040=\040pf.number_id\040JOIN\040Primes\040p\040ON\040pf.prime_id\040=\040p.prime_id\040\040WHERE\040pf.prime_id\040>\0405132\040and\040pf.prime_id\040<\0405175\040GROUP\040BY\040n.number\040LIMIT\04035;
SELECT\040n.nubmer_id,\040n.number,\040p.prime_id,\040GROUP_CONCAT(CONCAT(p.prime,\040'^',\040pf.exponent)\040SEPARATOR\040'\040x\040')\040AS\040factorization\040FROM\040Numbers\040n\040JOIN\040PrimeFactors\040pf\040ON\040n.number_id\040=\040pf.number_id\040JOIN\040Primes\040p\040ON\040pf.prime_id\040=\040p.prime_id\040\040WHERE\040pf.prime_id\040>\0405132\040and\040pf.prime_id\040<\0405175\040GROUP\040BY\040n.number\040LIMIT\04035;
SELECT\040n.number_id,\040n.number,\040p.prime_id,\040GROUP_CONCAT(CONCAT(p.prime,\040'^',\040pf.exponent)\040SEPARATOR\040'\040x\040')\040AS\040factorization\040FROM\040Numbers\040n\040JOIN\040PrimeFactors\040pf\040ON\040n.number_id\040=\040pf.number_id\040JOIN\040Primes\040p\040ON\040pf.prime_id\040=\040p.prime_id\040\040WHERE\040pf.prime_id\040>\0405132\040and\040pf.prime_id\040<\0405175\040GROUP\040BY\040n.number\040LIMIT\04035;
SELECT\040n.number_id,\040n.number,\040p.prime_id,\040GROUP_CONCAT(CONCAT(p.prime,\040'^',\040pf.exponent)\040SEPARATOR\040'\040x\040')\040AS\040factorization\040FROM\040Numbers\040n\040JOIN\040PrimeFactors\040pf\040ON\040n.number_id\040=\040pf.number_id\040JOIN\040Primes\040p\040ON\040pf.prime_id\040=\040p.prime_id\040\040WHERE\040pf.prime_id\040>\0405132\040and\040pf.prime_id\040<\0405175\040GROUP\040BY\040n.number,\040n.number_id\040LIMIT\04035;
SELECT\040n.number_id,\040n.number,\040p.prime_id,\040GROUP_CONCAT(CONCAT(p.prime,\040'^',\040pf.exponent)\040SEPARATOR\040'\040x\040')\040AS\040factorization\040FROM\040Numbers\040n\040JOIN\040PrimeFactors\040pf\040ON\040n.number_id\040=\040pf.number_id\040JOIN\040Primes\040p\040ON\040pf.prime_id\040=\040p.prime_id\040\040WHERE\040pf.prime_id\040>\0405132\040and\040pf.prime_id\040<\0405175\040GROUP\040BY\040n.number,\040n.number_id,pf.prime_id\040LIMIT\04035;
select\040*\040from\040primes\040where\040prime_id=5147\040or\040prime=5147;
quit
