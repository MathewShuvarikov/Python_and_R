## return squares of numbers from sorted array, ascending way
x = [-5, -4, 0, 1,2,5]

def solutiion(array: list[int]) -> list[int]:
    array = [num**2 for num in array]
    array.sort()
    return array

print(solutiion(x))

## return unique squares of numbers from sorted array,ascending way
def solutiion2(array: list[int]) -> list[int]:
    array = [num**2 for num in array]
    array.sort()
    return list(set(array))

print(solutiion2(x))

