SELECT n.number, GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ') AS factorization
FROM Numbers n
JOIN PrimeFactors pf ON n.number_id = pf.number_id
JOIN Primes p ON pf.prime_id = p.prime_id
GROUP BY n.number_value
ORDER BY n.number_value;
