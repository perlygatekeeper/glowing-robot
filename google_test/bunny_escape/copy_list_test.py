def change_b(b):
    b[2]="^"

a = [ 0, 1, 2, 3, 4 ]
b = a[:]

print("---------------------------")
print("a:",a)
print("b:",b)

print("---------------------------")
print("setting a[0] to 'X'")
a[0] = 'X'
print("a:",a)
print("b:",b)

print("---------------------------")
print("setting b[-1] to '*'")
b[-1] = '*'
print("a:",a)
print("b:",b)

print("---------------------------")
print("calling change_b(b)")
change_b(b)
print("a:",a)
print("b:",b)
