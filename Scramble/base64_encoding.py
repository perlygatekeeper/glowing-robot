import base64

# Encoding:
#     base64.b64encode(data): Converts binary data (bytes) into a Base64-encoded ASCII string.

encoded_data = base64.b64encode(b'Hello, world!')
print(encoded_data)  # Output: b'SGVsbG8sIHdvcmxkIQ=='

# Decoding:
#     base64.b64decode(data): Decodes a Base64-encoded string back into binary data (bytes).

decoded_data = base64.b64decode(b'SGVsbG8sIHdvcmxkIQ==')
print(decoded_data.decode())  # Output: Hello, world!
