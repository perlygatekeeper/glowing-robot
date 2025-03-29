import json

# Example data
data = [{"title": "Example Title", "description": "Example Description"}]

# Write to JSON
with open("output.json", "w", encoding="utf-8") as file:
    json.dump(data, file, indent=4)
