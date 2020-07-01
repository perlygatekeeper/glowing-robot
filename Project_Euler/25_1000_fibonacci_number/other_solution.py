#!/opt/local/bin/python
# Program to find the first fibon number with 1000 digits

def fibo():
    a = 0
    b = 1
    while True:
        yield b
        a,b = b,a+b

# This gives a generator that computes the Fibonacci sequence. For example

f = fibo()
print([next(f) for i in range(10)])

# produces
# [1,1,2,3,5,8,13,21,34,55]
# Using this, we can solve the problem like so:

f = enumerate(fibo())
x = 0
while len(str(x)) < 1000:
    i,x = next(f)

print("The %d-th term has %d digits"%(i+1,len(str(x))))
