import sys
from collections import deque, defaultdict
import re

# Example usage:
# string = "example"
# regex_patterns = [r'^ab$', r'^cd$', r'^xy$']  # Your regex patterns here
# validate_pairs(string, regex_patterns)

def main():
    if len(sys.argv) != 2:
        print("Usage: letter_boxed.py <12_letters>")
        return
    letters = sys.argv[1].lower()
    if len(letters) != 12:
        print("Error: Exactly 12 letters are required.")
        return
    if not re.fullmatch(r'[a-z]{12}', letters):
        print("Error: Exactly 12 LETTERS are required.")
        return

    # Corrected regex patterns using f-strings and proper variable naming
    patterns = [
        fr"[{letters[:3]}][{letters[3:]}]",        # [abc][defghijkl]
        fr"[{letters[3:6]}][{letters[:3]}{letters[6:]}]",  # [def][abcghijkl]
        fr"[{letters[6:9]}][{letters[:6]}{letters[9:]}]",  # [ghi][abcdefjkl]
        fr"[{letters[9:]}][{letters[:9]}]"         # [jkl][abcdefghi]
    ]
    eliminator = re.compile(fr"([^{letters}])")
    print(f"{patterns}\n{eliminator}")

    # Path to the web2 dictionary on macOS
    web2_path = '/usr/share/dict/web2'
    try:
        with open(web2_path, 'r') as f:
            words = [word.strip().lower() for word in f if len(word.strip()) >= 3]
    except FileNotFoundError:
        print(f"Error: The dictionary file at {web2_path} was not found.")
        return
    number_of_words = len(words)
    print(f"starting with {number_of_words} words.")
    
    valid_words = []
    for word in words:
        first10 = len(valid_words) <= 10 or re.search(r'^biblio',word) or re.search(r'scope',word)
        # Check if all characters are in the provided letters
        if re.search(eliminator, word):
            if first10:
                m = eliminator.search(word)
                # print(f"eliminating {word:>15} since it matches an illegal character '{m.group(0)}'")
            continue
        # Check for consecutive duplicate characters
        valid = True
        matches = True
        for i in range(len(word) - 1):
            if first10:
                print(f"{i} '{word[i]}'  '{word[i+1]}'")
            if word[i] == word[i+1]:
                valid = False
                break
            if first10:
                print(f"no double found here")
            a_pair_matched = False
            for pattern in patterns:
                if re.match(pattern, word[i:i+2]):
                    if first10:
                        print(f"this pattern {pattern} matches")
                    a_pair_matched = True
                    break
            matches = matches and a_pair_matched
            if first10:
                print(f"matches is now {matches} = match & {a_pair_matched}")
        if first10:
            print(f"for word: {word:>15} gives valid: {valid} and matches: {matches}")
        if valid and matches:
            valid_words.append(word)
    
    if not valid_words:
        print("No valid words found.")
        return
    else:
        print(f"{len(valid_words)} valid words found.")
        print("\n".join(valid_words))

    # Build a map from starting character to list of words
    start_char_map = defaultdict(list)
    for word in valid_words:
        start_char = word[0]
        start_char_map[start_char].append(word)
    
    # BFS to find the shortest valid sequences
    solutions = []
    visited = set()
    queue = deque()
    
    # Initialize the queue with all valid words as starting paths
    for word in valid_words:
        queue.append([word])
        visited.add((word[-1], 1))  # Track (last_char, path_length)
    
    while queue:
        current_path = queue.popleft()
        current_length = len(current_path)
        
        # Check if current path is a valid solution (length 4-6)
        if 4 <= current_length <= 6:
            solutions.append(current_path)
        
        # Stop processing if the path has reached maximum allowed length
        if current_length >= 6:
            continue
        
        last_char = current_path[-1][-1]
        next_words = start_char_map.get(last_char, [])
        
        for word in next_words:
            new_path = current_path + [word]
            new_length = current_length + 1
            new_last_char = word[-1]
            state = (new_last_char, new_length)
            
            if state not in visited:
                visited.add(state)
                queue.append(new_path)
    
    if not solutions:
        print("No valid sequences found.")
        return
    
    # Determine the minimal solution length
    min_length = min(len(sol) for sol in solutions)
    minimal_solutions = [sol for sol in solutions if len(sol) == min_length]
    
    print(f"Found {len(minimal_solutions)} solution(s) with {min_length} words:")
    for sol in minimal_solutions:
        print(' -> '.join(sol))

if __name__ == "__main__":
    main()
