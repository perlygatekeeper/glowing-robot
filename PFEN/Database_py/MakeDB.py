# import requests
# from bs4 import BeautifulSoup
import sqlite3

# response = requests.get("https://example.com/products")
# soup = BeautifulSoup(response.text, "html.parser")

conn = sqlite3.connect("PrimeFactorExpontialForm.db")
cursor = conn.cursor()
cursor.execute("CREATE TABLE IF NOT EXISTS Primes       (name TEXT, price REAL)")
cursor.execute("CREATE TABLE IF NOT EXISTS Numbers      (name TEXT, price REAL)")
cursor.execute("CREATE TABLE IF NOT EXISTS PrimeFactors (name TEXT, price REAL)")

products = soup.find_all("div", class_="product")
for product in products:
    name = product.find("h2").text
    price = float(product.find("span", class_="price").text.strip("$").replace(",", ""))
    cursor.execute("INSERT INTO products VALUES (?, ?)", (name, price))

conn.commit()
conn.close()

'''
--- SQLight 
CREATE TABLE Primes ( prime_id INTEGER PRIMARY KEY, prime_number INTEGER, prime_sequence INTEGER);
CREATE TABLE Numbers ( number_id INTEGER PRIMARY KEY, number_value INTEGER);
CREATE TABLE PrimeFactors ( prime_id INTEGER, number_id INTEGER, PRIMARY KEY (prime_id, number_id), FOREIGN KEY (prime_id) REFERENCES Primes(prime_id), FOREIGN KEY (number_id) REFERENCES Numbers(number_id));

--- MySQL 
'''

