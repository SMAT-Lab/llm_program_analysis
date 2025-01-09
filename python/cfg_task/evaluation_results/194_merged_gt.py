'\nIn this problem, we want to determine all possible permutations\nof the given sequence. We use backtracking to solve this problem.\n\nTime complexity: O(n! * n),\nwhere n denotes the length of the given sequence.\n'
from __future__ import annotations
def generate_all_permutations(sequence: list[int | str]) -> None:
    create_state_space_tree(sequence, [], 0, [0 for i in range(len(sequence))])
create_state_space_tree(sequence, [], 0, [0 for i in range(len(sequence))])
def create_state_space_tree(sequence: list[int | str], current_sequence: list[int | str], index: int, index_used: list[int]) -> None:
    """
    Creates a state space tree to iterate through each branch using DFS.
    We know that each state has exactly len(sequence) - index children.
    It terminates when it reaches the end of the given sequence.

    :param sequence: The input sequence for which permutations are generated.
    :param current_sequence: The current permutation being built.
    :param index: The current index in the sequence.
    :param index_used: list to track which elements are used in permutation.

    Example 1:
    >>> sequence = [1, 2, 3]
    >>> current_sequence = []
    >>> index_used = [False, False, False]
    >>> create_state_space_tree(sequence, current_sequence, 0, index_used)
    [1, 2, 3]
    [1, 3, 2]
    [2, 1, 3]
    [2, 3, 1]
    [3, 1, 2]
    [3, 2, 1]

    Example 2:
    >>> sequence = ["A", "B", "C"]
    >>> current_sequence = []
    >>> index_used = [False, False, False]
    >>> create_state_space_tree(sequence, current_sequence, 0, index_used)
    ['A', 'B', 'C']
    ['A', 'C', 'B']
    ['B', 'A', 'C']
    ['B', 'C', 'A']
    ['C', 'A', 'B']
    ['C', 'B', 'A']

    Example 3:
    >>> sequence = [1]
    >>> current_sequence = []
    >>> index_used = [False]
    >>> create_state_space_tree(sequence, current_sequence, 0, index_used)
    [1]
    """
    if index == len(sequence):
        print(current_sequence)
        return
    for i in range(len(sequence)):
        if not index_used[i]:
            current_sequence.append(sequence[i])
            index_used[i] = True
            create_state_space_tree(sequence, current_sequence, index + 1, index_used)
            current_sequence.pop()
            index_used[i] = False
'\n    Creates a state space tree to iterate through each branch using DFS.\n    We know that each state has exactly len(sequence) - index children.\n    It terminates when it reaches the end of the given sequence.\n\n    :param sequence: The input sequence for which permutations are generated.\n    :param current_sequence: The current permutation being built.\n    :param index: The current index in the sequence.\n    :param index_used: list to track which elements are used in permutation.\n\n    Example 1:\n    >>> sequence = [1, 2, 3]\n    >>> current_sequence = []\n    >>> index_used = [False, False, False]\n    >>> create_state_space_tree(sequence, current_sequence, 0, index_used)\n    [1, 2, 3]\n    [1, 3, 2]\n    [2, 1, 3]\n    [2, 3, 1]\n    [3, 1, 2]\n    [3, 2, 1]\n\n    Example 2:\n    >>> sequence = ["A", "B", "C"]\n    >>> current_sequence = []\n    >>> index_used = [False, False, False]\n    >>> create_state_space_tree(sequence, current_sequence, 0, index_used)\n    [\'A\', \'B\', \'C\']\n    [\'A\', \'C\', \'B\']\n    [\'B\', \'A\', \'C\']\n    [\'B\', \'C\', \'A\']\n    [\'C\', \'A\', \'B\']\n    [\'C\', \'B\', \'A\']\n\n    Example 3:\n    >>> sequence = [1]\n    >>> current_sequence = []\n    >>> index_used = [False]\n    >>> create_state_space_tree(sequence, current_sequence, 0, index_used)\n    [1]\n    '
index Eq len(sequence)
print(current_sequence)
return
i
range(len(sequence))
not index_used[i]
'\nremove the comment to take an input from the user\n\nprint("Enter the elements")\nsequence = list(map(int, input().split()))\n'
sequence: list[int | str] = [3, 1, 2, 4]
generate_all_permutations(sequence)
sequence_2: list[int | str] = ['A', 'B', 'C']
generate_all_permutations(sequence_2)
current_sequence.append(sequence[i])
index_used[i] = True
create_state_space_tree(sequence, current_sequence, index Add 1, index_used)
current_sequence.pop()
index_used[i] = False