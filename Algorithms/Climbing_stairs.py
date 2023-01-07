# there is a ladder, you can go either 1 step or 2
# depending on the number of steps, what number of ways there are

n = int(input())

dp = [0] * (n+1)
dp[0], dp[1] = 1, 1
for i in range(2, n+1):
    dp[i] = dp[i-2] + dp[i-1]
print(dp[-1])

