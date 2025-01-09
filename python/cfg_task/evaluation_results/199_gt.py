def get_index_of_rightmost_set_bit(number: int) -> int:
    """
    Take in a positive integer 'number'.
    Returns the zero-based index of first set bit in that 'number' from right.
    Returns -1, If no set bit found.

    >>> get_index_of_rightmost_set_bit(0)
    -1
    >>> get_index_of_rightmost_set_bit(5)
    0
    >>> get_index_of_rightmost_set_bit(36)
    2
    >>> get_index_of_rightmost_set_bit(8)
    3
    >>> get_index_of_rightmost_set_bit(-18)
    Traceback (most recent call last):
        ...
    ValueError: Input must be a non-negative integer
    >>> get_index_of_rightmost_set_bit('test')
    Traceback (most recent call last):
        ...
    ValueError: Input must be a non-negative integer
    >>> get_index_of_rightmost_set_bit(1.25)
    Traceback (most recent call last):
        ...
    ValueError: Input must be a non-negative integer
    """
    if not isinstance(number, int) or number < 0:
        raise ValueError('Input must be a non-negative integer')
    intermediate = number & ~(number - 1)
    index = 0
    while intermediate:
        intermediate >>= 1
        index += 1
    return index - 1
"\n    Take in a positive integer 'number'.\n    Returns the zero-based index of first set bit in that 'number' from right.\n    Returns -1, If no set bit found.\n\n    >>> get_index_of_rightmost_set_bit(0)\n    -1\n    >>> get_index_of_rightmost_set_bit(5)\n    0\n    >>> get_index_of_rightmost_set_bit(36)\n    2\n    >>> get_index_of_rightmost_set_bit(8)\n    3\n    >>> get_index_of_rightmost_set_bit(-18)\n    Traceback (most recent call last):\n        ...\n    ValueError: Input must be a non-negative integer\n    >>> get_index_of_rightmost_set_bit('test')\n    Traceback (most recent call last):\n        ...\n    ValueError: Input must be a non-negative integer\n    >>> get_index_of_rightmost_set_bit(1.25)\n    Traceback (most recent call last):\n        ...\n    ValueError: Input must be a non-negative integer\n    "
not isinstance(number, int) or number < 0
raise ValueError('Input must be a non-negative integer')
intermediate = number & ~(number - 1)
index = 0
intermediate
intermediate >>= 1
index += 1
return index - 1
__name__ Eq '__main__'
'\n    Finding the index of rightmost set bit has some very peculiar use-cases,\n    especially in finding missing or/and repeating numbers in a list of\n    positive integers.\n    '
import doctest
doctest.testmod()