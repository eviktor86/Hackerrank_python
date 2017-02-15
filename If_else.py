'''
Title     : If-else
Subdomain : Introduction
Domain    : Python
Author    : Viktor Török
Created   : 15 02 2017
'''
# Enter your code here. Read input from STDIN. Print output to STDOUT
if __name__ == '__main__':
    n = int(raw_input())
if (n in range (6, 21) or n % 2 != 0):
    print("Weird")
else:
    print("Not Weird")