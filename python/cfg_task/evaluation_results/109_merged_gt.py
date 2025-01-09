def logical_left_shift(number: int, shift_amount: int) -> str:
    """
    Take in 2 positive integers.
    'number' is the integer to be logically left shifted 'shift_amount' times.
    i.e. (number << shift_amount)
    Return the shifted binary representation.

    >>> logical_left_shift(0, 1)
    '0b00'
    >>> logical_left_shift(1, 1)
    '0b10'
    >>> logical_left_shift(1, 5)
    '0b100000'
    >>> logical_left_shift(17, 2)
    '0b1000100'
    >>> logical_left_shift(1983, 4)
    '0b111101111110000'
    >>> logical_left_shift(1, -1)
    Traceback (most recent call last):
        ...
    ValueError: both inputs must be positive integers
    """
    if number < 0 or shift_amount < 0:
        raise ValueError('both inputs must be positive integers')
    binary_number = str(bin(number))
    binary_number += '0' * shift_amount
    return binary_number
"\n    Take in 2 positive integers.\n    'number' is the integer to be logically left shifted 'shift_amount' times.\n    i.e. (number << shift_amount)\n    Return the shifted binary representation.\n\n    >>> logical_left_shift(0, 1)\n    '0b00'\n    >>> logical_left_shift(1, 1)\n    '0b10'\n    >>> logical_left_shift(1, 5)\n    '0b100000'\n    >>> logical_left_shift(17, 2)\n    '0b1000100'\n    >>> logical_left_shift(1983, 4)\n    '0b111101111110000'\n    >>> logical_left_shift(1, -1)\n    Traceback (most recent call last):\n        ...\n    ValueError: both inputs must be positive integers\n    "
number < 0 or shift_amount < 0
def logical_right_shift(number: int, shift_amount: int) -> str:
    """
    Take in positive 2 integers.
    'number' is the integer to be logically right shifted 'shift_amount' times.
    i.e. (number >>> shift_amount)
    Return the shifted binary representation.

    >>> logical_right_shift(0, 1)
    '0b0'
    >>> logical_right_shift(1, 1)
    '0b0'
    >>> logical_right_shift(1, 5)
    '0b0'
    >>> logical_right_shift(17, 2)
    '0b100'
    >>> logical_right_shift(1983, 4)
    '0b1111011'
    >>> logical_right_shift(1, -1)
    Traceback (most recent call last):
        ...
    ValueError: both inputs must be positive integers
    """
    if number < 0 or shift_amount < 0:
        raise ValueError('both inputs must be positive integers')
    binary_number = str(bin(number))[2:]
    if shift_amount >= len(binary_number):
        return '0b0'
    shifted_binary_number = binary_number[:len(binary_number) - shift_amount]
    return '0b' + shifted_binary_number
"\n    Take in positive 2 integers.\n    'number' is the integer to be logically right shifted 'shift_amount' times.\n    i.e. (number >>> shift_amount)\n    Return the shifted binary representation.\n\n    >>> logical_right_shift(0, 1)\n    '0b0'\n    >>> logical_right_shift(1, 1)\n    '0b0'\n    >>> logical_right_shift(1, 5)\n    '0b0'\n    >>> logical_right_shift(17, 2)\n    '0b100'\n    >>> logical_right_shift(1983, 4)\n    '0b1111011'\n    >>> logical_right_shift(1, -1)\n    Traceback (most recent call last):\n        ...\n    ValueError: both inputs must be positive integers\n    "
number < 0 or shift_amount < 0
def arithmetic_right_shift(number: int, shift_amount: int) -> str:
    """
    Take in 2 integers.
    'number' is the integer to be arithmetically right shifted 'shift_amount' times.
    i.e. (number >> shift_amount)
    Return the shifted binary representation.

    >>> arithmetic_right_shift(0, 1)
    '0b00'
    >>> arithmetic_right_shift(1, 1)
    '0b00'
    >>> arithmetic_right_shift(-1, 1)
    '0b11'
    >>> arithmetic_right_shift(17, 2)
    '0b000100'
    >>> arithmetic_right_shift(-17, 2)
    '0b111011'
    >>> arithmetic_right_shift(-1983, 4)
    '0b111110000100'
    """
    if number >= 0:
        binary_number = '0' + str(bin(number)).strip('-')[2:]
    else:
        binary_number_length = len(bin(number)[3:])
        binary_number = bin(abs(number) - (1 << binary_number_length))[3:]
        binary_number = '1' + '0' * (binary_number_length - len(binary_number)) + binary_number
    if shift_amount >= len(binary_number):
        return '0b' + binary_number[0] * len(binary_number)
    return '0b' + binary_number[0] * shift_amount + binary_number[:len(binary_number) - shift_amount]
"\n    Take in 2 integers.\n    'number' is the integer to be arithmetically right shifted 'shift_amount' times.\n    i.e. (number >> shift_amount)\n    Return the shifted binary representation.\n\n    >>> arithmetic_right_shift(0, 1)\n    '0b00'\n    >>> arithmetic_right_shift(1, 1)\n    '0b00'\n    >>> arithmetic_right_shift(-1, 1)\n    '0b11'\n    >>> arithmetic_right_shift(17, 2)\n    '0b000100'\n    >>> arithmetic_right_shift(-17, 2)\n    '0b111011'\n    >>> arithmetic_right_shift(-1983, 4)\n    '0b111110000100'\n    "
number GtE 0
__name__ Eq '__main__'
raise ValueError('both inputs must be positive integers')
raise ValueError('both inputs must be positive integers')
binary_number = '0' + str(bin(number)).strip('-')[2:]
binary_number_length = len(bin(number)[3:])
binary_number = bin(abs(number) - (1 << binary_number_length))[3:]
binary_number = '1' + '0' * (binary_number_length - len(binary_number)) + binary_number
import doctest
doctest.testmod()
binary_number = str(bin(number))
binary_number += '0' * shift_amount
return binary_number
binary_number = str(bin(number))[2:]
shift_amount GtE len(binary_number)
shift_amount GtE len(binary_number)
return '0b0'
return '0b' + binary_number[0] * len(binary_number)