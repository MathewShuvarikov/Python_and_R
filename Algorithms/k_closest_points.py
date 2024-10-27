
points = [[1,3],[-2,2]]
k = 1
class Solution(object):
    def kClosest(self, points, k):
        """
        :type points: List[List[int]]
        :type k: int
        :rtype: List[List[int]]
        """
        d = {}
        for num, i in enumerate(points):
            distance = ((i[0])**2+(i[1])**2)**0.5
            d[num] = distance

        d = dict(sorted(d.items(), key=lambda item: item[1], reverse=False))
        print(d)
        d = list(d.keys())[:k]

        d = [points[i] for i in d]

        return d
class1 = Solution()
print(class1.kClosest(points, k))



