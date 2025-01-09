'\nGiven a partially filled 9x9 2D array, the objective is to fill a 9x9\nsquare grid with digits numbered 1 to 9, so that every row, column, and\nand each of the nine 3x3 sub-grids contains all of the digits.\n\nThis can be solved using Backtracking and is similar to n-queens.\nWe check to see if a cell is safe or not and recursively call the\nfunction on the next column to see if it returns True. if yes, we\nhave solved the puzzle. else, we backtrack and place another number\nin that cell and repeat this process.\n'
from __future__ import annotations
Matrix = list[list[int]]
initial_grid: Matrix = [[3, 0, 6, 5, 0, 8, 4, 0, 0], [5, 2, 0, 0, 0, 0, 0, 0, 0], [0, 8, 7, 0, 0, 0, 0, 3, 1], [0, 0, 3, 0, 1, 0, 0, 8, 0], [9, 0, 0, 8, 6, 3, 0, 0, 5], [0, 5, 0, 0, 9, 0, 6, 0, 0], [1, 3, 0, 0, 0, 0, 2, 5, 0], [0, 0, 0, 0, 0, 0, 0, 7, 4], [0, 0, 5, 2, 0, 6, 3, 0, 0]]
no_solution: Matrix = [[5, 0, 6, 5, 0, 8, 4, 0, 3], [5, 2, 0, 0, 0, 0, 0, 0, 2], [1, 8, 7, 0, 0, 0, 0, 3, 1], [0, 0, 3, 0, 1, 0, 0, 8, 0], [9, 0, 0, 8, 6, 3, 0, 0, 5], [0, 5, 0, 0, 9, 0, 6, 0, 0], [1, 3, 0, 0, 0, 0, 2, 5, 0], [0, 0, 0, 0, 0, 0, 0, 7, 4], [0, 0, 5, 2, 0, 6, 3, 0, 0]]
def is_safe(grid: Matrix, row: int, column: int, n: int) -> bool:
    """
    This function checks the grid to see if each row,
    column, and the 3x3 subgrids contain the digit 'n'.
    It returns False if it is not 'safe' (a duplicate digit
    is found) else returns True if it is 'safe'
    """
    for i in range(9):
        if n in {grid[row][i], grid[i][column]}:
            return False
    for i in range(3):
        for j in range(3):
            if grid[row - row % 3 + i][column - column % 3 + j] == n:
                return False
    return True
"\n    This function checks the grid to see if each row,\n    column, and the 3x3 subgrids contain the digit 'n'.\n    It returns False if it is not 'safe' (a duplicate digit\n    is found) else returns True if it is 'safe'\n    "
i
range(9)
n In {grid[row][i], grid[i][column]}
return False
i
range(3)
return True
j
range(3)
grid[row - row % 3 + i][column - column % 3 + j] Eq n
return False
def find_empty_location(grid: Matrix) -> tuple[int, int] | None:
    """
    This function finds an empty location so that we can assign a number
    for that particular row and column.
    """
    for i in range(9):
        for j in range(9):
            if grid[i][j] == 0:
                return (i, j)
    return None
'\n    This function finds an empty location so that we can assign a number\n    for that particular row and column.\n    '
i
range(9)
return None
j
range(9)
grid[i][j] Eq 0
return (i, j)
def sudoku(grid: Matrix) -> Matrix | None:
    """
    Takes a partially filled-in grid and attempts to assign values to
    all unassigned locations in such a way to meet the requirements
    for Sudoku solution (non-duplication across rows, columns, and boxes)

    >>> sudoku(initial_grid)  # doctest: +NORMALIZE_WHITESPACE
    [[3, 1, 6, 5, 7, 8, 4, 9, 2],
     [5, 2, 9, 1, 3, 4, 7, 6, 8],
     [4, 8, 7, 6, 2, 9, 5, 3, 1],
     [2, 6, 3, 4, 1, 5, 9, 8, 7],
     [9, 7, 4, 8, 6, 3, 1, 2, 5],
     [8, 5, 1, 7, 9, 2, 6, 4, 3],
     [1, 3, 8, 9, 4, 7, 2, 5, 6],
     [6, 9, 2, 3, 5, 1, 8, 7, 4],
     [7, 4, 5, 2, 8, 6, 3, 1, 9]]
     >>> sudoku(no_solution) is None
     True
    """
    if (location := find_empty_location(grid)):
        (row, column) = location
    else:
        return grid
    for digit in range(1, 10):
        if is_safe(grid, row, column, digit):
            grid[row][column] = digit
            if sudoku(grid) is not None:
                return grid
            grid[row][column] = 0
    return None
'\n    Takes a partially filled-in grid and attempts to assign values to\n    all unassigned locations in such a way to meet the requirements\n    for Sudoku solution (non-duplication across rows, columns, and boxes)\n\n    >>> sudoku(initial_grid)  # doctest: +NORMALIZE_WHITESPACE\n    [[3, 1, 6, 5, 7, 8, 4, 9, 2],\n     [5, 2, 9, 1, 3, 4, 7, 6, 8],\n     [4, 8, 7, 6, 2, 9, 5, 3, 1],\n     [2, 6, 3, 4, 1, 5, 9, 8, 7],\n     [9, 7, 4, 8, 6, 3, 1, 2, 5],\n     [8, 5, 1, 7, 9, 2, 6, 4, 3],\n     [1, 3, 8, 9, 4, 7, 2, 5, 6],\n     [6, 9, 2, 3, 5, 1, 8, 7, 4],\n     [7, 4, 5, 2, 8, 6, 3, 1, 9]]\n     >>> sudoku(no_solution) is None\n     True\n    '
(location := find_empty_location(grid))
(row, column) = location
return grid
digit
range(1, 10)
is_safe(grid, row, column, digit)
return None
grid[row][column] = digit
sudoku(grid) IsNot None
return grid
def print_solution(grid: Matrix) -> None:
    """
    A function to print the solution in the form
    of a 9x9 grid
    """
    for row in grid:
        for cell in row:
            print(cell, end=' ')
        print()
'\n    A function to print the solution in the form\n    of a 9x9 grid\n    '
row
grid
__name__ Eq '__main__'
cell
row
print(cell)
print()
example_grid
(initial_grid, no_solution)
print('\nExample grid:\n' Add '=' Mult 20)
print_solution(example_grid)
print('\nExample grid solution:')
solution = sudoku(example_grid)
solution IsNot None
print_solution(solution)
print('Cannot find a solution.')