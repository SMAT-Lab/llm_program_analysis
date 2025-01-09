from __future__ import annotations
def solve_maze(maze: list[list[int]], source_row: int, source_column: int, destination_row: int, destination_column: int) -> list[list[int]]:
    """
    This method solves the "rat in maze" problem.
    Parameters :
        - maze: A two dimensional matrix of zeros and ones.
        - source_row: The row index of the starting point.
        - source_column: The column index of the starting point.
        - destination_row: The row index of the destination point.
        - destination_column: The column index of the destination point.
    Returns:
        - solution: A 2D matrix representing the solution path if it exists.
    Raises:
        - ValueError: If no solution exists or if the source or
            destination coordinates are invalid.
    Description:
        This method navigates through a maze represented as an n by n matrix,
        starting from a specified source cell and
        aiming to reach a destination cell.
        The maze consists of walls (1s) and open paths (0s).
        By providing custom row and column values, the source and destination
        cells can be adjusted.
    >>> maze = [[0, 1, 0, 1, 1],
    ...         [0, 0, 0, 0, 0],
    ...         [1, 0, 1, 0, 1],
    ...         [0, 0, 1, 0, 0],
    ...         [1, 0, 0, 1, 0]]
    >>> solve_maze(maze,0,0,len(maze)-1,len(maze)-1)    # doctest: +NORMALIZE_WHITESPACE
    [[0, 1, 1, 1, 1],
    [0, 0, 0, 0, 1],
    [1, 1, 1, 0, 1],
    [1, 1, 1, 0, 0],
    [1, 1, 1, 1, 0]]

    Note:
        In the output maze, the zeros (0s) represent one of the possible
        paths from the source to the destination.

    >>> maze = [[0, 1, 0, 1, 1],
    ...         [0, 0, 0, 0, 0],
    ...         [0, 0, 0, 0, 1],
    ...         [0, 0, 0, 0, 0],
    ...         [0, 0, 0, 0, 0]]
    >>> solve_maze(maze,0,0,len(maze)-1,len(maze)-1)    # doctest: +NORMALIZE_WHITESPACE
    [[0, 1, 1, 1, 1],
    [0, 1, 1, 1, 1],
    [0, 1, 1, 1, 1],
    [0, 1, 1, 1, 1],
    [0, 0, 0, 0, 0]]

    >>> maze = [[0, 0, 0],
    ...         [0, 1, 0],
    ...         [1, 0, 0]]
    >>> solve_maze(maze,0,0,len(maze)-1,len(maze)-1)    # doctest: +NORMALIZE_WHITESPACE
    [[0, 0, 0],
    [1, 1, 0],
    [1, 1, 0]]

    >>> maze = [[1, 0, 0],
    ...         [0, 1, 0],
    ...         [1, 0, 0]]
    >>> solve_maze(maze,0,1,len(maze)-1,len(maze)-1)    # doctest: +NORMALIZE_WHITESPACE
    [[1, 0, 0],
    [1, 1, 0],
    [1, 1, 0]]

    >>> maze = [[1, 1, 0, 0, 1, 0, 0, 1],
    ...         [1, 0, 1, 0, 0, 1, 1, 1],
    ...         [0, 1, 0, 1, 0, 0, 1, 0],
    ...         [1, 1, 1, 0, 0, 1, 0, 1],
    ...         [0, 1, 0, 0, 1, 0, 1, 1],
    ...         [0, 0, 0, 1, 1, 1, 0, 1],
    ...         [0, 1, 0, 1, 0, 1, 1, 1],
    ...         [1, 1, 0, 0, 0, 0, 0, 1]]
    >>> solve_maze(maze,0,2,len(maze)-1,2)  # doctest: +NORMALIZE_WHITESPACE
    [[1, 1, 0, 0, 1, 1, 1, 1],
    [1, 1, 1, 0, 0, 1, 1, 1],
    [1, 1, 1, 1, 0, 1, 1, 1],
    [1, 1, 1, 0, 0, 1, 1, 1],
    [1, 1, 0, 0, 1, 1, 1, 1],
    [1, 1, 0, 1, 1, 1, 1, 1],
    [1, 1, 0, 1, 1, 1, 1, 1],
    [1, 1, 0, 1, 1, 1, 1, 1]]
    >>> maze = [[1, 0, 0],
    ...         [0, 1, 1],
    ...         [1, 0, 1]]
    >>> solve_maze(maze,0,1,len(maze)-1,len(maze)-1)
    Traceback (most recent call last):
        ...
    ValueError: No solution exists!

    >>> maze = [[0, 0],
    ...         [1, 1]]
    >>> solve_maze(maze,0,0,len(maze)-1,len(maze)-1)
    Traceback (most recent call last):
        ...
    ValueError: No solution exists!

    >>> maze = [[0, 1],
    ...         [1, 0]]
    >>> solve_maze(maze,2,0,len(maze)-1,len(maze)-1)
    Traceback (most recent call last):
        ...
    ValueError: Invalid source or destination coordinates

    >>> maze = [[1, 0, 0],
    ...         [0, 1, 0],
    ...         [1, 0, 0]]
    >>> solve_maze(maze,0,1,len(maze),len(maze)-1)
    Traceback (most recent call last):
        ...
    ValueError: Invalid source or destination coordinates
    """
    size = len(maze)
    if not (0 <= source_row <= size - 1 and 0 <= source_column <= size - 1) or not (0 <= destination_row <= size - 1 and 0 <= destination_column <= size - 1):
        raise ValueError('Invalid source or destination coordinates')
    solutions = [[1 for _ in range(size)] for _ in range(size)]
    solved = run_maze(maze, source_row, source_column, destination_row, destination_column, solutions)
    if solved:
        return solutions
    else:
        raise ValueError('No solution exists!')
'\n    This method solves the "rat in maze" problem.\n    Parameters :\n        - maze: A two dimensional matrix of zeros and ones.\n        - source_row: The row index of the starting point.\n        - source_column: The column index of the starting point.\n        - destination_row: The row index of the destination point.\n        - destination_column: The column index of the destination point.\n    Returns:\n        - solution: A 2D matrix representing the solution path if it exists.\n    Raises:\n        - ValueError: If no solution exists or if the source or\n            destination coordinates are invalid.\n    Description:\n        This method navigates through a maze represented as an n by n matrix,\n        starting from a specified source cell and\n        aiming to reach a destination cell.\n        The maze consists of walls (1s) and open paths (0s).\n        By providing custom row and column values, the source and destination\n        cells can be adjusted.\n    >>> maze = [[0, 1, 0, 1, 1],\n    ...         [0, 0, 0, 0, 0],\n    ...         [1, 0, 1, 0, 1],\n    ...         [0, 0, 1, 0, 0],\n    ...         [1, 0, 0, 1, 0]]\n    >>> solve_maze(maze,0,0,len(maze)-1,len(maze)-1)    # doctest: +NORMALIZE_WHITESPACE\n    [[0, 1, 1, 1, 1],\n    [0, 0, 0, 0, 1],\n    [1, 1, 1, 0, 1],\n    [1, 1, 1, 0, 0],\n    [1, 1, 1, 1, 0]]\n\n    Note:\n        In the output maze, the zeros (0s) represent one of the possible\n        paths from the source to the destination.\n\n    >>> maze = [[0, 1, 0, 1, 1],\n    ...         [0, 0, 0, 0, 0],\n    ...         [0, 0, 0, 0, 1],\n    ...         [0, 0, 0, 0, 0],\n    ...         [0, 0, 0, 0, 0]]\n    >>> solve_maze(maze,0,0,len(maze)-1,len(maze)-1)    # doctest: +NORMALIZE_WHITESPACE\n    [[0, 1, 1, 1, 1],\n    [0, 1, 1, 1, 1],\n    [0, 1, 1, 1, 1],\n    [0, 1, 1, 1, 1],\n    [0, 0, 0, 0, 0]]\n\n    >>> maze = [[0, 0, 0],\n    ...         [0, 1, 0],\n    ...         [1, 0, 0]]\n    >>> solve_maze(maze,0,0,len(maze)-1,len(maze)-1)    # doctest: +NORMALIZE_WHITESPACE\n    [[0, 0, 0],\n    [1, 1, 0],\n    [1, 1, 0]]\n\n    >>> maze = [[1, 0, 0],\n    ...         [0, 1, 0],\n    ...         [1, 0, 0]]\n    >>> solve_maze(maze,0,1,len(maze)-1,len(maze)-1)    # doctest: +NORMALIZE_WHITESPACE\n    [[1, 0, 0],\n    [1, 1, 0],\n    [1, 1, 0]]\n\n    >>> maze = [[1, 1, 0, 0, 1, 0, 0, 1],\n    ...         [1, 0, 1, 0, 0, 1, 1, 1],\n    ...         [0, 1, 0, 1, 0, 0, 1, 0],\n    ...         [1, 1, 1, 0, 0, 1, 0, 1],\n    ...         [0, 1, 0, 0, 1, 0, 1, 1],\n    ...         [0, 0, 0, 1, 1, 1, 0, 1],\n    ...         [0, 1, 0, 1, 0, 1, 1, 1],\n    ...         [1, 1, 0, 0, 0, 0, 0, 1]]\n    >>> solve_maze(maze,0,2,len(maze)-1,2)  # doctest: +NORMALIZE_WHITESPACE\n    [[1, 1, 0, 0, 1, 1, 1, 1],\n    [1, 1, 1, 0, 0, 1, 1, 1],\n    [1, 1, 1, 1, 0, 1, 1, 1],\n    [1, 1, 1, 0, 0, 1, 1, 1],\n    [1, 1, 0, 0, 1, 1, 1, 1],\n    [1, 1, 0, 1, 1, 1, 1, 1],\n    [1, 1, 0, 1, 1, 1, 1, 1],\n    [1, 1, 0, 1, 1, 1, 1, 1]]\n    >>> maze = [[1, 0, 0],\n    ...         [0, 1, 1],\n    ...         [1, 0, 1]]\n    >>> solve_maze(maze,0,1,len(maze)-1,len(maze)-1)\n    Traceback (most recent call last):\n        ...\n    ValueError: No solution exists!\n\n    >>> maze = [[0, 0],\n    ...         [1, 1]]\n    >>> solve_maze(maze,0,0,len(maze)-1,len(maze)-1)\n    Traceback (most recent call last):\n        ...\n    ValueError: No solution exists!\n\n    >>> maze = [[0, 1],\n    ...         [1, 0]]\n    >>> solve_maze(maze,2,0,len(maze)-1,len(maze)-1)\n    Traceback (most recent call last):\n        ...\n    ValueError: Invalid source or destination coordinates\n\n    >>> maze = [[1, 0, 0],\n    ...         [0, 1, 0],\n    ...         [1, 0, 0]]\n    >>> solve_maze(maze,0,1,len(maze),len(maze)-1)\n    Traceback (most recent call last):\n        ...\n    ValueError: Invalid source or destination coordinates\n    '
size = len(maze)
not (0 <= source_row <= size - 1 and 0 <= source_column <= size - 1) or not (0 <= destination_row <= size - 1 and 0 <= destination_column <= size - 1)
__name__ Eq '__main__'
raise ValueError('Invalid source or destination coordinates')
import doctest
doctest.testmod()
solutions = [[1 for _ in range(size)] for _ in range(size)]
solved = run_maze(maze, source_row, source_column, destination_row, destination_column, solutions)
solved
raise ValueError('No solution exists!')
return solutions
solutions[i][j] = 0
return True
block_flag = solutions[i][j] and (not maze[i][j])
block_flag
solutions[i][j] = 0
run_maze(maze, i + 1, j, destination_row, destination_column, solutions) or run_maze(maze, i, j + 1, destination_row, destination_column, solutions) or run_maze(maze, i - 1, j, destination_row, destination_column, solutions) or run_maze(maze, i, j - 1, destination_row, destination_column, solutions)
return False
return True