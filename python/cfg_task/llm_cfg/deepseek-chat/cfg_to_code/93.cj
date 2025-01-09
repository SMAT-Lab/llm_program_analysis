```python
# https://www.geeksforgeeks.org/solve-crossword-puzzle/


def is_valid(
    puzzle: list[list[str]], word: str, row: int, col: int, vertical: bool
) -> bool:
    """
    Check if a word can be placed at the given position.

    >>> puzzle = [
    ...     ['', '', '', ''],
    ...     ['', '', '', ''],
    ...     ['', '', '', ''],
    ...     ['', '', '', '']
    ... ]
    >>> is_valid(puzzle, 'word', 0, 0, True)
    True
    >>> puzzle = [
    ...     ['', '', '', ''],
    ...     ['', '', '', ''],
    ...     ['', '', '', ''],
    ...     ['', '', '', '']
    ... ]
    >>> is_valid(puzzle, 'word', 0, 0, False)
    True
    """
    for i in range(len(word)):
        if vertical:
            if row + i >= len(puzzle) or puzzle[row + i][col] != "":
                return False
        elif col + i >= len(puzzle[0]) or puzzle[row][col + i] != "":
            return False
    return True