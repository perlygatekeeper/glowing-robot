#!/opt/local/bin/python

sum_even_fibs = 2
f0 = 1
f1 = 2
for i in range(1,10000):
    f = f0 + f1
    if f >= 4000000:
        break
#   if f % 2 == 0:
    if f & 1 == 0:   # bit wise and 1 is faster
        sum_even_fibs += f
    f0 = f1
    f1 = f

print(sum_even_fibs)


