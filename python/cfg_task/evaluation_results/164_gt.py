def get_highest_set_bit_position(number: int) -> int:
    """
    Returns position of the highest set bit of a number.
    Ref - https://graphics.stanford.edu/~seander/bithacks.html#IntegerLogObvious
    >>> get_highest_set_bit_position(25)
    5
    >>> get_highest_set_bit_position(37)
    6
    >>> get_highest_set_bit_position(1)
    1
    >>> get_highest_set_bit_position(4)
    3
    >>> get_highest_set_bit_position(0)
    0
    >>> get_highest_set_bit_position(0.8)
    Traceback (most recent call last):
        ...
    TypeError: Input value must be an 'int' type
    """
    if not isinstance(number, int):
        raise TypeError("Input value must be an 'int' type")
    position = 0
    while number:
        position += 1
        number >>= 1
    return position
"\n    Returns position of the highest set bit of a number.\n    Ref - https://graphics.stanford.edu/~seander/bithacks.html#IntegerLogObvious\n    >>> get_highest_set_bit_position(25)\n    5\n    >>> get_highest_set_bit_position(37)\n    6\n    >>> get_highest_set_bit_position(1)\n    1\n    >>> get_highest_set_bit_position(4)\n    3\n    >>> get_highest_set_bit_position(0)\n    0\n    >>> get_highest_set_bit_position(0.8)\n    Traceback (most recent call last):\n        ...\n    TypeError: Input value must be an 'int' type\n    "
not isinstance(number, int)
raise TypeError("Input value must be an 'int' type")
position = 0
number
position += 1
number >>= 1
return position
__name__ Eq '__main__'
import doctest
doctest.testmod()