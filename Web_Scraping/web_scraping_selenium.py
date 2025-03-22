from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
import time

# Step 1: Set up Selenium WebDriver
chrome_options = Options()
chrome_options.add_argument("--headless")  # Run in headless mode (no browser window)
service = Service("path/to/chromedriver")  # Replace with the path to your ChromeDriver
driver = webdriver.Chrome(service=service, options=chrome_options)

# Step 2: Navigate to the webpage
url = "https://twitter.com/search?q=python&src=typed_query"
driver.get(url)

# Step 3: Wait for the page to load
time.sleep(5)  # Adjust the sleep time as needed

# Step 4: Extract tweet text
tweets = driver.find_elements(By.CSS_SELECTOR, 'div[data-testid="tweetText"]')

# Step 5: Print the results
print("Tweets:")
for idx, tweet in enumerate(tweets, start=1):
    print(f"{idx}. {tweet.text}")

# Step 6: Close the browser
driver.quit()
