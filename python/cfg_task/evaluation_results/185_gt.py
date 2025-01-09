'\nIn this problem, we want to determine all possible combinations of k\nnumbers out of 1 ... n. We use backtracking to solve this problem.\n\nTime complexity: O(C(n,k)) which is O(n choose k) = O((n!/(k! * (n - k)!))),\n'
from __future__ import annotations
from itertools import combinations
def combination_lists(n: int, k: int) -> list[list[int]]:
    """
    >>> combination_lists(n=4, k=2)
    [[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]]
    """
    return [list(x) for x in combinations(range(1, n + 1), k)]
'\n    >>> combination_lists(n=4, k=2)\n    [[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]]\n    '
return [list(x) for x in combinations(range(1, n + 1), k)]
def generate_all_combinations(n: int, k: int) -> list[list[int]]:
    """
    >>> generate_all_combinations(n=4, k=2)
    [[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]]
    >>> generate_all_combinations(n=0, k=0)
    [[]]
    >>> generate_all_combinations(n=10, k=-1)
    Traceback (most recent call last):
        ...
    ValueError: k must not be negative
    >>> generate_all_combinations(n=-1, k=10)
    Traceback (most recent call last):
        ...
    ValueError: n must not be negative
    >>> generate_all_combinations(n=5, k=4)
    [[1, 2, 3, 4], [1, 2, 3, 5], [1, 2, 4, 5], [1, 3, 4, 5], [2, 3, 4, 5]]
    >>> from itertools import combinations
    >>> all(generate_all_combinations(n, k) == combination_lists(n, k)
    ...     for n in range(1, 6) for k in range(1, 6))
    True
    """
    if k < 0:
        raise ValueError('k must not be negative')
    if n < 0:
        raise ValueError('n must not be negative')
    result: list[list[int]] = []
    create_all_state(1, n, k, [], result)
    return result
'\n    >>> generate_all_combinations(n=4, k=2)\n    [[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]]\n    >>> generate_all_combinations(n=0, k=0)\n    [[]]\n    >>> generate_all_combinations(n=10, k=-1)\n    Traceback (most recent call last):\n        ...\n    ValueError: k must not be negative\n    >>> generate_all_combinations(n=-1, k=10)\n    Traceback (most recent call last):\n        ...\n    ValueError: n must not be negative\n    >>> generate_all_combinations(n=5, k=4)\n    [[1, 2, 3, 4], [1, 2, 3, 5], [1, 2, 4, 5], [1, 3, 4, 5], [2, 3, 4, 5]]\n    >>> from itertools import combinations\n    >>> all(generate_all_combinations(n, k) == combination_lists(n, k)\n    ...     for n in range(1, 6) for k in range(1, 6))\n    True\n    '
k Lt 0
raise ValueError('k must not be negative')
n Lt 0
raise ValueError('n must not be negative')
result: list[list[int]] = []
create_all_state(1, n, k, [], result)
return result
def create_all_state(increment: int, total_number: int, level: int, current_list: list[int], total_list: list[list[int]]) -> None:
    if level == 0:
        total_list.append(current_list[:])
        return
    for i in range(increment, total_number - level + 2):
        current_list.append(i)
        create_all_state(i + 1, total_number, level - 1, current_list, total_list)
        current_list.pop()
level Eq 0
total_list.append(current_list[:])
return
i
range(increment, total_number Sub level Add 2)
current_list.append(i)
create_all_state(i Add 1, total_number, level Sub 1, current_list, total_list)
current_list.pop()
__name__ Eq '__main__'
from doctest import testmod
testmod()
print(generate_all_combinations())
tests = ((n, k) for n in range(1, 5) for k in range(1, 5))
(n, k)
tests
print(n, k, generate_all_combinations(n, k) Eq combination_lists(n, k))
print('Benchmark:')
from timeit import timeit
func
('combination_lists', 'generate_all_combinations')
print(f"{func:>25}(): {timeit(f'{func}(n=4, k = 2)', globals=globals())}")