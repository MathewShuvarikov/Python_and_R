# task: given a set of n points in a two-dimensional space (a list of n turtles of size 2)
# it is necessary to check whether there is a vertical axis of symmetry for the set of these points

t1 = (1, 3)
t2 = (3, 5)
t5 = (4, 1)
t3 = (5, 5)
t4 = (7, 3)
t6 = (5, 2)

l = [t1, t3, t2, t4, t5, t6]
l.sort()

d = abs(l[0][0] - l[-1][0])/2 + l[0][0]
rez = 1
for i in range(0, len(l)):
    if abs(l[i][0]-d)==abs(l[-i-1][0]-d):
        rez *= 1
    else:
        rez*=0
for i in range(0, len(l)):
    if l[i][1] == l[-i-1][1]:
        rez *= 1
    else:
        rez *= 0
print(rez)