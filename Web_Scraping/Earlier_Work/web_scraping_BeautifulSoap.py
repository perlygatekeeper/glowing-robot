import requests
from bs4 import BeautifulSoup

# Step 1: Fetch the webpage
url = "https://www.bbc.com/news"
response = requests.get(url)

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
