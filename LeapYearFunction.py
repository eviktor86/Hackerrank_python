'''
Title     : Leap year Function
Subdomain : Introduction
Domain    : Python
Author    : Viktor Török
Created   : 17 02 2017
'''
# Enter your code here. Read input from STDIN. Print output to STDOUT
def is_leap(year):
    if (year % 400):
        leap = False
        if (year % 4):
            leap = False
        else:
            leap = True
            if (year % 100):
                leap = True
            else:
                leap = False
    else:
        leap = True
    return leap
year = int(raw_input())
print is_leap(year)