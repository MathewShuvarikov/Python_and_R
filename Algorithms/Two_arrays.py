
list1 = [1,2,4]
list2 = [1,3,4]

list1.extend(list2)
list1.sort()


class Solution:
    def mergeTwoLists(self, list1: Optional[ListNode], list2: Optional[ListNode]) -> Optional[ListNode]:
        list1.extend(list2)

        return list1.sort()