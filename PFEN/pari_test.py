import cypari2
pari = cypari2.Pari()
# Test with a known prime
print(pari.ispseudoprime(pari("999999999999999989")))
