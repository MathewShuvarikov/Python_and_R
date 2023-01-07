# to determine if a number is a palindrome

s = str(input())
rez = 1
for i in range(0, int(len(s)/2)):
    if s[i]==s[-i-1]:
        rez *= 1
    else:
        rez *= 0
    print(rez)
print(bool(rez))

