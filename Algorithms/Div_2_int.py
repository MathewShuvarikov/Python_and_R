# поделить нацело одно число на другое, не используя деление, умножение и т.д.
# ищем только целую часть числа

dividend = int(input())
divisor = int(input())

t = 0
flag = 0
rez = 0

for i in range(1, dividend + 2):
    rez += abs(divisor)
    if rez == dividend:
        t = i
        flag = 1
        break
    elif rez > dividend:
        t = i - 1
        flag = 1
        break
    if flag:
        break
if divisor < 0:
    t = -t
print(t)
