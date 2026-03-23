import string

with open("Prove_Prime_25K.txt") as f:
    s = f.read()

bad = [(i, c, ord(c)) for i, c in enumerate(s) if c not in string.digits]

print(f"Found {len(bad)} invalid characters")

for i, c, o in bad[:20]:
    print(f"Position {i}: '{c}' (ASCII {o})")
