
# simple script to show XOR's of different ranges of integers

checksum = 0

n = 200001
start = int(4*n + 3)
start = int(4*n + 0)
start = int(4*n + 1)
start = int(4*n + 2)
start = 254
# for i in range( start,start+8+1):
for i in range( 0, 10001):
    checksum ^= i
    print("{0:4d}: {0:10b}  {1:4d}: {1:10b}".format(i,checksum))

#for i in range(0,1000000000):
#    checksum ^= i
#   print("{0:4d}: {0:10b}  {1:4d}: {1:10b}".format(i,checksum))
#print checksum


# if line_length > 400
#   if start is odd
#     checksum = start
#     line_length -= 1
#   else
#     checksum = 0
#     start here
#   if line_length % 4 == 0:
#      done
#   if line_length % 4 == 1:
#      checksum ^= last_number
#   if line_length % 4 == 2:
#      checksum ^= 1
#   if line_length % 4 == 3:
#      checksum ^= last_number
#      checksum ^= 1

#254:   11111110   254:   11111110
#255:   11111111     1:          1
#256:  100000000   257:  100000001
#257:  100000001     0:          0 <- line_length = 257 - 254 + 1 = 4   % 4 = 0
#258:  100000010   258:  100000010 <- line_length = 258 - 254 + 1 = 4   % 4 = 1
#259:  100000011     1:          1 <- line_length = 259 - 254 + 1 = 6   % 4 = 2
#260:  100000100   261:  100000101 <- line_length = 260 - 254 + 1 = 7   % 4 = 3
#261:  100000101     0:          0 <- line_length = 261 - 254 + 1 = 8   % 4 = 0
#262:  100000110   262:  100000110
