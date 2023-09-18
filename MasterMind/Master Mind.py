import random
import re
from os import system, name 
from sys import argv

puzzle_size=4
if len(argv) >= 2:
    puzzle_size = int(argv[1])

# define our clear function 
def clear(): 
    if name == 'nt': 
        _ = system('cls') 
    else: 
        _ = system('clear') 


def make_puzzle( puzzle_size = 4 ):

    # populates puzzle's digits
    answer = []
    for index in range(puzzle_size):
      answer.append(random.randint(0, 9))
  
    # DEBUG use to see answers at start
    # print(answer)
    return tuple(answer)


def process_guess(puzzle, guess_string, previous_guesses):
    # print("puzzle is ", puzzle)
    # print("guess is ", guess_string)
    guess = re.findall("\d", guess_string)
    # print(guess) 
    if len(guess) == len(puzzle):
      correct  = determine_number_correct(  puzzle, guess)
      in_place = determine_number_in_place( puzzle, guess)
      previous_guesses.append( { "guess": guess, "correct": correct, "in_place": in_place } )
      return {  "correct" : determine_number_correct(puzzle, guess), 
               "in_place" : determine_number_in_place(puzzle, guess) }
    else:
      return { "error" : "Input incorrect number of digits, excpected %d got %d" % (len(puzzle), len(guess)) }
      

def determine_number_correct(puzzle, guess):
    puzzle_digits = {}
    for digit in range(10):
      puzzle_digits[str(digit)] = 0
    for index in range(len(puzzle)):
      puzzle_digits[str(puzzle[index])] += 1

    guess_digits = {}
    for digit in range(10):
      guess_digits[str(digit)] = 0
    for index in range(len(guess)):
      guess_digits[str(guess[index])] += 1

    correct = 0
    for digit in range(10):
      correct += min(puzzle_digits[str(digit)], guess_digits[str(digit)])

    return correct


def determine_number_in_place(puzzle, guess):
    in_place = 0
    for index in range(len(puzzle)):
      if puzzle[index] == int(guess[index]):
        in_place += 1
    return in_place

puzzle = make_puzzle(puzzle_size)
guesses = 0
guess_history = []
# print(puzzle)

# Game Loop
while (1):
    guesses += 1
    user_input = input("\n Input your %d guess of %d decimal digits, q to quit, l to list previous guesses: " % (guesses, len(puzzle)) )
    if user_input == 'q':
        print("you want to end our wonderful relationship :(")
        break
    elif user_input == 'l':
        print("Here are your past guesses:")
        for event in guess_history:
            print("%s: (%d,%d)" % (event["guess"], event["correct"], event["in_place"]))
    elif user_input == '':
        print("you can't even input anything, COME ON...")
    else:
        # print("calling process_guess()")
        results = process_guess(puzzle, user_input, guess_history )
        clear()
        if "error" in results:
          print("\n", results["error"])
          continue
        else:
          if (results["correct"] == results["in_place"]) and (results["in_place"] == len(puzzle)):
            print("\n YOU SOLVED THE PUZZLE IN %d GUESSES!!!\n\n" % guesses)
            print("Here are your past guesses:")
            for event in guess_history:
                print("%s: (%d,%d)" % (event["guess"], event["correct"], event["in_place"]))
            break
          else:
            print("\n You got %d digits correct and %d digits in the right position." % (results["correct"], results["in_place"]))
