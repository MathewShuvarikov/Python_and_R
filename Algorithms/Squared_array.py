
x = [-5, -4, 0, 1,2,5]

def solutiion(array: list[int]) -> list[int]:
    array = [num**2 for num in array]
    array.sort()
    return array

print(solutiion(x))

