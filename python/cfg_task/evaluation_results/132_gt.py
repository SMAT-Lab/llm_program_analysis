def get_1s_count(number: int) -> int:
    """
    Count the number of set bits in a 32 bit integer using Brian Kernighan's way.
    Ref - https://graphics.stanford.edu/~seander/bithacks.html#CountBitsSetKernighan
    >>> get_1s_count(25)
    3
    >>> get_1s_count(37)
    3
    >>> get_1s_count(21)
    3
    >>> get_1s_count(58)
    4
    >>> get_1s_count(0)
    0
    >>> get_1s_count(256)
    1
    >>> get_1s_count(-1)
    Traceback (most recent call last):
        ...
    ValueError: Input must be a non-negative integer
    >>> get_1s_count(0.8)
    Traceback (most recent call last):
        ...
    ValueError: Input must be a non-negative integer
    >>> get_1s_count("25")
    Traceback (most recent call last):
        ...
    ValueError: Input must be a non-negative integer
    """
    if not isinstance(number, int) or number < 0:
        raise ValueError('Input must be a non-negative integer')
    count = 0
    while number:
        number &= number - 1
        count += 1
    return count
'\n    Count the number of set bits in a 32 bit integer using Brian Kernighan\'s way.\n    Ref - https://graphics.stanford.edu/~seander/bithacks.html#CountBitsSetKernighan\n    >>> get_1s_count(25)\n    3\n    >>> get_1s_count(37)\n    3\n    >>> get_1s_count(21)\n    3\n    >>> get_1s_count(58)\n    4\n    >>> get_1s_count(0)\n    0\n    >>> get_1s_count(256)\n    1\n    >>> get_1s_count(-1)\n    Traceback (most recent call last):\n        ...\n    ValueError: Input must be a non-negative integer\n    >>> get_1s_count(0.8)\n    Traceback (most recent call last):\n        ...\n    ValueError: Input must be a non-negative integer\n    >>> get_1s_count("25")\n    Traceback (most recent call last):\n        ...\n    ValueError: Input must be a non-negative integer\n    '
not isinstance(number, int) or number < 0
raise ValueError('Input must be a non-negative integer')
count = 0
number
number &= number - 1
count += 1
return count
__name__ Eq '__main__'
import doctest
doctest.testmod()