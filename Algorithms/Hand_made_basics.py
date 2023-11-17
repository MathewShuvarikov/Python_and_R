## SUM
def SUM(array: list[int]) -> int:
    summa = 0
    for i in array:
        summa+=i
    return summa
print(SUM([0,-1,2,5,7,8]))

## MEAN
def MEAN(array: list[int]) -> float:
    summa = 0
    n = 0
    for i in array:
        summa+=i
        n += 1
    return (summa/n)

print(MEAN([0,-1,2,5,7,8]))

## Variance
def VAR(array: list[int]) -> float:
    mean = MEAN(array)
    sumsq = 0
    n = 0
    for i in array:
        sumsq += (i-mean)**2
        n += 1
    return sumsq/(n-1)
print(VAR([0,-1,2,5,7,8]))

## Standard deviation
def SD(array: list[int]) -> float:
    return VAR(array)**0.5
print(SD([0,-1,2,5,7,8]))

## Median
def MED(array: list[int]) -> float:
    array.sort()
    if len(array)%2==1:
        numelem = (len(array)-1)/2
        med1 = array[int(numelem)]
    else:
        numelem = len(array) / 2
        med1 = (array[int(numelem) - 1]+array[int(numelem)])/2
    return med1

print(MED([0,-1,2, -2, 3, 1, 1, 5,6,7,9]))
print(MED([0,-1,2, -2, 3, 1, 1, 5,6,7]))


