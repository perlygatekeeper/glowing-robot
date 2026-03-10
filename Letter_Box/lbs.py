import sys
from collections import deque, defaultdict
import re

def main():
    if len(sys.argv) != 2:
        print("Usage: letter_boxed.py <12_letters>")
        return
    letters = sys.argv[1].lower()
    if len(letters) != 12 or not re.fullmatch(r'[a-z]{12}', letters):
        print("Error: Exactly 12 unique letters are required.")
        return

    # Precompute letter indices for bitmask
    letter_indices = {letter: idx for idx, letter in enumerate(letters)}
    full_mask = (1 << 12) - 1  # All 12 bits set

    # Create regex patterns for valid adjacent pairs
    patterns = [
        fr"[{letters[:3]}][{letters[3:]}]",
        fr"[{letters[3:6]}][{letters[:3]}{letters[6:]}]",
        fr"[{letters[6:9]}][{letters[:6]}{letters[9:]}]",
        fr"[{letters[9:]}][{letters[:9]}]"
    ]
    compiled_patterns = [re.compile(p) for p in patterns]
    eliminator = re.compile(fr"[^{letters}]")

    # Load and filter dictionary
    web2_path = '/usr/share/dict/web2'
    try:
        with open(web2_path, 'r') as f:
            words = [word.strip().lower() for word in f if len(word.strip()) >= 3]
    except FileNotFoundError:
        print(f"Error: Dictionary file not found at {web2_path}.")
        return

    # Precompute word validity and masks
    valid_words = []
    word_masks = {}
    for word in words:
        if eliminator.search(word):
            continue
        if any(c1 == c2 for c1, c2 in zip(word, word[1:])):
            continue
        valid_pairs = True
        for i in range(len(word)-1):
            pair = word[i:i+2]
            if not any(p.fullmatch(pair) for p in compiled_patterns):
                valid_pairs = False
                break
        if valid_pairs:
            mask = 0
            for c in word:
                mask |= 1 << letter_indices[c]
            word_masks[word] = mask
            valid_words.append(word)

    if not valid_words:
        print("No valid words found.")
        return
    else:
        print(f"{len(valid_words)} valid words found.")
        print("\n".join(sorted(valid_words)))

    # Build start character map
    start_char_map = defaultdict(list)
    for word in valid_words:
        start_char_map[word[0]].append(word)

    # BFS with state tracking (last_char, used_mask, path_length)
    solutions = []
    visited = set()
    queue = deque()

    # Initialize queue with all valid starting words
    for word in valid_words:
        mask = word_masks[word]
        state = (word[-1], mask, 1)
        queue.append(([word], mask, word[-1]))
        visited.add(state)

    while queue:
        path, current_mask, last_char = queue.popleft()
        path_len = len(path)

        # Check if all letters are used and path length is within target
        if current_mask == full_mask and path_len <= 6:
            solutions.append(path)
            continue  # Continue searching for other possible solutions

        # Stop if path exceeds maximum length
        if path_len >= 6:
            continue

        # Explore next words
        for next_word in start_char_map.get(last_char, []):
            new_mask = current_mask | word_masks[next_word]
            new_state = (next_word[-1], new_mask, path_len + 1)
            if new_state not in visited:
                visited.add(new_state)
                new_path = path + [next_word]
                queue.append((new_path, new_mask, next_word[-1]))

    # Process solutions
    if not solutions:
        print("No valid solutions found.")
        return

    # Find minimal solutions
    solutions.sort(key=lambda x: len(x))
    min_length = len(solutions[0])
    minimal_solutions = [sol for sol in solutions if len(sol) <= ( min_length + 1 ) ]

    print(f"Found {len(minimal_solutions)} solution(s) with {min_length} or {min_length + 1} words:")
    for sol in minimal_solutions:
        print(' -> '.join(sol))

if __name__ == "__main__":
    main()
