# Given SQL result
sql_results = [
    {'number': 38, 'total_factors': 2, 'unique_factors': 2, 'prime_id': 1, 'exponent': 1},
    {'number': 38, 'total_factors': 2, 'unique_factors': 2, 'prime_id': 8, 'exponent': 1},
    {'number': 39, 'total_factors': 2, 'unique_factors': 2, 'prime_id': 2, 'exponent': 1},
    {'number': 39, 'total_factors': 2, 'unique_factors': 2, 'prime_id': 6, 'exponent': 1},
    {'number': 40, 'total_factors': 4, 'unique_factors': 2, 'prime_id': 1, 'exponent': 3},
    {'number': 40, 'total_factors': 4, 'unique_factors': 2, 'prime_id': 3, 'exponent': 1}
]

# Transform SQL results into desired dictionary structure
Numbers = {}

for row in sql_results:
    num = row['number']
    
    # If the number is not already in the dictionary, initialize it
    if num not in Numbers:
        Numbers[num] = {
            'total_factors': row['total_factors'],
            'unique_factors': row['unique_factors'],
            'primefactors': {}
        }
    
    # Add prime factors
    Numbers[num]['primefactors'][row['prime_id']] = row['exponent']

# Print result
from pprint import pprint
pprint(Numbers)

