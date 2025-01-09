'\nMinimax helps to achieve maximum score in a game by checking all possible moves\ndepth is current depth in game tree.\n\nnodeIndex is index of current node in scores[].\nif move is of maximizer return true else false\nleaves of game tree is stored in scores[]\nheight is maximum height of Game tree\n'
from __future__ import annotations
import math
def minimax(depth: int, node_index: int, is_max: bool, scores: list[int], height: float) -> int:
    """
    This function implements the minimax algorithm, which helps achieve the optimal
    score for a player in a two-player game by checking all possible moves.
    If the player is the maximizer, then the score is maximized.
    If the player is the minimizer, then the score is minimized.

    Parameters:
    - depth: Current depth in the game tree.
    - node_index: Index of the current node in the scores list.
    - is_max: A boolean indicating whether the current move
              is for the maximizer (True) or minimizer (False).
    - scores: A list containing the scores of the leaves of the game tree.
    - height: The maximum height of the game tree.

    Returns:
    - An integer representing the optimal score for the current player.

    >>> import math
    >>> scores = [90, 23, 6, 33, 21, 65, 123, 34423]
    >>> height = math.log(len(scores), 2)
    >>> minimax(0, 0, True, scores, height)
    65
    >>> minimax(-1, 0, True, scores, height)
    Traceback (most recent call last):
        ...
    ValueError: Depth cannot be less than 0
    >>> minimax(0, 0, True, [], 2)
    Traceback (most recent call last):
        ...
    ValueError: Scores cannot be empty
    >>> scores = [3, 5, 2, 9, 12, 5, 23, 23]
    >>> height = math.log(len(scores), 2)
    >>> minimax(0, 0, True, scores, height)
    12
    """
    if depth < 0:
        raise ValueError('Depth cannot be less than 0')
    if len(scores) == 0:
        raise ValueError('Scores cannot be empty')
    if depth == height:
        return scores[node_index]
    if is_max:
        return max(minimax(depth + 1, node_index * 2, False, scores, height), minimax(depth + 1, node_index * 2 + 1, False, scores, height))
    return min(minimax(depth + 1, node_index * 2, True, scores, height), minimax(depth + 1, node_index * 2 + 1, True, scores, height))
'\n    This function implements the minimax algorithm, which helps achieve the optimal\n    score for a player in a two-player game by checking all possible moves.\n    If the player is the maximizer, then the score is maximized.\n    If the player is the minimizer, then the score is minimized.\n\n    Parameters:\n    - depth: Current depth in the game tree.\n    - node_index: Index of the current node in the scores list.\n    - is_max: A boolean indicating whether the current move\n              is for the maximizer (True) or minimizer (False).\n    - scores: A list containing the scores of the leaves of the game tree.\n    - height: The maximum height of the game tree.\n\n    Returns:\n    - An integer representing the optimal score for the current player.\n\n    >>> import math\n    >>> scores = [90, 23, 6, 33, 21, 65, 123, 34423]\n    >>> height = math.log(len(scores), 2)\n    >>> minimax(0, 0, True, scores, height)\n    65\n    >>> minimax(-1, 0, True, scores, height)\n    Traceback (most recent call last):\n        ...\n    ValueError: Depth cannot be less than 0\n    >>> minimax(0, 0, True, [], 2)\n    Traceback (most recent call last):\n        ...\n    ValueError: Scores cannot be empty\n    >>> scores = [3, 5, 2, 9, 12, 5, 23, 23]\n    >>> height = math.log(len(scores), 2)\n    >>> minimax(0, 0, True, scores, height)\n    12\n    '
depth Lt 0
def main() -> None:
    scores = [90, 23, 6, 33, 21, 65, 123, 34423]
    height = math.log(len(scores), 2)
    print('Optimal value : ', end='')
    print(minimax(0, 0, True, scores, height))
scores = [90, 23, 6, 33, 21, 65, 123, 34423]
height = math.log(len(scores), 2)
print('Optimal value : ')
print(minimax(0, 0, True, scores, height))
__name__ Eq '__main__'
raise ValueError('Depth cannot be less than 0')
import doctest
doctest.testmod()
main()
len(scores) Eq 0
raise ValueError('Scores cannot be empty')
depth Eq height
return scores[node_index]
return max(minimax(depth + 1, node_index * 2, False, scores, height), minimax(depth + 1, node_index * 2 + 1, False, scores, height))