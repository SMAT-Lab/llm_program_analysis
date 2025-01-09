'\n\nThe nqueens problem is of placing N queens on a N * N\nchess board such that no queen can attack any other queens placed\non that chess board.\nThis means that one queen cannot have any other queen on its horizontal, vertical and\ndiagonal lines.\n\n'
from __future__ import annotations
solution = []
def is_safe(board: list[list[int]], row: int, column: int) -> bool:
    """
    This function returns a boolean value True if it is safe to place a queen there
    considering the current state of the board.

    Parameters:
    board (2D matrix): The chessboard
    row, column: Coordinates of the cell on the board

    Returns:
    Boolean Value

    >>> is_safe([[0, 0, 0], [0, 0, 0], [0, 0, 0]], 1, 1)
    True
    >>> is_safe([[1, 0, 0], [0, 0, 0], [0, 0, 0]], 1, 1)
    False
    """
    n = len(board)
    return all((board[i][j] != 1 for (i, j) in zip(range(row, -1, -1), range(column, n)))) and all((board[i][j] != 1 for (i, j) in zip(range(row, -1, -1), range(column, -1, -1)))) and all((board[i][j] != 1 for (i, j) in zip(range(row, n), range(column, n)))) and all((board[i][j] != 1 for (i, j) in zip(range(row, n), range(column, -1, -1))))
'\n    This function returns a boolean value True if it is safe to place a queen there\n    considering the current state of the board.\n\n    Parameters:\n    board (2D matrix): The chessboard\n    row, column: Coordinates of the cell on the board\n\n    Returns:\n    Boolean Value\n\n    >>> is_safe([[0, 0, 0], [0, 0, 0], [0, 0, 0]], 1, 1)\n    True\n    >>> is_safe([[1, 0, 0], [0, 0, 0], [0, 0, 0]], 1, 1)\n    False\n    '
n = len(board)
return all((board[i][j] != 1 for (i, j) in zip(range(row, -1, -1), range(column, n)))) and all((board[i][j] != 1 for (i, j) in zip(range(row, -1, -1), range(column, -1, -1)))) and all((board[i][j] != 1 for (i, j) in zip(range(row, n), range(column, n)))) and all((board[i][j] != 1 for (i, j) in zip(range(row, n), range(column, -1, -1))))
def solve(board: list[list[int]], row: int) -> bool:
    """
    This function creates a state space tree and calls the safe function until it
    receives a False Boolean and terminates that branch and backtracks to the next
    possible solution branch.
    """
    if row >= len(board):
        '\n        If the row number exceeds N, we have a board with a successful combination\n        and that combination is appended to the solution list and the board is printed.\n        '
        solution.append(board)
        printboard(board)
        print()
        return True
    for i in range(len(board)):
        '\n        For every row, it iterates through each column to check if it is feasible to\n        place a queen there.\n        If all the combinations for that particular branch are successful, the board is\n        reinitialized for the next possible combination.\n        '
        if is_safe(board, row, i):
            board[row][i] = 1
            solve(board, row + 1)
            board[row][i] = 0
    return False
'\n    This function creates a state space tree and calls the safe function until it\n    receives a False Boolean and terminates that branch and backtracks to the next\n    possible solution branch.\n    '
row GtE len(board)
'\n        If the row number exceeds N, we have a board with a successful combination\n        and that combination is appended to the solution list and the board is printed.\n        '
solution.append(board)
printboard(board)
print()
return True
i
range(len(board))
'\n        For every row, it iterates through each column to check if it is feasible to\n        place a queen there.\n        If all the combinations for that particular branch are successful, the board is\n        reinitialized for the next possible combination.\n        '
is_safe(board, row, i)
return False
board[row][i] = 1
solve(board, row Add 1)
board[row][i] = 0
def printboard(board: list[list[int]]) -> None:
    """
    Prints the boards that have a successful combination.
    """
    for i in range(len(board)):
        for j in range(len(board)):
            if board[i][j] == 1:
                print('Q', end=' ')
            else:
                print('.', end=' ')
        print()
'\n    Prints the boards that have a successful combination.\n    '
i
range(len(board))
n = 8
board = [[0 for i in range(n)] for j in range(n)]
solve(board, 0)
print('The total number of solutions are:', len(solution))
j
range(len(board))
board[i][j] Eq 1
print()
print('Q')
print('.')