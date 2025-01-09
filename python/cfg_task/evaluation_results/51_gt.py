'\nIn the Combination Sum problem, we are given a list consisting of distinct integers.\nWe need to find all the combinations whose sum equals to target given.\nWe can use an element more than one.\n\nTime complexity(Average Case): O(n!)\n\nConstraints:\n1 <= candidates.length <= 30\n2 <= candidates[i] <= 40\nAll elements of candidates are distinct.\n1 <= target <= 40\n'
def backtrack(candidates: list, path: list, answer: list, target: int, previous_index: int) -> None:
    """
    A recursive function that searches for possible combinations. Backtracks in case
    of a bigger current combination value than the target value.

    Parameters
    ----------
    previous_index: Last index from the previous search
    target: The value we need to obtain by summing our integers in the path list.
    answer: A list of possible combinations
    path: Current combination
    candidates: A list of integers we can use.
    """
    if target == 0:
        answer.append(path.copy())
    else:
        for index in range(previous_index, len(candidates)):
            if target >= candidates[index]:
                path.append(candidates[index])
                backtrack(candidates, path, answer, target - candidates[index], index)
                path.pop(len(path) - 1)
'\n    A recursive function that searches for possible combinations. Backtracks in case\n    of a bigger current combination value than the target value.\n\n    Parameters\n    ----------\n    previous_index: Last index from the previous search\n    target: The value we need to obtain by summing our integers in the path list.\n    answer: A list of possible combinations\n    path: Current combination\n    candidates: A list of integers we can use.\n    '
target Eq 0
answer.append(path.copy())
def combination_sum(candidates: list, target: int) -> list:
    """
    >>> combination_sum([2, 3, 5], 8)
    [[2, 2, 2, 2], [2, 3, 3], [3, 5]]
    >>> combination_sum([2, 3, 6, 7], 7)
    [[2, 2, 3], [7]]
    >>> combination_sum([-8, 2.3, 0], 1)
    Traceback (most recent call last):
        ...
    RecursionError: maximum recursion depth exceeded
    """
    path = []
    answer = []
    backtrack(candidates, path, answer, target, 0)
    return answer
'\n    >>> combination_sum([2, 3, 5], 8)\n    [[2, 2, 2, 2], [2, 3, 3], [3, 5]]\n    >>> combination_sum([2, 3, 6, 7], 7)\n    [[2, 2, 3], [7]]\n    >>> combination_sum([-8, 2.3, 0], 1)\n    Traceback (most recent call last):\n        ...\n    RecursionError: maximum recursion depth exceeded\n    '
path = []
answer = []
backtrack(candidates, path, answer, target, 0)
return answer
index
range(previous_index, len(candidates))
target GtE candidates[index]
path.append(candidates[index])
backtrack(candidates, path, answer, target Sub candidates[index], index)
path.pop(len(path) Sub 1)
def main() -> None:
    print(combination_sum([-8, 2.3, 0], 1))
print(combination_sum([-8, 2.3, 0], 1))
__name__ Eq '__main__'
import doctest
doctest.testmod()
main()