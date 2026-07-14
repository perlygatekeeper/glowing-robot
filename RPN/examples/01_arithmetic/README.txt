01 Arithmetic
=============

These examples build familiar arithmetic operations from smaller RPN
primitives. They are intentionally educational: when an equivalent built-in
command exists, the built-in is normally the better choice for everyday use.

Recipes
-------

* Factorial with Reduce
  Builds n! from range, exchange, reduce, and an executable multiplication.

* Greatest Common Divisor
  Implements Euclid's algorithm with while, modulo, and two helper functions.

* Least Common Multiple
  Demonstrates the identity (a * b) / gcd(a,b) and careful stack cleanup.

* Integer Power
  Uses repeat and a multiplication helper to raise a base to a non-negative
  integer exponent.

* Running Product
  Reduces all current stack values with multiplication.

* Running Sum
  Reduces all current stack values with addition.

* Clamp a Value
  Composes min2 and max2 to restrict a value to inclusive bounds.

* Minimum/Maximum of Two Values
  Uses stack manipulation and conditional executable values to select from
  only the top two stack values.

Suggested order
---------------

1. minmax_two_values.txt
2. clamp_value.txt
3. running_sum.txt
4. running_product.txt
5. factorial_with_reduce.txt
6. integer_power.txt
7. gcd_euclid.txt
8. least_common_multiple.txt
