'\nWord Ladder is a classic problem in computer science.\nThe problem is to transform a start word into an end word\nby changing one letter at a time.\nEach intermediate word must be a valid word from a given list of words.\nThe goal is to find a transformation sequence\nfrom the start word to the end word.\n\nWikipedia: https://en.wikipedia.org/wiki/Word_ladder\n'
import string
def backtrack(current_word: str, path: list[str], end_word: str, word_set: set[str]) -> list[str]:
    """
    Helper function to perform backtracking to find the transformation
    from the current_word to the end_word.

    Parameters:
    current_word (str): The current word in the transformation sequence.
    path (list[str]): The list of transformations from begin_word to current_word.
    end_word (str): The target word for transformation.
    word_set (set[str]): The set of valid words for transformation.

    Returns:
    list[str]: The list of transformations from begin_word to end_word.
               Returns an empty list if there is no valid
                transformation from current_word to end_word.

    Example:
    >>> backtrack("hit", ["hit"], "cog", {"hot", "dot", "dog", "lot", "log", "cog"})
    ['hit', 'hot', 'dot', 'lot', 'log', 'cog']

    >>> backtrack("hit", ["hit"], "cog", {"hot", "dot", "dog", "lot", "log"})
    []

    >>> backtrack("lead", ["lead"], "gold", {"load", "goad", "gold", "lead", "lord"})
    ['lead', 'lead', 'load', 'goad', 'gold']

    >>> backtrack("game", ["game"], "code", {"came", "cage", "code", "cade", "gave"})
    ['game', 'came', 'cade', 'code']
    """
    if current_word == end_word:
        return path
    for i in range(len(current_word)):
        for c in string.ascii_lowercase:
            transformed_word = current_word[:i] + c + current_word[i + 1:]
            if transformed_word in word_set:
                word_set.remove(transformed_word)
                result = backtrack(transformed_word, [*path, transformed_word], end_word, word_set)
                if result:
                    return result
                word_set.add(transformed_word)
    return []
'\n    Helper function to perform backtracking to find the transformation\n    from the current_word to the end_word.\n\n    Parameters:\n    current_word (str): The current word in the transformation sequence.\n    path (list[str]): The list of transformations from begin_word to current_word.\n    end_word (str): The target word for transformation.\n    word_set (set[str]): The set of valid words for transformation.\n\n    Returns:\n    list[str]: The list of transformations from begin_word to end_word.\n               Returns an empty list if there is no valid\n                transformation from current_word to end_word.\n\n    Example:\n    >>> backtrack("hit", ["hit"], "cog", {"hot", "dot", "dog", "lot", "log", "cog"})\n    [\'hit\', \'hot\', \'dot\', \'lot\', \'log\', \'cog\']\n\n    >>> backtrack("hit", ["hit"], "cog", {"hot", "dot", "dog", "lot", "log"})\n    []\n\n    >>> backtrack("lead", ["lead"], "gold", {"load", "goad", "gold", "lead", "lord"})\n    [\'lead\', \'lead\', \'load\', \'goad\', \'gold\']\n\n    >>> backtrack("game", ["game"], "code", {"came", "cage", "code", "cade", "gave"})\n    [\'game\', \'came\', \'cade\', \'code\']\n    '
current_word Eq end_word
return path
i
range(len(current_word))
return []
c
string.ascii_lowercase
transformed_word = current_word[:i] + c + current_word[i + 1:]
transformed_word In word_set
word_set.remove(transformed_word)
result = backtrack(transformed_word, [*path, transformed_word], end_word, word_set)
result
return result
def word_ladder(begin_word: str, end_word: str, word_set: set[str]) -> list[str]:
    """
    Solve the Word Ladder problem using Backtracking and return
    the list of transformations from begin_word to end_word.

    Parameters:
    begin_word (str): The word from which the transformation starts.
    end_word (str): The target word for transformation.
    word_list (list[str]): The list of valid words for transformation.

    Returns:
    list[str]: The list of transformations from begin_word to end_word.
               Returns an empty list if there is no valid transformation.

    Example:
    >>> word_ladder("hit", "cog", ["hot", "dot", "dog", "lot", "log", "cog"])
    ['hit', 'hot', 'dot', 'lot', 'log', 'cog']

    >>> word_ladder("hit", "cog", ["hot", "dot", "dog", "lot", "log"])
    []

    >>> word_ladder("lead", "gold", ["load", "goad", "gold", "lead", "lord"])
    ['lead', 'lead', 'load', 'goad', 'gold']

    >>> word_ladder("game", "code", ["came", "cage", "code", "cade", "gave"])
    ['game', 'came', 'cade', 'code']
    """
    if end_word not in word_set:
        return []
    return backtrack(begin_word, [begin_word], end_word, word_set)
'\n    Solve the Word Ladder problem using Backtracking and return\n    the list of transformations from begin_word to end_word.\n\n    Parameters:\n    begin_word (str): The word from which the transformation starts.\n    end_word (str): The target word for transformation.\n    word_list (list[str]): The list of valid words for transformation.\n\n    Returns:\n    list[str]: The list of transformations from begin_word to end_word.\n               Returns an empty list if there is no valid transformation.\n\n    Example:\n    >>> word_ladder("hit", "cog", ["hot", "dot", "dog", "lot", "log", "cog"])\n    [\'hit\', \'hot\', \'dot\', \'lot\', \'log\', \'cog\']\n\n    >>> word_ladder("hit", "cog", ["hot", "dot", "dog", "lot", "log"])\n    []\n\n    >>> word_ladder("lead", "gold", ["load", "goad", "gold", "lead", "lord"])\n    [\'lead\', \'lead\', \'load\', \'goad\', \'gold\']\n\n    >>> word_ladder("game", "code", ["came", "cage", "code", "cade", "gave"])\n    [\'game\', \'came\', \'cade\', \'code\']\n    '
end_word NotIn word_set
return []