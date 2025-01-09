from __future__ import annotations

def solve_maze(
    maze: list[list[int]],
    source_row: int,
    source_column: int,
    destination_row: int,
    destination_column: int,
) -> list[list[int]]:
    """
    This method solves the "rat in maze" problem.
    Parameters:
        - maze: A two dimensional matrix of zeros and ones.
        - source_row: The row index of the starting point.
        - source_column: The column index of the starting point.
        - destination_row: The row index of the destination point.
        - destination_column: The column index of the destination point.
    Returns:
        - solution: A 2D matrix representing the solution path if it exists.
    Raises:
        - ValueError: If no solution exists or if the source or destination coordinates are invalid.
    Description:
        This method navigates through a maze represented as an n by n matrix,
        starting from a specified source cell and aiming to reach a destination cell.
        The maze consists of walls (1s) and open paths (0s).
        By providing custom row and column values, the source and destination cells can be adjusted.
    """
    size = len(maze)
    # Check if source and destination coordinates are invalid.
    if not (0 <= source_row <= size - 1 and 0 <= source_column <= size - 1) or (
        not (0 <= destination_row <= size - 1 and 0 <= destination_column <= size - 1)
    ):
        raise ValueError("Invalid source or destination coordinates")
    
    # We need to create a solution object to save the path.
    solutions = [[1 for _ in range(size)] for _ in range(size)]
    solved = run_maze(maze, source_row, source_column, destination_row, destination_column, solutions)
    
    if solved:
        return solutions
    else:
        raise ValueError("No solution exists!")

def run_maze(
    maze: list[list[int]],
    i: int,
    j: int,
    destination_row: int,
    destination_column: int,
    solutions: list[list[int]],
) -> bool:
    """
    This method is recursive starting from (i, j) and going in one of four directions:
    up, down, left, right.
    If a path is found to destination, it returns True; otherwise, it returns False.
    Parameters:
        maze: A two dimensional matrix of zeros and ones.
        i, j: coordinates of the matrix.
        solutions: A two dimensional matrix of solutions.
    Returns:
        Boolean: True if a path is found, otherwise False.
    """
    size = len(maze)
    # Final check point.
    if i == destination_row and j == destination_column and maze[i][j] == 0:
        solutions[i][j] = 0
        return True
    
    lower_flag = (not i < 0) and (not j < 0)  # Check lower bounds
    upper_flag = (i < size) and (j < size)  # Check upper bounds
    
    if lower_flag and upper_flag:
        # Check for already visited and block points.
        block_flag = (solutions[i][j]) and (not maze[i][j])
        if block_flag:
            # Check visited
            solutions[i][j] = 0
        
        # Check for directions
        if (
            run_maze(maze, i + 1, j, destination_row, destination_column, solutions)
            or run_maze(maze, i, j + 1, destination_row, destination_column, solutions)
            or run_maze(maze, i - 1, j, destination_row, destination_column, solutions)
            or run_maze(maze, i, j - 1, destination_row, destination_column, solutions)
        ):
            return True
        
        solutions[i][j] = 1
        return False
    
    return False

if __name__ == "__main__":
    import doctest
    doctest.testmod(optionflags=doctest.NORMALIZE_WHITESPACE)