import requests
# from bs4 import BeautifulSoup

for lower_ord in ( range ( ord('a'),   ord('z') + 1 ) ):
    # Step 1: Define URL for the webpage
    lower_letter = chr(lower_ord)
    upper_letter = chr(lower_ord - 32)
    url = f"https://www.dndbeyond.com/sources/dnd/mm-2024/monsters-{lower_letter}#Monsters{upper_letter}"
    print(f"{url}")
    # print(f"{lower_letter} & {upper_letter}")

response = requests.get(url)
print(response)

exit(0)

example_monster_url = "https://www.dndbeyond.com/monsters/5195090-iron-golem"

# Check if the request was successful
if response.status_code != 200:
    print(f"Failed to retrieve the page. Status code: {response.status_code}")
    exit()

# Step 2: Parse the HTML content
soup = BeautifulSoup(response.content, 'lxml')

# Step 3: Extract specific elements
headlines = soup.find_all('h3')  # BBC News headlines are often in <h3> tags

# Step 4: Print the results
print("Headlines:")
for idx, headline in enumerate(headlines, start=1):
    print(f"{idx}. {headline.get_text(strip=True)}")
