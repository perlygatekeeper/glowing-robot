#!/opt/local/bin/python
# Python program to find largest common multiple
  
import sys 
import math 
import timeit
import time

start_time = timeit.default_timer()
year  =  1900
month =     0
weekday =   1 # Jan 1990 is a Monday
sunday_months = 0
#  0 - Sunday
#  1 - Monday
#  2 - Tuesday
#  3 - Wednesday
#  4 - Thursday
#  5 - Friday
#  6 - Saturday
month_abbrevs = []
month_abbrevs.append('Jan')
month_abbrevs.append('Feb')
month_abbrevs.append('Mar')
month_abbrevs.append('Apr')
month_abbrevs.append('May')
month_abbrevs.append('Jun')
month_abbrevs.append('Jul')
month_abbrevs.append('Aug')
month_abbrevs.append('Sep')
month_abbrevs.append('Oct')
month_abbrevs.append('Nov')
month_abbrevs.append('Dec')

month_lengths = []
month_lengths.append(31)   #  0 - January
month_lengths.append(28)   #  1 - February (leap year)
month_lengths.append(31)   #  2 - March
month_lengths.append(30)   #  3 - April
month_lengths.append(31)   #  4 - May
month_lengths.append(30)   #  5 - June
month_lengths.append(31)   #  6 - July
month_lengths.append(31)   #  7 - August
month_lengths.append(30)   #  8 - Septemer
month_lengths.append(31)   #  9 - October
month_lengths.append(30)   # 10 - November
month_lengths.append(31)   # 11 - December

sunday_months = 0
not_done = True
while not_done:
# for step in range(12*101):
    if month == 11 and year == 1900:
        sunday_months = 0
#   print ("Year: %4d - Month: %2d - Sunday Months: %4d" % ( year, month, sunday_months ) )
    weekday += month_lengths[month]
    if month == 1:  # February  - leap year logic
        if ( year %    4 ) == 0 and ( year %  100 ) != 0: # leap year
#          ( year %  400 ) == 0 and ( year % 1000 ) != 0 
            weekday += 1
    weekday %= 7
    if weekday == 0:
        sunday_months += 1
    if month == 11: # Decemeber - year's end
        year += 1
    month += 1
    month %= 12
    print ("cal %s %4d - Sunday Months: %4d" % ( month_abbrevs[month], year, sunday_months ) )
    if year == 2000 and month == 11:
        not_done = False

print ("Months starting on Sunday in 20th century is %d" % ( sunday_months ) )
print( timeit.default_timer() - start_time )
