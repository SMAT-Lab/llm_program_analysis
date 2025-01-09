def twos_complement(number: int) -> str:
    """
    Take in a negative integer 'number'.
    Return the two's complement representation of 'number'.

    >>> twos_complement(0)
    '0b0'
    >>> twos_complement(-1)
    '0b11'
    >>> twos_complement(-5)
    '0b1011'
    >>> twos_complement(-17)
    '0b101111'
    >>> twos_complement(-207)
    '0b100110001'
    >>> twos_complement(1)
    Traceback (most recent call last):
        ...
    ValueError: input must be a negative integer
    """
    if number > 0:
        raise ValueError('input must be a negative integer')
    binary_number_length = len(bin(number)[3:])
    twos_complement_number = bin(abs(number) - (1 << binary_number_length))[3:]
    twos_complement_number = '1' + '0' * (binary_number_length - len(twos_complement_number)) + twos_complement_number if number < 0 else '0'
    return '0b' + twos_complement_number
"\n    Take in a negative integer 'number'.\n    Return the two's complement representation of 'number'.\n\n    >>> twos_complement(0)\n    '0b0'\n    >>> twos_complement(-1)\n    '0b11'\n    >>> twos_complement(-5)\n    '0b1011'\n    >>> twos_complement(-17)\n    '0b101111'\n    >>> twos_complement(-207)\n    '0b100110001'\n    >>> twos_complement(1)\n    Traceback (most recent call last):\n        ...\n    ValueError: input must be a negative integer\n    "
number Gt 0
__name__ Eq '__main__'
raise ValueError('input must be a negative integer')
import doctest
doctest.testmod()
binary_number_length = len(bin(number)[3:])
twos_complement_number = bin(abs(number) - (1 << binary_number_length))[3:]
twos_complement_number = '1' + '0' * (binary_number_length - len(twos_complement_number)) + twos_complement_number if number < 0 else '0'
return '0b' + twos_complement_number