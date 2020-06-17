#!/opt/local/bin/python
# Python program to find the product of the one pythagreon triplet whose sum is 1000.
  
import timeit
import time

start_time = timeit.default_timer()

found_it = False
for a in range(1,334):
  if found_it:
     break
  for b in range((a+1),int((1000 - a)/2 + 1)):
      c = 1000 - a -b
      if ( a*a + b*b ) == c*c:
          product = a*b*c
          found_it = True
          break


print ("Found pythagorean triplet (%d, %d, %d) with a product of %d with a + b + c = 1000" % ( a, b, c, product) )
print( timeit.default_timer() - start_time )
