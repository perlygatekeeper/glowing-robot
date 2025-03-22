import requests
from bs4 import BeautifulSoup

base_url = "https://example.com/page/"
all_data = []

# Scrape the first 3 pages
for page in range(1, 4):
    url = f"{base_url}{page}"
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'lxml')
    
    # Extract data (adjust selectors based on the website structure)
    items = soup.find_all('div', class_='item')
    for item in items:
        title = item.find('h2').get_text(strip=True)
        description = item.find('p').get_text(strip=True)
        all_data.append({"title": title, "description": description})

# Print the collected data
for entry in all_data:
    print(entry)
