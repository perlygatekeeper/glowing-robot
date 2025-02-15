UPDATE Primes p1
JOIN Primes p2 ON p2.prime_id = p1.prime_id + 1
SET p1.prime_gap = p2.prime - p1.prime;
