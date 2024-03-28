import base64

def is_valid_base64_string(input_string):
  try:
    # Check if the string is of length 20
    if len(input_string) != 20:
      return False
    # Try decoding the base64 string with strict validation
    base64.b64decode(input_string, validate=True)
    return True
  except (TypeError, base64.binascii.Error):
    # Return False if there's an error during decoding
    return False

# Example usage
test_string = "This is a test string"
if is_valid_base64_string(test_string):
  print("The string is valid base64 encoded")
else:
  print("The string is not valid base64 encoded")
