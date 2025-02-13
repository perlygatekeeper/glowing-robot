from db_module import get_number_db

def populate_numbers(start, end):
    numbers_db = get_number_db()
    batch_size = 1000  # Insert in batches to optimize performance
    
    for i in range(start, end + 1):
        numbers_db.insert_number(i, 0, 0)
        
        if i % batch_size == 0:
            print(f"Inserted up to: {i}")
    
    print("Population complete!")

if __name__ == "__main__":
    populate_numbers(100000, 10000000)
