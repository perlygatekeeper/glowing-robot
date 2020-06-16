#!/opt/local/bin/python

sum_3_5 = 0
for i in range(1,1000):
    if i % 3 == 0 or i % 5 == 0:
        print(i)
        sum_3_5 += i

print(sum_3_5)


