import random

buffer = bytearray(0)
for i in range(2399) :
    buffer.append(random.randint(0,255))

for i in range(24) :
    output_file = open(f"filesize_mod24={i:02d}", 'wb')
    buffer.append(random.randint(0,255))
    output_file.write(buffer)
    output_file.close()
