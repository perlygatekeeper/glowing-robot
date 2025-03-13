import re

letters = 'abcdefghijkl'
print(letters)

# Corrected regex patterns using f-strings and proper variable naming
patterns = [
    fr"[{letters[:3]}][{letters[3:]}]",        # [abc][defghijkl]
    fr"[{letters[3:6]}][{letters[:3]}{letters[6:]}]",  # [def][abcghijkl]
    fr"[{letters[6:9]}][{letters[:6]}{letters[9:]}]",  # [ghi][abcdefjkl]
    fr"[{letters[9:]}][{letters[:9]}]"         # [jkl][abcdefghi]
]

print(patterns)

# Fixed variable name and regex compilation
regex_list = [re.compile(pattern) for pattern in patterns]
print(regex_list)

print(all(isinstance(r, re.Pattern) for r in regex_list))  # Output: True
