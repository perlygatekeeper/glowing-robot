package Math::Prime::ExponentialForm;
use strict;
use warnings;
use Moose;
use Moose::Util::TypeConstraints;
use Data::Dumper;
use Carp;
use Big::Int;
# use Math::Prime::Factorization; ???

# ABSTRACT: a really awesome library

=head1 SYNOPSIS

Primes up to 700 stored in a 128-length array
others are stored as a seperate array of hashes,
each 'prime_factory' => 'exponent'

or for Nth prime: '#N' => 'exponent'

methods needed:

PFEN => number
number => PFEN
pfen_asjson   = for storage into database

gcd           = Greatest Common Divisor (Intersection)
lcm           = Lowest Common Multiple (Superset)
mult          = Multiplication (Vector Addition)
div           = Multiplication (Vector Subtraction)
exp           = Exponentation (Vector Multiplication)
root          = Exponentation (Vector Division)
is_root       = are all numbers in vector multiple of power of the root, sqrt => are all exponents even
is_prime      = single point vector
are_coprime   = ( number, number)
prime_factors = list each prime and exponent
pmc           = prime_factor_count (number of non-zero values in vector)
num_factors   = number of factors
factors       = list all factors

prime_factoral = a vector of all ones, followed by all zeros
  ...

=method method_x

This method does something experimental.

=method method_y

This method returns a reason.

=head1 SEE ALSO

=for :list
* L<Your::Module>
* L<Your::Package>
=cut

has small_primes ( is = 'Array[Int]',  required => 0 );
has sursolids    ( is = 'Array[Hash]', required => 0 );

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
