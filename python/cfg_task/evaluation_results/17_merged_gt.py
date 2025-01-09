'\nAuthor  : Alexander Pantyukhin\nDate    : November 24, 2022\n\nTask:\nGiven an m x n grid of characters board and a string word,\nreturn true if word exists in the grid.\n\nThe word can be constructed from letters of sequentially adjacent cells,\nwhere adjacent cells are horizontally or vertically neighboring.\nThe same letter cell may not be used more than once.\n\nExample:\n\nMatrix:\n---------\n|A|B|C|E|\n|S|F|C|S|\n|A|D|E|E|\n---------\n\nWord:\n"ABCCED"\n\nResult:\nTrue\n\nImplementation notes: Use backtracking approach.\nAt each point, check all neighbors to try to find the next letter of the word.\n\nleetcode: https://leetcode.com/problems/word-search/\n\n'
def get_point_key(len_board: int, len_board_column: int, row: int, column: int) -> int:
    """
    Returns the hash key of matrix indexes.

    >>> get_point_key(10, 20, 1, 0)
    200
    """
    return len_board * len_board_column * row + column
'\n    Returns the hash key of matrix indexes.\n\n    >>> get_point_key(10, 20, 1, 0)\n    200\n    '
return len_board * len_board_column * row + column
def exits_word(board: list[list[str]], word: str, row: int, column: int, word_index: int, visited_points_set: set[int]) -> bool:
    """
    Return True if it's possible to search the word suffix
    starting from the word_index.

    >>> exits_word([["A"]], "B", 0, 0, 0, set())
    False
    """
    if board[row][column] != word[word_index]:
        return False
    if word_index == len(word) - 1:
        return True
    traverts_directions = [(0, 1), (0, -1), (-1, 0), (1, 0)]
    len_board = len(board)
    len_board_column = len(board[0])
    for direction in traverts_directions:
        next_i = row + direction[0]
        next_j = column + direction[1]
        if not (0 <= next_i < len_board and 0 <= next_j < len_board_column):
            continue
        key = get_point_key(len_board, len_board_column, next_i, next_j)
        if key in visited_points_set:
            continue
        visited_points_set.add(key)
        if exits_word(board, word, next_i, next_j, word_index + 1, visited_points_set):
            return True
        visited_points_set.remove(key)
    return False
'\n    Return True if it\'s possible to search the word suffix\n    starting from the word_index.\n\n    >>> exits_word([["A"]], "B", 0, 0, 0, set())\n    False\n    '
board[row][column] NotEq word[word_index]
return False
return True
direction
traverts_directions
next_i = row + direction[0]
next_j = column + direction[1]
not (0 <= next_i < len_board and 0 <= next_j < len_board_column)
return False
continue
key = get_point_key(len_board, len_board_column, next_i, next_j)
key In visited_points_set
continue
visited_points_set.add(key)
exits_word(board, word, next_i, next_j, word_index Add 1, visited_points_set)
return True
def word_exists(board: list[list[str]], word: str) -> bool:
    """
    >>> word_exists([["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], "ABCCED")
    True
    >>> word_exists([["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], "SEE")
    True
    >>> word_exists([["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], "ABCB")
    False
    >>> word_exists([["A"]], "A")
    True
    >>> word_exists([["B", "A", "A"], ["A", "A", "A"], ["A", "B", "A"]], "ABB")
    False
    >>> word_exists([["A"]], 123)
    Traceback (most recent call last):
        ...
    ValueError: The word parameter should be a string of length greater than 0.
    >>> word_exists([["A"]], "")
    Traceback (most recent call last):
        ...
    ValueError: The word parameter should be a string of length greater than 0.
    >>> word_exists([[]], "AB")
    Traceback (most recent call last):
        ...
    ValueError: The board should be a non empty matrix of single chars strings.
    >>> word_exists([], "AB")
    Traceback (most recent call last):
        ...
    ValueError: The board should be a non empty matrix of single chars strings.
    >>> word_exists([["A"], [21]], "AB")
    Traceback (most recent call last):
        ...
    ValueError: The board should be a non empty matrix of single chars strings.
    """
    board_error_message = 'The board should be a non empty matrix of single chars strings.'
    len_board = len(board)
    if not isinstance(board, list) or len(board) == 0:
        raise ValueError(board_error_message)
    for row in board:
        if not isinstance(row, list) or len(row) == 0:
            raise ValueError(board_error_message)
        for item in row:
            if not isinstance(item, str) or len(item) != 1:
                raise ValueError(board_error_message)
    if not isinstance(word, str) or len(word) == 0:
        raise ValueError('The word parameter should be a string of length greater than 0.')
    len_board_column = len(board[0])
    for i in range(len_board):
        for j in range(len_board_column):
            if exits_word(board, word, i, j, 0, {get_point_key(len_board, len_board_column, i, j)}):
                return True
    return False
'\n    >>> word_exists([["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], "ABCCED")\n    True\n    >>> word_exists([["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], "SEE")\n    True\n    >>> word_exists([["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], "ABCB")\n    False\n    >>> word_exists([["A"]], "A")\n    True\n    >>> word_exists([["B", "A", "A"], ["A", "A", "A"], ["A", "B", "A"]], "ABB")\n    False\n    >>> word_exists([["A"]], 123)\n    Traceback (most recent call last):\n        ...\n    ValueError: The word parameter should be a string of length greater than 0.\n    >>> word_exists([["A"]], "")\n    Traceback (most recent call last):\n        ...\n    ValueError: The word parameter should be a string of length greater than 0.\n    >>> word_exists([[]], "AB")\n    Traceback (most recent call last):\n        ...\n    ValueError: The board should be a non empty matrix of single chars strings.\n    >>> word_exists([], "AB")\n    Traceback (most recent call last):\n        ...\n    ValueError: The board should be a non empty matrix of single chars strings.\n    >>> word_exists([["A"], [21]], "AB")\n    Traceback (most recent call last):\n        ...\n    ValueError: The board should be a non empty matrix of single chars strings.\n    '
board_error_message = 'The board should be a non empty matrix of single chars strings.'
len_board = len(board)
not isinstance(board, list) or len(board) == 0
raise ValueError(board_error_message)
row
board
not isinstance(row, list) or len(row) == 0
not isinstance(word, str) or len(word) == 0
raise ValueError(board_error_message)
item
row
not isinstance(item, str) or len(item) != 1
raise ValueError(board_error_message)
raise ValueError('The word parameter should be a string of length greater than 0.')
len_board_column = len(board[0])
i
range(len_board)
return False
j
range(len_board_column)
exits_word(board, word, i, j, 0, {get_point_key(len_board, len_board_column, i, j)})
return True
__name__ Eq '__main__'
import doctest
doctest.testmod()