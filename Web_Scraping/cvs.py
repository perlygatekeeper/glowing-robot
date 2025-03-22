import csv

# Example data
data = [{"title": "Example Title", "description": "Example Description"}]

# Write to CSV
with open("output.csv", "w", newline="", encoding="utf-8") as file:
    writer = csv.DictWriter(file, fieldnames=["title", "description"])
    writer.writeheader()
    writer.writerows(data)
