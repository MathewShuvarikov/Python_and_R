import re

s = "A man, a plan, a canal: Panama"
def palindrom(s):
    s = s.lower()
    s = re.sub(r'[^а-яa-z\s]', '', s)
    s = s.replace(" ", "")
    print(s)
    rez = 1
    for i in range(0, int(len(s)/2)):
        if s[i]==s[-i-1]:
            rez *= 1
        else:
            rez *= 0
    return bool(rez)
print(palindrom(s))