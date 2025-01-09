'\nCalculates the sum of two non-negative integers using bitwise operators\nWikipedia explanation: https://en.wikipedia.org/wiki/Binary_number\n'
def bitwise_addition_recursive(number: int, other_number: int) -> int:
    """
    >>> bitwise_addition_recursive(4, 5)
    9
    >>> bitwise_addition_recursive(8, 9)
    17
    >>> bitwise_addition_recursive(0, 4)
    4
    >>> bitwise_addition_recursive(4.5, 9)
    Traceback (most recent call last):
        ...
    TypeError: Both arguments MUST be integers!
    >>> bitwise_addition_recursive('4', 9)
    Traceback (most recent call last):
        ...
    TypeError: Both arguments MUST be integers!
    >>> bitwise_addition_recursive('4.5', 9)
    Traceback (most recent call last):
        ...
    TypeError: Both arguments MUST be integers!
    >>> bitwise_addition_recursive(-1, 9)
    Traceback (most recent call last):
        ...
    ValueError: Both arguments MUST be non-negative!
    >>> bitwise_addition_recursive(1, -9)
    Traceback (most recent call last):
        ...
    ValueError: Both arguments MUST be non-negative!
    """
    if not isinstance(number, int) or not isinstance(other_number, int):
        raise TypeError('Both arguments MUST be integers!')
    if number < 0 or other_number < 0:
        raise ValueError('Both arguments MUST be non-negative!')
    bitwise_sum = number ^ other_number
    carry = number & other_number
    if carry == 0:
        return bitwise_sum
    return bitwise_addition_recursive(bitwise_sum, carry << 1)
"\n    >>> bitwise_addition_recursive(4, 5)\n    9\n    >>> bitwise_addition_recursive(8, 9)\n    17\n    >>> bitwise_addition_recursive(0, 4)\n    4\n    >>> bitwise_addition_recursive(4.5, 9)\n    Traceback (most recent call last):\n        ...\n    TypeError: Both arguments MUST be integers!\n    >>> bitwise_addition_recursive('4', 9)\n    Traceback (most recent call last):\n        ...\n    TypeError: Both arguments MUST be integers!\n    >>> bitwise_addition_recursive('4.5', 9)\n    Traceback (most recent call last):\n        ...\n    TypeError: Both arguments MUST be integers!\n    >>> bitwise_addition_recursive(-1, 9)\n    Traceback (most recent call last):\n        ...\n    ValueError: Both arguments MUST be non-negative!\n    >>> bitwise_addition_recursive(1, -9)\n    Traceback (most recent call last):\n        ...\n    ValueError: Both arguments MUST be non-negative!\n    "
not isinstance(number, int) or not isinstance(other_number, int)
__name__ Eq '__main__'
raise TypeError('Both arguments MUST be integers!')
import doctest
doctest.testmod()
number < 0 or other_number < 0
raise ValueError('Both arguments MUST be non-negative!')
bitwise_sum = number ^ other_number
carry = number & other_number
carry Eq 0
return bitwise_sum