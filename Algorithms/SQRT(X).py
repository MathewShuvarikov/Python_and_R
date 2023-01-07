# find the square root of a number (integer part) without using degrees

x = int(input())

rez = 1
t = 0
for i in range(1, x**2):
    rez = i*i
    if rez == x:
        t = i
        break
    elif rez > x:
        t = i-1
        break
print(t)
