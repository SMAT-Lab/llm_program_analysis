def gray_code(bit_count: int) -> list:
    """
    Takes in an integer n and returns a n-bit
    gray code sequence
    An n-bit gray code sequence is a sequence of 2^n
    integers where:

    a) Every integer is between [0,2^n -1] inclusive
    b) The sequence begins with 0
    c) An integer appears at most one times in the sequence
    d)The binary representation of every pair of integers differ
       by exactly one bit
    e) The binary representation of first and last bit also
       differ by exactly one bit

    >>> gray_code(2)
    [0, 1, 3, 2]

    >>> gray_code(1)
    [0, 1]

    >>> gray_code(3)
    [0, 1, 3, 2, 6, 7, 5, 4]

    >>> gray_code(-1)
    Traceback (most recent call last):
        ...
    ValueError: The given input must be positive

    >>> gray_code(10.6)
    Traceback (most recent call last):
        ...
    TypeError: unsupported operand type(s) for <<: 'int' and 'float'
    """
    if bit_count < 0:
        raise ValueError('The given input must be positive')
    sequence = gray_code_sequence_string(bit_count)
    for i in range(len(sequence)):
        sequence[i] = int(sequence[i], 2)
    return sequence
"\n    Takes in an integer n and returns a n-bit\n    gray code sequence\n    An n-bit gray code sequence is a sequence of 2^n\n    integers where:\n\n    a) Every integer is between [0,2^n -1] inclusive\n    b) The sequence begins with 0\n    c) An integer appears at most one times in the sequence\n    d)The binary representation of every pair of integers differ\n       by exactly one bit\n    e) The binary representation of first and last bit also\n       differ by exactly one bit\n\n    >>> gray_code(2)\n    [0, 1, 3, 2]\n\n    >>> gray_code(1)\n    [0, 1]\n\n    >>> gray_code(3)\n    [0, 1, 3, 2, 6, 7, 5, 4]\n\n    >>> gray_code(-1)\n    Traceback (most recent call last):\n        ...\n    ValueError: The given input must be positive\n\n    >>> gray_code(10.6)\n    Traceback (most recent call last):\n        ...\n    TypeError: unsupported operand type(s) for <<: 'int' and 'float'\n    "
bit_count Lt 0
raise ValueError('The given input must be positive')
sequence = gray_code_sequence_string(bit_count)
i
range(len(sequence))
sequence[i] = int(sequence[i], 2)
return sequence
def gray_code_sequence_string(bit_count: int) -> list:
    """
    Will output the n-bit grey sequence as a
    string of bits

    >>> gray_code_sequence_string(2)
    ['00', '01', '11', '10']

    >>> gray_code_sequence_string(1)
    ['0', '1']
    """
    if bit_count == 0:
        return ['0']
    if bit_count == 1:
        return ['0', '1']
    seq_len = 1 << bit_count
    smaller_sequence = gray_code_sequence_string(bit_count - 1)
    sequence = []
    for i in range(seq_len // 2):
        generated_no = '0' + smaller_sequence[i]
        sequence.append(generated_no)
    for i in reversed(range(seq_len // 2)):
        generated_no = '1' + smaller_sequence[i]
        sequence.append(generated_no)
    return sequence
"\n    Will output the n-bit grey sequence as a\n    string of bits\n\n    >>> gray_code_sequence_string(2)\n    ['00', '01', '11', '10']\n\n    >>> gray_code_sequence_string(1)\n    ['0', '1']\n    "
bit_count Eq 0
return ['0']
return ['0', '1']
i
range(seq_len FloorDiv 2)
generated_no = '0' + smaller_sequence[i]
sequence.append(generated_no)
i
reversed(range(seq_len FloorDiv 2))
generated_no = '1' + smaller_sequence[i]
sequence.append(generated_no)
return sequence
__name__ Eq '__main__'
import doctest
doctest.testmod()