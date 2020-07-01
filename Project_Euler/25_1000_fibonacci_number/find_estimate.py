#!/opt/local/bin/python
# Program to find the first fibin number with 1000 digits

import timeit
import time
import sys
import math

# Fn   =   ( phi^n - psi^n ) / ( phi - psi )  =  ( phi^n - psi^n ) / sqrt(5)
# where
# phi  =  ( 1 + sqrt(5) ) / 2                             approx 1.61803 39887 ...
# is the golden ratio (OEIS: A001622), and
# psi  =  ( 1 - sqrt(5) ) / 2  =   1 - phi =  -1 / phi    approx -0.61803 39887 ...

r5 = pow(5,0.5)
print(r5)
print(math.log(r5,10))
print(math.log(r5*10,10))
print(math.log(r5*100,10))
print(math.log(r5*1000,10))

phi = ( 1 + r5 ) / 2
psi = 1 - phi
print(phi)
print(math.log(phi,10))

n = 400
Fn = ( pow(phi,n) - pow(psi,n) ) / ( phi - psi ) 
print(Fn)


n = 1000
Fn = ( pow(phi,n) - pow(psi,n) ) / ( phi - psi ) 
print(Fn)

n = 1400
Fn = ( pow(phi,n) - pow(psi,n) ) / ( phi - psi ) 
print(Fn)

print(sys.float_info)
print(sys.int_info)

# As the floor function is monotonic, the latter formula can be inverted for finding the index n(F)
# of the largest Fibonacci number that is not greater than a real number F > 1:

#   n(F)=  [log_phi (F sqrt(5) + 1/2 ) ] ,
#   where log_phi(x) = ln(x)/ln(phi) = log_10(x)/log_10(phi).

# here we set F = 10^1000
# 
# n(10^1000) = log_phi( r5 * 10^1000 + 1/2 )
#            = log_10( r5 * 10^1000 + 1/2 ) / log_10(phi)

n = (1000.0 + math.log(r5,10) + 0.5) / math.log(phi,10)

print(n)



# Magnitude
# Since Fn is asymptotic to phi^n/sqrt(5), the number of digits in Fn is asymptotic to  n log_10(phi) =~ 0.2090 n.
# As a consequence, for every integer d > 1 there are either 4 or 5 Fibonacci numbers with d decimal digits.


print(1000/math.log(phi,10))
print(math.log(phi,10))


digits = 1000

n = math.ceil((digits-1 + math.log(r5,10)) / math.log(phi,10));
print(n)





















