from numpy import random

puzzle_size = 4

def make_puzzle(puzzle_size=4):
    # puzzle will be stored as a puzzle_size - tuple
    x = random.randint(10, size=(puzzle_size))
    y = lambda y : foreach item in y item
    list_of 
    print(x)
    print(type(x))
    print(dir(x))
    print(x.all)
    return x

def process_guess():
    pass

def determine_number_correct():
    pass

def determine_number_in_place():
    pass

make_puzzle(puzzle_size)
# Game Loop
while (1):
   user_input = input("Input guess of %d decimal digits, q to quit, l to list previous guesses: " % puzzle_size)
   print("your input was %r" % user_input)
   if user_input == 'q':
       print("you want to end our wonderful relationship :(")
       break
   elif user_input == 'l':
       print("here I would list past guesses")
   elif user_input == '':
       print("you can't even input anything, COME ON...")
   else:
       print("this could be a guess")
