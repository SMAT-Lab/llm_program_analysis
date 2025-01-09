def excess_3_code(number: int) -> str:
    """
    Find excess-3 code of integer base 10.
    Add 3 to all digits in a decimal number then convert to a binary-coded decimal.
    https://en.wikipedia.org/wiki/Excess-3

    >>> excess_3_code(0)
    '0b0011'
    >>> excess_3_code(3)
    '0b0110'
    >>> excess_3_code(2)
    '0b0101'
    >>> excess_3_code(20)
    '0b01010011'
    >>> excess_3_code(120)
    '0b010001010011'
    """
    num = ''
    for digit in str(max(0, number)):
        num += str(bin(int(digit) + 3))[2:].zfill(4)
    return '0b' + num
"\n    Find excess-3 code of integer base 10.\n    Add 3 to all digits in a decimal number then convert to a binary-coded decimal.\n    https://en.wikipedia.org/wiki/Excess-3\n\n    >>> excess_3_code(0)\n    '0b0011'\n    >>> excess_3_code(3)\n    '0b0110'\n    >>> excess_3_code(2)\n    '0b0101'\n    >>> excess_3_code(20)\n    '0b01010011'\n    >>> excess_3_code(120)\n    '0b010001010011'\n    "
num = ''
digit
str(max(0, number))
num += str(bin(int(digit) + 3))[2:].zfill(4)
return '0b' + num
__name__ Eq '__main__'
import doctest
doctest.testmod()