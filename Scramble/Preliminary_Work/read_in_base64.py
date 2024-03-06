import base64

def decode_and_yield_blocks(data):
  """
  Reads 32 bytes, base64 decodes them, and yields back 3 sets of 8-byte blocks.

  Args:
      data: A bytes object containing 32 bytes of data.

  Yields:
      Three bytes objects, each containing 8 bytes of the decoded data.
  """

  if len(data) != 32:
    raise ValueError("Input data must be 32 bytes long.")

  decoded_data = base64.b64decode(data)

  for i in range(0, 24, 8):
    yield decoded_data[i:i+8]

# Example usage
data = b"VGhpcyBpcyBhIHNhbXBsZSB0ZXN0Lg=="  # Base64 encoded string representing 32 bytes
for block in decode_and_yield_blocks(data):
  print(block.hex())

data = b"AQIDBAUGBwgJCgsMDQ4PEBESExQVFhcY"
for block in decode_and_yield_blocks(data):
  print(block.hex())
