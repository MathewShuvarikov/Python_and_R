## return max number from moving window of length k

x = [6,2,3,7,0,1,2]
k = 3
def solution(x, k):
    ar1 = []
    for i in range(len(x)):
        if k+i < len(x):
            ar1.append(max(x[i:(i+k)]))
        else:
            break
    return ar1

print(solution(x, k))

