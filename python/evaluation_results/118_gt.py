'\nauthor: Aayush Soni\nGiven n pairs of parentheses, write a function to generate all\ncombinations of well-formed parentheses.\nInput: n = 2\nOutput: ["(())","()()"]\nLeetcode link: https://leetcode.com/problems/generate-parentheses/description/\n'
def backtrack(partial: str, open_count: int, close_count: int, n: int, result: list[str]) -> None:
    """
    Generate valid combinations of balanced parentheses using recursion.

    :param partial: A string representing the current combination.
    :param open_count: An integer representing the count of open parentheses.
    :param close_count: An integer representing the count of close parentheses.
    :param n: An integer representing the total number of pairs.
    :param result: A list to store valid combinations.
    :return: None

    This function uses recursion to explore all possible combinations,
    ensuring that at each step, the parentheses remain balanced.

    Example:
    >>> result = []
    >>> backtrack("", 0, 0, 2, result)
    >>> result
    ['(())', '()()']
    """
    if len(partial) == 2 * n:
        result.append(partial)
        return
    if open_count < n:
        backtrack(partial + '(', open_count + 1, close_count, n, result)
    if close_count < open_count:
        backtrack(partial + ')', open_count, close_count + 1, n, result)
'\n    Generate valid combinations of balanced parentheses using recursion.\n\n    :param partial: A string representing the current combination.\n    :param open_count: An integer representing the count of open parentheses.\n    :param close_count: An integer representing the count of close parentheses.\n    :param n: An integer representing the total number of pairs.\n    :param result: A list to store valid combinations.\n    :return: None\n\n    This function uses recursion to explore all possible combinations,\n    ensuring that at each step, the parentheses remain balanced.\n\n    Example:\n    >>> result = []\n    >>> backtrack("", 0, 0, 2, result)\n    >>> result\n    [\'(())\', \'()()\']\n    '
len(partial) Eq 2 Mult n
__name__ Eq '__main__'
result.append(partial)
return
import doctest
doctest.testmod()
backtrack(partial Add '(', open_count Add 1, close_count, n, result)
close_count Lt open_count
backtrack(partial Add ')', open_count, close_count Add 1, n, result)
def generate_parenthesis(n: int) -> list[str]:
    """
    Generate valid combinations of balanced parentheses for a given n.

    :param n: An integer representing the number of pairs of parentheses.
    :return: A list of strings with valid combinations.

    This function uses a recursive approach to generate the combinations.

    Time Complexity: O(2^(2n)) - In the worst case, we have 2^(2n) combinations.
    Space Complexity: O(n) - where 'n' is the number of pairs.

    Example 1:
    >>> generate_parenthesis(3)
    ['((()))', '(()())', '(())()', '()(())', '()()()']

    Example 2:
    >>> generate_parenthesis(1)
    ['()']
    """
    result: list[str] = []
    backtrack('', 0, 0, n, result)
    return result
"\n    Generate valid combinations of balanced parentheses for a given n.\n\n    :param n: An integer representing the number of pairs of parentheses.\n    :return: A list of strings with valid combinations.\n\n    This function uses a recursive approach to generate the combinations.\n\n    Time Complexity: O(2^(2n)) - In the worst case, we have 2^(2n) combinations.\n    Space Complexity: O(n) - where 'n' is the number of pairs.\n\n    Example 1:\n    >>> generate_parenthesis(3)\n    ['((()))', '(()())', '(())()', '()(())', '()()()']\n\n    Example 2:\n    >>> generate_parenthesis(1)\n    ['()']\n    "
result: list[str] = []
backtrack('', 0, 0, n, result)
return result