import base64

# Define the block of 8 bytes
# data = b"\x01\x02\x03\x04\x05\x06\x07\x08"

# Encode the data using base64
# encoded_data = base64.b64encode(data)

# Calculate the number of characters in the encoded data
# num_chars = len(encoded_data.decode())

# Print the number of characters
# print(f"Number of characters after base64 encoding {encoded_data}: {num_chars}")

print(f" <   8 bits    > <    8 bits   > <    8 bits   >")
print(f"               1               2               3")
print(f" 0 1 2 3 4 5 6 7 0 1 2 3 4 5 6 7 0 1 2 3 4 5 6 7")
print(f" 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5")
print(f"           1           2           3           4")
print(f" <  6 bits > <  6 bits > <  6 bits > <  6 bits >")

data = b"\x01"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")
