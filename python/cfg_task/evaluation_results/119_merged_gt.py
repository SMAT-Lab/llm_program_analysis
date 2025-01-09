from timeit import timeit
def get_set_bits_count_using_brian_kernighans_algorithm(number: int) -> int:
    """
    Count the number of set bits in a 32 bit integer
    >>> get_set_bits_count_using_brian_kernighans_algorithm(25)
    3
    >>> get_set_bits_count_using_brian_kernighans_algorithm(37)
    3
    >>> get_set_bits_count_using_brian_kernighans_algorithm(21)
    3
    >>> get_set_bits_count_using_brian_kernighans_algorithm(58)
    4
    >>> get_set_bits_count_using_brian_kernighans_algorithm(0)
    0
    >>> get_set_bits_count_using_brian_kernighans_algorithm(256)
    1
    >>> get_set_bits_count_using_brian_kernighans_algorithm(-1)
    Traceback (most recent call last):
        ...
    ValueError: the value of input must not be negative
    """
    if number < 0:
        raise ValueError('the value of input must not be negative')
    result = 0
    while number:
        number &= number - 1
        result += 1
    return result
'\n    Count the number of set bits in a 32 bit integer\n    >>> get_set_bits_count_using_brian_kernighans_algorithm(25)\n    3\n    >>> get_set_bits_count_using_brian_kernighans_algorithm(37)\n    3\n    >>> get_set_bits_count_using_brian_kernighans_algorithm(21)\n    3\n    >>> get_set_bits_count_using_brian_kernighans_algorithm(58)\n    4\n    >>> get_set_bits_count_using_brian_kernighans_algorithm(0)\n    0\n    >>> get_set_bits_count_using_brian_kernighans_algorithm(256)\n    1\n    >>> get_set_bits_count_using_brian_kernighans_algorithm(-1)\n    Traceback (most recent call last):\n        ...\n    ValueError: the value of input must not be negative\n    '
number Lt 0
raise ValueError('the value of input must not be negative')
result = 0
number
number &= number - 1
result += 1
return result
def get_set_bits_count_using_modulo_operator(number: int) -> int:
    """
    Count the number of set bits in a 32 bit integer
    >>> get_set_bits_count_using_modulo_operator(25)
    3
    >>> get_set_bits_count_using_modulo_operator(37)
    3
    >>> get_set_bits_count_using_modulo_operator(21)
    3
    >>> get_set_bits_count_using_modulo_operator(58)
    4
    >>> get_set_bits_count_using_modulo_operator(0)
    0
    >>> get_set_bits_count_using_modulo_operator(256)
    1
    >>> get_set_bits_count_using_modulo_operator(-1)
    Traceback (most recent call last):
        ...
    ValueError: the value of input must not be negative
    """
    if number < 0:
        raise ValueError('the value of input must not be negative')
    result = 0
    while number:
        if number % 2 == 1:
            result += 1
        number >>= 1
    return result
'\n    Count the number of set bits in a 32 bit integer\n    >>> get_set_bits_count_using_modulo_operator(25)\n    3\n    >>> get_set_bits_count_using_modulo_operator(37)\n    3\n    >>> get_set_bits_count_using_modulo_operator(21)\n    3\n    >>> get_set_bits_count_using_modulo_operator(58)\n    4\n    >>> get_set_bits_count_using_modulo_operator(0)\n    0\n    >>> get_set_bits_count_using_modulo_operator(256)\n    1\n    >>> get_set_bits_count_using_modulo_operator(-1)\n    Traceback (most recent call last):\n        ...\n    ValueError: the value of input must not be negative\n    '
number Lt 0
raise ValueError('the value of input must not be negative')
result = 0
number
number Mod 2 Eq 1
return result
result += 1
number >>= 1
def benchmark() -> None:
    """
    Benchmark code for comparing 2 functions, with different length int values.
    Brian Kernighan's algorithm is consistently faster than using modulo_operator.
    """

    def do_benchmark(number: int) -> None:
        setup = 'import __main__ as z'
        print(f'Benchmark when number = {number!r}:')
        print(f'get_set_bits_count_using_modulo_operator(number) = {get_set_bits_count_using_modulo_operator(number)!r}')
        timing = timeit(f'z.get_set_bits_count_using_modulo_operator({number})', setup=setup)
        print(f'timeit() runs in {timing} seconds')
        print(f'get_set_bits_count_using_brian_kernighans_algorithm(number) = {get_set_bits_count_using_brian_kernighans_algorithm(number)!r}')
        timing = timeit(f'z.get_set_bits_count_using_brian_kernighans_algorithm({number})', setup=setup)
        print(f'timeit() runs in {timing} seconds')
    for number in (25, 37, 58, 0):
        do_benchmark(number)
        print()
"\n    Benchmark code for comparing 2 functions, with different length int values.\n    Brian Kernighan's algorithm is consistently faster than using modulo_operator.\n    "
def do_benchmark(number: int) -> None:
    setup = 'import __main__ as z'
    print(f'Benchmark when number = {number!r}:')
    print(f'get_set_bits_count_using_modulo_operator(number) = {get_set_bits_count_using_modulo_operator(number)!r}')
    timing = timeit(f'z.get_set_bits_count_using_modulo_operator({number})', setup=setup)
    print(f'timeit() runs in {timing} seconds')
    print(f'get_set_bits_count_using_brian_kernighans_algorithm(number) = {get_set_bits_count_using_brian_kernighans_algorithm(number)!r}')
    timing = timeit(f'z.get_set_bits_count_using_brian_kernighans_algorithm({number})', setup=setup)
    print(f'timeit() runs in {timing} seconds')
setup = 'import __main__ as z'
print(f'Benchmark when number = {number!r}:')
print(f'get_set_bits_count_using_modulo_operator(number) = {get_set_bits_count_using_modulo_operator(number)!r}')
timing = timeit(f'z.get_set_bits_count_using_modulo_operator({number})', setup=setup)
print(f'timeit() runs in {timing} seconds')
print(f'get_set_bits_count_using_brian_kernighans_algorithm(number) = {get_set_bits_count_using_brian_kernighans_algorithm(number)!r}')
timing = timeit(f'z.get_set_bits_count_using_brian_kernighans_algorithm({number})', setup=setup)
print(f'timeit() runs in {timing} seconds')
number
(25, 37, 58, 0)
do_benchmark(number)
print()
__name__ Eq '__main__'
import doctest
doctest.testmod()
benchmark()