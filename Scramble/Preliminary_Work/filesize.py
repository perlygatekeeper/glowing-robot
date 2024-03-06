#!/opt/local/bin/python
import os

def get_file_size(filename):
    try:
        file_size = os.path.getsize(filename)
        return file_size
    except OSError as e:
        print(f"Error getting file size: {e}")
        return None

# -rw-r--r--   1 perlygatekeeper  staff    830 Feb  5 22:21 Sample_file.txt

# Example usage:

filename = "Sample_file.txt"  # Replace with the actual filename
filename = "ByteTransformer.py"  # Replace with the actual filename
file_size = get_file_size(filename)

if file_size is not None:
    last = file_size % 8
    print(f"The size of {filename} is {file_size} bytes.")
    print(f"Last block will be {last} bytes.")
else:
    print("Could not determine file size.")

