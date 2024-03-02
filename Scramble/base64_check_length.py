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
#        0_0_0_0_0_0_0_0 0_0_0_1_0_0_0_0 1_0_0_0_0_0_1_1
#          0     0     0   0     2     0   2     0     3   \000\020\203
#        0_0_0_1_0_0_0_0 0_1_0_1_0_0_0_1 1_1_0_0_1_0_0_0
#          0     2     0   1     2     1   3     1     0   \020\121\310
#        0_0_1_0_0_1_0_0 1_0_1_0_0_0_1_0 1_1_0_0_1_1_0_0
#          0     4     4   2     4     2   3     1     4   \044\242\314
#        0_0_1_1_0_1_0_0 1_1_1_0_0_0_1_1 1_1_0_1_0_0_0_0
#          0     6     4   3     4     3   3     2     0   \064\343\320
#        0_1_0_0_0_1_0_1 0_0_1_0_0_1_0_0 1_1_0_1_0_1_0_0
#          1     0     5   0     4     4   3     2     4   \105\044\324
#        0_1_0_1_0_1_0_1 0_1_1_0_0_1_0_1 1_1_0_1_1_0_0_0
#          1     4     5   1     4     5   3     3     0   \145\145\330
#        0_1_1_0_0_1_0_1 1_0_1_0_0_1_1_0 1_1_0_1_1_1_0_0
#          1     4     5   2     4     6   3     3     4   \145\246\334
#        0_1_1_1_0_1_0_1 1_1_1_0_0_1_1_1 1_1_1_0_0_0_0_0
#          1     6     5   3     4     7   3     4     0   \165\347\340


#        1_0_0_0_0_1_1_0 0_0_1_0_1_0_0_0 1_1_1_0_0_1_0_0
#          2     0     6   0     5     0   3     4     4   \206\050\344
#        1_0_0_1_0_1_1_0 0_1_1_1_1_0_1_0 0_0_1_0_1_0_0_1
#          2     2     6   1     7     2   0     5     1   \226\172\051
#        1_0_1_0_1_0_1_0 1_0_1_1_1_0_1_1 0_0_1_0_1_1_0_1
#          2     5     2   2     7     3   0     5     5   \252\273\055
#        1_0_1_1_1_0_1_0 1_1_1_1_1_1_0_0 0_0_1_1_0_0_0_1
#          2     7     2   3     7     4   0     6     1   \272\374\061
#        1_1_0_0_1_0_1_1 0_0_1_1_1_1_0_1 0_0_1_1_0_1_0_1
#          3     1     3   0     7     5   0     6     5   \313\075\065
#        1_1_0_1_1_0_1_1 0_1_1_1_1_1_1_0 0_0_1_1_1_0_0_1
#          3     3     3   1     7     6   0     7     1   \333\176\071
#        1_1_1_0_1_0_1_1 1_0_1_1_1_1_1_1 0_0_1_1_1_1_0_1
#          3     5     3   2     7     7   0     7     5   \353\277\075
#        1_1_1_1_1_0_1_1 1_1_1_1_1_0_0_0 0_0_0_0_0_0_0_0
#          3     7     3   3     7     0   0     0     0   \373\370\000



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
data = b"\000\020\203"
print(f"{data[0]:08b}{data[1]:08b}{data[2]:08b}")
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
data = b"\000\020\203\020\121\310"
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

data = b"\xFF\xFF\xFF\x1F\x00\x00\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

data = b"\000\020\203\020\121\310\044\242\314\064\343\320\105\044\324\145\145\330\145\246\334\165\347\340\206\050\344\226\172\051\252\273\055\272\374\061\313\075\065\333\176\071\353\277\075\373\370\000"
data= b"\000\020\203\020\121\207\040\222\213\060\323\217\101\024\223\121\125\227\141\226\233\161\327\237\202\030\243\222\131\247\242\232\253\262\333\257\303\034\263\323\135\267\343\236\273\363\337\277"
i = len(data)
encoded_data = base64.b64encode(data)
num_chars = len(encoded_data.decode())
print(f"Number of characters after base64 encoding {i:2d} -> {num_chars:2d}: {encoded_data}")

'''

0_0_0_0_0_0  0_0     0_0_0_1  0_0_0_0     1_0  0_0_0_0_1_1
  0     0      0       0      2     0       2      0     3
0_0_0_1_0_0  0_0     0_1_0_1  0_0_0_1     1_0  0_0_0_1_1_1
  0     2      0       1      2     1       2      0     7
0_0_1_0_0_0  0_0     1_0_0_1  0_0_1_0     1_0  0_0_1_0_1_1
  0     4      0       2      2     2       2      1     3
0_0_1_1_0_0  0_0     1_1_0_1  0_0_1_1     1_0  0_0_1_1_1_1
  0     6      0       3      2     3       2      1     7
0_1_0_0_0_0  0_1     0_0_0_1  0_1_0_0     1_0  0_1_0_0_1_1
  1     0      1       0      2     4       2      2     3
0_1_0_1_0_0  0_1     0_1_0_1  0_1_0_1     1_0  0_1_0_1_1_1
  1     2      1       1      2     5       2      2     7
0_1_1_0_0_0  0_1     1_0_0_1  0_1_1_0     1_0  0_1_1_0_1_1
  1     4      1       2      2     6       2      3     3
0_1_1_1_0_0  0_1     1_1_0_1  0_1_1_1     1_0  0_1_1_1_1_1
  1     6      1       3      2     7       2      3     7
1_0_0_0_0_0  1_0     0_0_0_1  1_0_0_0     1_0  1_0_0_0_1_1
  2     0      2       0      3     0       2      4     3
1_0_0_1_0_0  1_0     0_1_0_1  1_0_0_1     1_0  1_0_0_1_1_1
  2     2      2       1      3     1       2      4     7
1_0_1_0_0_0  1_0     1_0_0_1  1_0_1_0     1_0  1_0_1_0_1_1
  2     4      2       2      3     2       2      5     3
1_0_1_1_0_0  1_0     1_1_0_1  1_0_1_1     1_0  1_0_1_1_1_1
  2     6      2       3      3     3       2      5     7
1_1_0_0_0_0  1_1     0_0_0_1  1_1_0_0     1_0  1_1_0_0_1_1
  3     0      3       0      3     4       2      6     3
1_1_0_1_0_0  1_1     0_1_0_1  1_1_0_1     1_0  1_1_0_1_1_1
  3     2      3       1      3     5       2      6     7
1_1_1_0_0_0  1_1     1_0_0_1  1_1_1_0     1_0  1_1_1_0_1_1
  3     4      3       2      3     6       2      7     3
1_1_1_1_0_0  1_1     1_1_0_1  1_1_1_1     1_0  1_1_1_1_1_1
  3     6      3       3      3     7       2      7     7


data= b"\000\020\203\020\121\207\040\222\213\060\323\217\101\024\223\121\125\227\141\226\233\161\327\237\202\030\243\222\131\247\242\232\253\262\333\257\303\034\263\323\135\267\343\236\273\363\337\277"

'''
