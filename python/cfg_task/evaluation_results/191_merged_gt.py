from __future__ import annotations
def get_valid_pos(position: tuple[int, int], n: int) -> list[tuple[int, int]]:
    """
    Find all the valid positions a knight can move to from the current position.

    >>> get_valid_pos((1, 3), 4)
    [(2, 1), (0, 1), (3, 2)]
    """
    (y, x) = position
    positions = [(y + 1, x + 2), (y - 1, x + 2), (y + 1, x - 2), (y - 1, x - 2), (y + 2, x + 1), (y + 2, x - 1), (y - 2, x + 1), (y - 2, x - 1)]
    permissible_positions = []
    for inner_position in positions:
        (y_test, x_test) = inner_position
        if 0 <= y_test < n and 0 <= x_test < n:
            permissible_positions.append(inner_position)
    return permissible_positions
'\n    Find all the valid positions a knight can move to from the current position.\n\n    >>> get_valid_pos((1, 3), 4)\n    [(2, 1), (0, 1), (3, 2)]\n    '
(y, x) = position
positions = [(y + 1, x + 2), (y - 1, x + 2), (y + 1, x - 2), (y - 1, x - 2), (y + 2, x + 1), (y + 2, x - 1), (y - 2, x + 1), (y - 2, x - 1)]
permissible_positions = []
inner_position
positions
(y_test, x_test) = inner_position
0 <= y_test < n and 0 <= x_test < n
return permissible_positions
permissible_positions.append(inner_position)
def is_complete(board: list[list[int]]) -> bool:
    """
    Check if the board (matrix) has been completely filled with non-zero values.

    >>> is_complete([[1]])
    True

    >>> is_complete([[1, 2], [3, 0]])
    False
    """
    return not any((elem == 0 for row in board for elem in row))
'\n    Check if the board (matrix) has been completely filled with non-zero values.\n\n    >>> is_complete([[1]])\n    True\n\n    >>> is_complete([[1, 2], [3, 0]])\n    False\n    '
return not any((elem == 0 for row in board for elem in row))
def open_knight_tour_helper(board: list[list[int]], pos: tuple[int, int], curr: int) -> bool:
    """
    Helper function to solve knight tour problem.
    """
    if is_complete(board):
        return True
    for position in get_valid_pos(pos, len(board)):
        (y, x) = position
        if board[y][x] == 0:
            board[y][x] = curr + 1
            if open_knight_tour_helper(board, position, curr + 1):
                return True
            board[y][x] = 0
    return False
'\n    Helper function to solve knight tour problem.\n    '
is_complete(board)
return True
position
get_valid_pos(pos, len(board))
(y, x) = position
board[y][x] Eq 0
return False
board[y][x] = curr + 1
open_knight_tour_helper(board, position, curr Add 1)
return True
def open_knight_tour(n: int) -> list[list[int]]:
    """
    Find the solution for the knight tour problem for a board of size n. Raises
    ValueError if the tour cannot be performed for the given size.

    >>> open_knight_tour(1)
    [[1]]

    >>> open_knight_tour(2)
    Traceback (most recent call last):
        ...
    ValueError: Open Knight Tour cannot be performed on a board of size 2
    """
    board = [[0 for i in range(n)] for j in range(n)]
    for i in range(n):
        for j in range(n):
            board[i][j] = 1
            if open_knight_tour_helper(board, (i, j), 1):
                return board
            board[i][j] = 0
    msg = f'Open Knight Tour cannot be performed on a board of size {n}'
    raise ValueError(msg)
'\n    Find the solution for the knight tour problem for a board of size n. Raises\n    ValueError if the tour cannot be performed for the given size.\n\n    >>> open_knight_tour(1)\n    [[1]]\n\n    >>> open_knight_tour(2)\n    Traceback (most recent call last):\n        ...\n    ValueError: Open Knight Tour cannot be performed on a board of size 2\n    '
board = [[0 for i in range(n)] for j in range(n)]
i
range(n)
msg = f'Open Knight Tour cannot be performed on a board of size {n}'
raise ValueError(msg)
__name__ Eq '__main__'
j
range(n)
board[i][j] = 1
open_knight_tour_helper(board, (i, j), 1)
return board
import doctest
doctest.testmod()