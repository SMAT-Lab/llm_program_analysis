'\nIn this problem, we want to determine all possible subsequences\nof the given sequence. We use backtracking to solve this problem.\n\nTime complexity: O(2^n),\nwhere n denotes the length of the given sequence.\n'
from __future__ import annotations
from typing import Any
def generate_all_subsequences(sequence: list[Any]) -> None:
    create_state_space_tree(sequence, [], 0)
create_state_space_tree(sequence, [], 0)
def create_state_space_tree(sequence: list[Any], current_subsequence: list[Any], index: int) -> None:
    """
    Creates a state space tree to iterate through each branch using DFS.
    We know that each state has exactly two children.
    It terminates when it reaches the end of the given sequence.

    :param sequence: The input sequence for which subsequences are generated.
    :param current_subsequence: The current subsequence being built.
    :param index: The current index in the sequence.

    Example:
    >>> sequence = [3, 2, 1]
    >>> current_subsequence = []
    >>> create_state_space_tree(sequence, current_subsequence, 0)
    []
    [1]
    [2]
    [2, 1]
    [3]
    [3, 1]
    [3, 2]
    [3, 2, 1]

    >>> sequence = ["A", "B"]
    >>> current_subsequence = []
    >>> create_state_space_tree(sequence, current_subsequence, 0)
    []
    ['B']
    ['A']
    ['A', 'B']

    >>> sequence = []
    >>> current_subsequence = []
    >>> create_state_space_tree(sequence, current_subsequence, 0)
    []

    >>> sequence = [1, 2, 3, 4]
    >>> current_subsequence = []
    >>> create_state_space_tree(sequence, current_subsequence, 0)
    []
    [4]
    [3]
    [3, 4]
    [2]
    [2, 4]
    [2, 3]
    [2, 3, 4]
    [1]
    [1, 4]
    [1, 3]
    [1, 3, 4]
    [1, 2]
    [1, 2, 4]
    [1, 2, 3]
    [1, 2, 3, 4]
    """
    if index == len(sequence):
        print(current_subsequence)
        return
    create_state_space_tree(sequence, current_subsequence, index + 1)
    current_subsequence.append(sequence[index])
    create_state_space_tree(sequence, current_subsequence, index + 1)
    current_subsequence.pop()
'\n    Creates a state space tree to iterate through each branch using DFS.\n    We know that each state has exactly two children.\n    It terminates when it reaches the end of the given sequence.\n\n    :param sequence: The input sequence for which subsequences are generated.\n    :param current_subsequence: The current subsequence being built.\n    :param index: The current index in the sequence.\n\n    Example:\n    >>> sequence = [3, 2, 1]\n    >>> current_subsequence = []\n    >>> create_state_space_tree(sequence, current_subsequence, 0)\n    []\n    [1]\n    [2]\n    [2, 1]\n    [3]\n    [3, 1]\n    [3, 2]\n    [3, 2, 1]\n\n    >>> sequence = ["A", "B"]\n    >>> current_subsequence = []\n    >>> create_state_space_tree(sequence, current_subsequence, 0)\n    []\n    [\'B\']\n    [\'A\']\n    [\'A\', \'B\']\n\n    >>> sequence = []\n    >>> current_subsequence = []\n    >>> create_state_space_tree(sequence, current_subsequence, 0)\n    []\n\n    >>> sequence = [1, 2, 3, 4]\n    >>> current_subsequence = []\n    >>> create_state_space_tree(sequence, current_subsequence, 0)\n    []\n    [4]\n    [3]\n    [3, 4]\n    [2]\n    [2, 4]\n    [2, 3]\n    [2, 3, 4]\n    [1]\n    [1, 4]\n    [1, 3]\n    [1, 3, 4]\n    [1, 2]\n    [1, 2, 4]\n    [1, 2, 3]\n    [1, 2, 3, 4]\n    '
index Eq len(sequence)
print(current_subsequence)
return
seq: list[Any] = [1, 2, 3]
generate_all_subsequences(seq)
seq.clear()
seq.extend(['A', 'B', 'C'])
generate_all_subsequences(seq)