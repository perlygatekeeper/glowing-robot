ALTER TABLE Numbers 
ADD COLUMN total_factor INT UNSIGNED NOT NULL DEFAULT 0,
ADD COLUMN unique_factors INT UNSIGNED NOT NULL DEFAULT 0;

UPDATE Numbers n
SET n.total_factors = (
    SELECT COALESCE(SUM(pf.exponent), 0)
    FROM PrimeFactors pf
    WHERE pf.number_id = n.number_id
);


UPDATE Numbers n
SET n.unique_factors = (
    SELECT COALESCE(COUNT(pf.prime_id), 0)
    FROM PrimeFactors pf
    WHERE pf.number_id = n.number_id
);



