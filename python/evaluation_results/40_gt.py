'\nWord Break Problem is a well-known problem in computer science.\nGiven a string and a dictionary of words, the task is to determine if\nthe string can be segmented into a sequence of one or more dictionary words.\n\nWikipedia: https://en.wikipedia.org/wiki/Word_break_problem\n'
def backtrack(input_string: str, word_dict: set[str], start: int) -> bool:
    """
    Helper function that uses backtracking to determine if a valid
    word segmentation is possible starting from index 'start'.

    Parameters:
    input_string (str): The input string to be segmented.
    word_dict (set[str]): A set of valid dictionary words.
    start (int): The starting index of the substring to be checked.

    Returns:
    bool: True if a valid segmentation is possible, otherwise False.

    Example:
    >>> backtrack("leetcode", {"leet", "code"}, 0)
    True

    >>> backtrack("applepenapple", {"apple", "pen"}, 0)
    True

    >>> backtrack("catsandog", {"cats", "dog", "sand", "and", "cat"}, 0)
    False
    """
    if start == len(input_string):
        return True
    for end in range(start + 1, len(input_string) + 1):
        if input_string[start:end] in word_dict and backtrack(input_string, word_dict, end):
            return True
    return False
'\n    Helper function that uses backtracking to determine if a valid\n    word segmentation is possible starting from index \'start\'.\n\n    Parameters:\n    input_string (str): The input string to be segmented.\n    word_dict (set[str]): A set of valid dictionary words.\n    start (int): The starting index of the substring to be checked.\n\n    Returns:\n    bool: True if a valid segmentation is possible, otherwise False.\n\n    Example:\n    >>> backtrack("leetcode", {"leet", "code"}, 0)\n    True\n\n    >>> backtrack("applepenapple", {"apple", "pen"}, 0)\n    True\n\n    >>> backtrack("catsandog", {"cats", "dog", "sand", "and", "cat"}, 0)\n    False\n    '
start Eq len(input_string)
return True
end
range(start Add 1, len(input_string) Add 1)
input_string[start:end] in word_dict and backtrack(input_string, word_dict, end)
return False
return True
def word_break(input_string: str, word_dict: set[str]) -> bool:
    """
    Determines if the input string can be segmented into a sequence of
    valid dictionary words using backtracking.

    Parameters:
    input_string (str): The input string to segment.
    word_dict (set[str]): The set of valid words.

    Returns:
    bool: True if the string can be segmented into valid words, otherwise False.

    Example:
    >>> word_break("leetcode", {"leet", "code"})
    True

    >>> word_break("applepenapple", {"apple", "pen"})
    True

    >>> word_break("catsandog", {"cats", "dog", "sand", "and", "cat"})
    False
    """
    return backtrack(input_string, word_dict, 0)
'\n    Determines if the input string can be segmented into a sequence of\n    valid dictionary words using backtracking.\n\n    Parameters:\n    input_string (str): The input string to segment.\n    word_dict (set[str]): The set of valid words.\n\n    Returns:\n    bool: True if the string can be segmented into valid words, otherwise False.\n\n    Example:\n    >>> word_break("leetcode", {"leet", "code"})\n    True\n\n    >>> word_break("applepenapple", {"apple", "pen"})\n    True\n\n    >>> word_break("catsandog", {"cats", "dog", "sand", "and", "cat"})\n    False\n    '
return backtrack(input_string, word_dict, 0)