#!/opt/local/bin/python
def bytearray_to_8x8_bits(bytearray):
 """Converts a bytearray of length 8 into an 8x8 grid of bits."""

 if len(bytearray) != 8:
   raise ValueError("Input bytearray must have length 8")

 bits = []
 for byte in bytearray:
     print(f"{byte:08b}")
 # bits.extend(f"{byte:08b}" for byte in bytearray)

 # row_strings = ["".join(bits[i:i+8]) for i in range(0, 64, 8)]
 # return "\n".join(row_strings)

# Example usage
byte_array = bytearray(b'\xAB\xCD\xEF\x12\x34\x56\x78\x90')
bytearray_to_8x8_bits(byte_array)
