def is_valid(puzzle: list[list[str]], word: str, row: int, col: int, vertical: bool) -> bool:
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
            if row + i >= len(puzzle) or puzzle[row + i][col] != '':
                return False
        elif col + i >= len(puzzle[0]) or puzzle[row][col + i] != '':
            return False
    return True
"\n    Check if a word can be placed at the given position.\n\n    >>> puzzle = [\n    ...     ['', '', '', ''],\n    ...     ['', '', '', ''],\n    ...     ['', '', '', ''],\n    ...     ['', '', '', '']\n    ... ]\n    >>> is_valid(puzzle, 'word', 0, 0, True)\n    True\n    >>> puzzle = [\n    ...     ['', '', '', ''],\n    ...     ['', '', '', ''],\n    ...     ['', '', '', ''],\n    ...     ['', '', '', '']\n    ... ]\n    >>> is_valid(puzzle, 'word', 0, 0, False)\n    True\n    "
i
range(len(word))
vertical
return True
row + i >= len(puzzle) or puzzle[row + i][col] != ''
col + i >= len(puzzle[0]) or puzzle[row][col + i] != ''
return False
return False
def place_word(puzzle: list[list[str]], word: str, row: int, col: int, vertical: bool) -> None:
    """
    Place a word at the given position.

    >>> puzzle = [
    ...     ['', '', '', ''],
    ...     ['', '', '', ''],
    ...     ['', '', '', ''],
    ...     ['', '', '', '']
    ... ]
    >>> place_word(puzzle, 'word', 0, 0, True)
    >>> puzzle
    [['w', '', '', ''], ['o', '', '', ''], ['r', '', '', ''], ['d', '', '', '']]
    """
    for (i, char) in enumerate(word):
        if vertical:
            puzzle[row + i][col] = char
        else:
            puzzle[row][col + i] = char
"\n    Place a word at the given position.\n\n    >>> puzzle = [\n    ...     ['', '', '', ''],\n    ...     ['', '', '', ''],\n    ...     ['', '', '', ''],\n    ...     ['', '', '', '']\n    ... ]\n    >>> place_word(puzzle, 'word', 0, 0, True)\n    >>> puzzle\n    [['w', '', '', ''], ['o', '', '', ''], ['r', '', '', ''], ['d', '', '', '']]\n    "
(i, char)
enumerate(word)
vertical
def remove_word(puzzle: list[list[str]], word: str, row: int, col: int, vertical: bool) -> None:
    """
    Remove a word from the given position.

    >>> puzzle = [
    ...     ['w', '', '', ''],
    ...     ['o', '', '', ''],
    ...     ['r', '', '', ''],
    ...     ['d', '', '', '']
    ... ]
    >>> remove_word(puzzle, 'word', 0, 0, True)
    >>> puzzle
    [['', '', '', ''], ['', '', '', ''], ['', '', '', ''], ['', '', '', '']]
    """
    for i in range(len(word)):
        if vertical:
            puzzle[row + i][col] = ''
        else:
            puzzle[row][col + i] = ''
"\n    Remove a word from the given position.\n\n    >>> puzzle = [\n    ...     ['w', '', '', ''],\n    ...     ['o', '', '', ''],\n    ...     ['r', '', '', ''],\n    ...     ['d', '', '', '']\n    ... ]\n    >>> remove_word(puzzle, 'word', 0, 0, True)\n    >>> puzzle\n    [['', '', '', ''], ['', '', '', ''], ['', '', '', ''], ['', '', '', '']]\n    "
puzzle[row + i][col] = char
puzzle[row][col + i] = char
i
range(len(word))
vertical
def solve_crossword(puzzle: list[list[str]], words: list[str]) -> bool:
    """
    Solve the crossword puzzle using backtracking.

    >>> puzzle = [
    ...     ['', '', '', ''],
    ...     ['', '', '', ''],
    ...     ['', '', '', ''],
    ...     ['', '', '', '']
    ... ]

    >>> words = ['word', 'four', 'more', 'last']
    >>> solve_crossword(puzzle, words)
    True
    >>> puzzle = [
    ...     ['', '', '', ''],
    ...     ['', '', '', ''],
    ...     ['', '', '', ''],
    ...     ['', '', '', '']
    ... ]
    >>> words = ['word', 'four', 'more', 'paragraphs']
    >>> solve_crossword(puzzle, words)
    False
    """
    for row in range(len(puzzle)):
        for col in range(len(puzzle[0])):
            if puzzle[row][col] == '':
                for word in words:
                    for vertical in [True, False]:
                        if is_valid(puzzle, word, row, col, vertical):
                            place_word(puzzle, word, row, col, vertical)
                            words.remove(word)
                            if solve_crossword(puzzle, words):
                                return True
                            words.append(word)
                            remove_word(puzzle, word, row, col, vertical)
                return False
    return True
"\n    Solve the crossword puzzle using backtracking.\n\n    >>> puzzle = [\n    ...     ['', '', '', ''],\n    ...     ['', '', '', ''],\n    ...     ['', '', '', ''],\n    ...     ['', '', '', '']\n    ... ]\n\n    >>> words = ['word', 'four', 'more', 'last']\n    >>> solve_crossword(puzzle, words)\n    True\n    >>> puzzle = [\n    ...     ['', '', '', ''],\n    ...     ['', '', '', ''],\n    ...     ['', '', '', ''],\n    ...     ['', '', '', '']\n    ... ]\n    >>> words = ['word', 'four', 'more', 'paragraphs']\n    >>> solve_crossword(puzzle, words)\n    False\n    "
puzzle[row + i][col] = ''
puzzle[row][col + i] = ''
row
range(len(puzzle))
return True
col
range(len(puzzle[0]))
puzzle[row][col] Eq ''
word
words
return False
vertical
[True, False]
is_valid(puzzle, word, row, col, vertical)
place_word(puzzle, word, row, col, vertical)
words.remove(word)
solve_crossword(puzzle, words)
return True
__name__ Eq '__main__'
PUZZLE = [[''] * 3 for _ in range(3)]
WORDS = ['cat', 'dog', 'car']
solve_crossword(PUZZLE, WORDS)
print('Solution found:')
print('No solution found:')
row
PUZZLE
print(' '.join(row))