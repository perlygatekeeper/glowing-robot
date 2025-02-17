SELECT CONCAT(n.number,"="),
       CASE WHEN n.total_factors = 1
           THEN GROUP_CONCAT(CONCAT(p.prime, '^', pf.exponent) SEPARATOR ' x ')
           ELSE CONCAT(p.prime, '(', p.prime, ')' )
       END AS factorization
FROM Numbers n
JOIN PrimeFactors pf ON n.number_id = pf.number_id
JOIN Primes p ON p.prime_id = pf.number_id
GROUP BY n.number
ORDER BY n.number;
