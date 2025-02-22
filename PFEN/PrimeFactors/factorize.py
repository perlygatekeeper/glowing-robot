import math
from db_module import get_prime_db, get_primefactor_db

# Get user input
try:
        user_input = int(input("Enter an integer of which you wish to find the prime factors: "))
        prime_limit = min(10000000, (user_input/2))
        prime_db = get_prime_db(prime_limit)
        primefactor_db = get_primefactor_db(prime_db)
        print(primefactor_db.factorize_number(user_input))  # Call function with user input
except ValueError:
        print("Invalid input! Please enter a valid integer.")
