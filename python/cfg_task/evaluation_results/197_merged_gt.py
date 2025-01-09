def binary_or(a: int, b: int) -> str:
    """
    Take in 2 integers, convert them to binary, and return a binary number that is the
    result of a binary or operation on the integers provided.

    >>> binary_or(25, 32)
    '0b111001'
    >>> binary_or(37, 50)
    '0b110111'
    >>> binary_or(21, 30)
    '0b11111'
    >>> binary_or(58, 73)
    '0b1111011'
    >>> binary_or(0, 255)
    '0b11111111'
    >>> binary_or(0, 256)
    '0b100000000'
    >>> binary_or(0, -1)
    Traceback (most recent call last):
        ...
    ValueError: the value of both inputs must be positive
    >>> binary_or(0, 1.1)
    Traceback (most recent call last):
        ...
    TypeError: 'float' object cannot be interpreted as an integer
    >>> binary_or("0", "1")
    Traceback (most recent call last):
        ...
    TypeError: '<' not supported between instances of 'str' and 'int'
    """
    if a < 0 or b < 0:
        raise ValueError('the value of both inputs must be positive')
    a_binary = str(bin(a))[2:]
    b_binary = str(bin(b))[2:]
    max_len = max(len(a_binary), len(b_binary))
    return '0b' + ''.join((str(int('1' in (char_a, char_b))) for (char_a, char_b) in zip(a_binary.zfill(max_len), b_binary.zfill(max_len))))
'\n    Take in 2 integers, convert them to binary, and return a binary number that is the\n    result of a binary or operation on the integers provided.\n\n    >>> binary_or(25, 32)\n    \'0b111001\'\n    >>> binary_or(37, 50)\n    \'0b110111\'\n    >>> binary_or(21, 30)\n    \'0b11111\'\n    >>> binary_or(58, 73)\n    \'0b1111011\'\n    >>> binary_or(0, 255)\n    \'0b11111111\'\n    >>> binary_or(0, 256)\n    \'0b100000000\'\n    >>> binary_or(0, -1)\n    Traceback (most recent call last):\n        ...\n    ValueError: the value of both inputs must be positive\n    >>> binary_or(0, 1.1)\n    Traceback (most recent call last):\n        ...\n    TypeError: \'float\' object cannot be interpreted as an integer\n    >>> binary_or("0", "1")\n    Traceback (most recent call last):\n        ...\n    TypeError: \'<\' not supported between instances of \'str\' and \'int\'\n    '
a < 0 or b < 0
__name__ Eq '__main__'
raise ValueError('the value of both inputs must be positive')
import doctest
doctest.testmod()
a_binary = str(bin(a))[2:]
b_binary = str(bin(b))[2:]
max_len = max(len(a_binary), len(b_binary))
return '0b' + ''.join((str(int('1' in (char_a, char_b))) for (char_a, char_b) in zip(a_binary.zfill(max_len), b_binary.zfill(max_len))))