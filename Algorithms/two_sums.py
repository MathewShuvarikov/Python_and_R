
nums = [2,7,11,15]
target = 9
class Solution:
    def twoSum(self, nums: list[int], target: int) -> list[int]:
        n = len(nums)
        for i in range(n - 1):
            for j in range(i + 1, n):
                if nums[i] + nums[j] == target:
                    return [i, j]
        return []  # No solution found

class1 = Solution()
print(class1.twoSum(nums, target))
s = "(())"
print(list(s))


