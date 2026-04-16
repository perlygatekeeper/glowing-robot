#!/usr/bin/perl

my $VERSION = '0.3b';

$primes_found=0;
$truth = 1;

if ($ARGV[1] == 0)
{
print "Enter the number of prime numbers to find: ";
$primes_to_find=<STDIN>;chomp $primes_to_find;
}
else {$primes_to_find=$ARGV[1];}

if ($ARGV[0] == 0)
{
print "Enter the first number to test: ";
$prime_candidate = <STDIN>;chomp $prime_candidate;
}
else {$prime_candidate = $ARGV[0];}
 
while ($primes_to_find > $primes_found)
{
PRIMETEST:
	for ($count1=1;$count1 <= $prime_candidate / 2;$count1++)
	{
		for ($count2=1;$count2 <= $prime_candidate /2;$count2++)
		{
			if ($count1 * $count2 == $prime_candidate)
			{
			$truth = 0;
			last PRIMETEST;
			}
		}
	}

if ($truth == 1)
{
$primes_found++;
print "$prime_candidate is the $primes_found th prime found\n";
}
$truth = 1;
$prime_candidate++;
}


=head1 NAME

Prime Number 0.3b - Finds prime numbers over a given range of intergers

=head1 Author

Christopher Porter, console@ufl.edu

=head1 Copyright

Distributed under GNU License. May be freely used, copied, and modified for
educational purposes if credit is given to original author and the program
is not used for academic fraud.

=head1 PRERQUISITES

Support can only be guaranteed for Perl 5.0 and higher.

=pod OSNAMES

Linux

=pod SCRIPT CATEGORIES

Computer science, math