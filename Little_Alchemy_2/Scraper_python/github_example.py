import requests
from bs4 import BeautifulSoup

# Collect the github page
page = requests.get('https://github.com/trending')
#print(page)
#print('----')

# Create a BeautifulSoup object
soup = BeautifulSoup(page.text, 'html.parser')
#print(soup)
#print('----')

# get the repo list
repo = soup.find(class_="application-main")
repo = repo.find(class_="Box")
#print(repo)
#print('----')

# find all instances of that class (should return 25 as shown in the github main page)
repo_list = repo.find_all(class_='Box-row')

print(len(repo_list))
print('----')
