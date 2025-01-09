"\nProblem:\n\nThe n queens problem is: placing N queens on a N * N chess board such that no queen\ncan attack any other queens placed on that chess board.  This means that one queen\ncannot have any other queen on its horizontal, vertical and diagonal lines.\n\nSolution:\n\nTo solve this problem we will use simple math. First we know the queen can move in all\nthe possible ways, we can simplify it in this: vertical, horizontal, diagonal left and\n diagonal right.\n\nWe can visualize it like this:\n\nleft diagonal = \\\nright diagonal = /\n\nOn a chessboard vertical movement could be the rows and horizontal movement could be\nthe columns.\n\nIn programming we can use an array, and in this array each index could be the rows and\neach value in the array could be the column. For example:\n\n    . Q . .     We have this chessboard with one queen in each column and each queen\n    . . . Q     can't attack to each other.\n    Q . . .     The array for this example would look like this: [1, 3, 0, 2]\n    . . Q .\n\nSo if we use an array and we verify that each value in the array is different to each\nother we know that at least the queens can't attack each other in horizontal and\nvertical.\n\nAt this point we have it halfway completed and we will treat the chessboard as a\nCartesian plane.  Hereinafter we are going to remember basic math, so in the school we\nlearned this formula:\n\n    Slope of a line:\n\n           y2 - y1\n     m = ----------\n          x2 - x1\n\nThis formula allow us to get the slope. For the angles 45º (right diagonal) and 135º\n(left diagonal) this formula gives us m = 1, and m = -1 respectively.\n\nSee::\nhttps://www.enotes.com/homework-help/write-equation-line-that-hits-origin-45-degree-1474860\n\nThen we have this other formula:\n\nSlope intercept:\n\ny = mx + b\n\nb is where the line crosses the Y axis (to get more information see:\nhttps://www.mathsisfun.com/y_intercept.html), if we change the formula to solve for b\nwe would have:\n\ny - mx = b\n\nAnd since we already have the m values for the angles 45º and 135º, this formula would\nlook like this:\n\n45º: y - (1)x = b\n45º: y - x = b\n\n135º: y - (-1)x = b\n135º: y + x = b\n\ny = row\nx = column\n\nApplying these two formulas we can check if a queen in some position is being attacked\nfor another one or vice versa.\n\n"
from __future__ import annotations
def depth_first_search(possible_board: list[int], diagonal_right_collisions: list[int], diagonal_left_collisions: list[int], boards: list[list[str]], n: int) -> None:
    """
    >>> boards = []
    >>> depth_first_search([], [], [], boards, 4)
    >>> for board in boards:
    ...     print(board)
    ['. Q . . ', '. . . Q ', 'Q . . . ', '. . Q . ']
    ['. . Q . ', 'Q . . . ', '. . . Q ', '. Q . . ']
    """
    row = len(possible_board)
    if row == n:
        boards.append(['. ' * i + 'Q ' + '. ' * (n - 1 - i) for i in possible_board])
        return
    for col in range(n):
        if col in possible_board or row - col in diagonal_right_collisions or row + col in diagonal_left_collisions:
            continue
        depth_first_search([*possible_board, col], [*diagonal_right_collisions, row - col], [*diagonal_left_collisions, row + col], boards, n)
"\n    >>> boards = []\n    >>> depth_first_search([], [], [], boards, 4)\n    >>> for board in boards:\n    ...     print(board)\n    ['. Q . . ', '. . . Q ', 'Q . . . ', '. . Q . ']\n    ['. . Q . ', 'Q . . . ', '. . . Q ', '. Q . . ']\n    "
row = len(possible_board)
row Eq n
boards.append(['. ' * i + 'Q ' + '. ' * (n - 1 - i) for i in possible_board])
return
col
range(n)
col in possible_board or row - col in diagonal_right_collisions or row + col in diagonal_left_collisions
def n_queens_solution(n: int) -> None:
    boards: list[list[str]] = []
    depth_first_search([], [], [], boards, n)
    for board in boards:
        for column in board:
            print(column)
        print('')
    print(len(boards), 'solutions were found.')
boards: list[list[str]] = []
depth_first_search([], [], [], boards, n)
continue
depth_first_search([*possible_board, col], [*diagonal_right_collisions, row - col], [*diagonal_left_collisions, row + col], boards, n)
board
boards
print(len(boards), 'solutions were found.')
__name__ Eq '__main__'
column
board
print(column)
print('')
import doctest
doctest.testmod()
n_queens_solution(4)