import random

def fermat_primality_test(n, k=5):
    """ Perform the Fermat primality test on n using k iterations. """
    # if n <= 1:
    #     return False
    # if n in (2, 3):
    #     return True  # 2 and 3 are prime numbers
    
    # Run the test k times for different random values of 'a'
    for _ in range(k):
        a = random.randint(2, n - 2)  # Choose a random integer in range [2, n-2]
        if pow(a, n - 1, n) != 1:  # Compute (a^(n-1)) % n
            return False  # Definitely composite

    return True  # Probably prime

# Example usage:
# n = 561  # Try different values
k = 5  # Number of iterations

# Get user input
# try:
#    user_input = int(input("Enter an integer of which you wish to test for primality using the Fermat test: "))
#    print(f"Is {user_input} prime? {'Yes' if fermat_primality_test(user_input, k) else 'No'}")
#except ValueError:
#    print("Invalid input! Please enter a valid integer.")

# n = 10**2048 + 1
exp = 2**14
n = 10**exp + 1

# print(n%11)
# exit()

# 1 -> 3 -> 7 -> 9 -> 11
steps = [ 2, 4, 2, 2 ]
i = 0
add = 0
found = False
while (not found and i <= 1000):
    add += steps[ ( i % 4 ) ]
    n   += steps[ ( i % 4 ) ]
    i = (i + 1)
    if add % 3 == 1:
        # print(n)
        # break
        print (f"{i} skipped divisible by 3")
        continue
    if add % 7 == 2:
        print (f"{i} skipped divisible by 7")
        continue
    if add % 11 == 9:
        print (f"{i} skipped divisible by 11")
        continue
    found = fermat_primality_test(n, k)
    print (f"{i}")
if found:
    print(f"first prime greater than 10^{exp} is:\n{n}")
else:
    print(f"no primes found up to:\n{n}")

