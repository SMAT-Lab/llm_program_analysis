"\nA Hamiltonian cycle (Hamiltonian circuit) is a graph cycle\nthrough a graph that visits each node exactly once.\nDetermining whether such paths and cycles exist in graphs\nis the 'Hamiltonian path problem', which is NP-complete.\n\nWikipedia: https://en.wikipedia.org/wiki/Hamiltonian_path\n"
def valid_connection(graph: list[list[int]], next_ver: int, curr_ind: int, path: list[int]) -> bool:
    """
    Checks whether it is possible to add next into path by validating 2 statements
    1. There should be path between current and next vertex
    2. Next vertex should not be in path
    If both validations succeed we return True, saying that it is possible to connect
    this vertices, otherwise we return False

    Case 1:Use exact graph as in main function, with initialized values
    >>> graph = [[0, 1, 0, 1, 0],
    ...          [1, 0, 1, 1, 1],
    ...          [0, 1, 0, 0, 1],
    ...          [1, 1, 0, 0, 1],
    ...          [0, 1, 1, 1, 0]]
    >>> path = [0, -1, -1, -1, -1, 0]
    >>> curr_ind = 1
    >>> next_ver = 1
    >>> valid_connection(graph, next_ver, curr_ind, path)
    True

    Case 2: Same graph, but trying to connect to node that is already in path
    >>> path = [0, 1, 2, 4, -1, 0]
    >>> curr_ind = 4
    >>> next_ver = 1
    >>> valid_connection(graph, next_ver, curr_ind, path)
    False
    """
    if graph[path[curr_ind - 1]][next_ver] == 0:
        return False
    return not any((vertex == next_ver for vertex in path))
'\n    Checks whether it is possible to add next into path by validating 2 statements\n    1. There should be path between current and next vertex\n    2. Next vertex should not be in path\n    If both validations succeed we return True, saying that it is possible to connect\n    this vertices, otherwise we return False\n\n    Case 1:Use exact graph as in main function, with initialized values\n    >>> graph = [[0, 1, 0, 1, 0],\n    ...          [1, 0, 1, 1, 1],\n    ...          [0, 1, 0, 0, 1],\n    ...          [1, 1, 0, 0, 1],\n    ...          [0, 1, 1, 1, 0]]\n    >>> path = [0, -1, -1, -1, -1, 0]\n    >>> curr_ind = 1\n    >>> next_ver = 1\n    >>> valid_connection(graph, next_ver, curr_ind, path)\n    True\n\n    Case 2: Same graph, but trying to connect to node that is already in path\n    >>> path = [0, 1, 2, 4, -1, 0]\n    >>> curr_ind = 4\n    >>> next_ver = 1\n    >>> valid_connection(graph, next_ver, curr_ind, path)\n    False\n    '
graph[path[curr_ind - 1]][next_ver] Eq 0
return False
def util_hamilton_cycle(graph: list[list[int]], path: list[int], curr_ind: int) -> bool:
    """
    Pseudo-Code
    Base Case:
    1. Check if we visited all of vertices
        1.1 If last visited vertex has path to starting vertex return True either
            return False
    Recursive Step:
    2. Iterate over each vertex
        Check if next vertex is valid for transiting from current vertex
            2.1 Remember next vertex as next transition
            2.2 Do recursive call and check if going to this vertex solves problem
            2.3 If next vertex leads to solution return True
            2.4 Else backtrack, delete remembered vertex

    Case 1: Use exact graph as in main function, with initialized values
    >>> graph = [[0, 1, 0, 1, 0],
    ...          [1, 0, 1, 1, 1],
    ...          [0, 1, 0, 0, 1],
    ...          [1, 1, 0, 0, 1],
    ...          [0, 1, 1, 1, 0]]
    >>> path = [0, -1, -1, -1, -1, 0]
    >>> curr_ind = 1
    >>> util_hamilton_cycle(graph, path, curr_ind)
    True
    >>> path
    [0, 1, 2, 4, 3, 0]

    Case 2: Use exact graph as in previous case, but in the properties taken from
        middle of calculation
    >>> graph = [[0, 1, 0, 1, 0],
    ...          [1, 0, 1, 1, 1],
    ...          [0, 1, 0, 0, 1],
    ...          [1, 1, 0, 0, 1],
    ...          [0, 1, 1, 1, 0]]
    >>> path = [0, 1, 2, -1, -1, 0]
    >>> curr_ind = 3
    >>> util_hamilton_cycle(graph, path, curr_ind)
    True
    >>> path
    [0, 1, 2, 4, 3, 0]
    """
    if curr_ind == len(graph):
        return graph[path[curr_ind - 1]][path[0]] == 1
    for next_ver in range(len(graph)):
        if valid_connection(graph, next_ver, curr_ind, path):
            path[curr_ind] = next_ver
            if util_hamilton_cycle(graph, path, curr_ind + 1):
                return True
            path[curr_ind] = -1
    return False
'\n    Pseudo-Code\n    Base Case:\n    1. Check if we visited all of vertices\n        1.1 If last visited vertex has path to starting vertex return True either\n            return False\n    Recursive Step:\n    2. Iterate over each vertex\n        Check if next vertex is valid for transiting from current vertex\n            2.1 Remember next vertex as next transition\n            2.2 Do recursive call and check if going to this vertex solves problem\n            2.3 If next vertex leads to solution return True\n            2.4 Else backtrack, delete remembered vertex\n\n    Case 1: Use exact graph as in main function, with initialized values\n    >>> graph = [[0, 1, 0, 1, 0],\n    ...          [1, 0, 1, 1, 1],\n    ...          [0, 1, 0, 0, 1],\n    ...          [1, 1, 0, 0, 1],\n    ...          [0, 1, 1, 1, 0]]\n    >>> path = [0, -1, -1, -1, -1, 0]\n    >>> curr_ind = 1\n    >>> util_hamilton_cycle(graph, path, curr_ind)\n    True\n    >>> path\n    [0, 1, 2, 4, 3, 0]\n\n    Case 2: Use exact graph as in previous case, but in the properties taken from\n        middle of calculation\n    >>> graph = [[0, 1, 0, 1, 0],\n    ...          [1, 0, 1, 1, 1],\n    ...          [0, 1, 0, 0, 1],\n    ...          [1, 1, 0, 0, 1],\n    ...          [0, 1, 1, 1, 0]]\n    >>> path = [0, 1, 2, -1, -1, 0]\n    >>> curr_ind = 3\n    >>> util_hamilton_cycle(graph, path, curr_ind)\n    True\n    >>> path\n    [0, 1, 2, 4, 3, 0]\n    '
curr_ind Eq len(graph)
return graph[path[curr_ind - 1]][path[0]] == 1
next_ver
range(len(graph))
valid_connection(graph, next_ver, curr_ind, path)
return False
path[curr_ind] = next_ver
util_hamilton_cycle(graph, path, curr_ind Add 1)
return True
def hamilton_cycle(graph: list[list[int]], start_index: int=0) -> list[int]:
    """
    Wrapper function to call subroutine called util_hamilton_cycle,
    which will either return array of vertices indicating hamiltonian cycle
    or an empty list indicating that hamiltonian cycle was not found.
    Case 1:
    Following graph consists of 5 edges.
    If we look closely, we can see that there are multiple Hamiltonian cycles.
    For example one result is when we iterate like:
    (0)->(1)->(2)->(4)->(3)->(0)

    (0)---(1)---(2)
     |   /   \\   |
     |  /     \\  |
     | /       \\ |
     |/         \\|
    (3)---------(4)
    >>> graph = [[0, 1, 0, 1, 0],
    ...          [1, 0, 1, 1, 1],
    ...          [0, 1, 0, 0, 1],
    ...          [1, 1, 0, 0, 1],
    ...          [0, 1, 1, 1, 0]]
    >>> hamilton_cycle(graph)
    [0, 1, 2, 4, 3, 0]

    Case 2:
    Same Graph as it was in Case 1, changed starting index from default to 3

    (0)---(1)---(2)
     |   /   \\   |
     |  /     \\  |
     | /       \\ |
     |/         \\|
    (3)---------(4)
    >>> graph = [[0, 1, 0, 1, 0],
    ...          [1, 0, 1, 1, 1],
    ...          [0, 1, 0, 0, 1],
    ...          [1, 1, 0, 0, 1],
    ...          [0, 1, 1, 1, 0]]
    >>> hamilton_cycle(graph, 3)
    [3, 0, 1, 2, 4, 3]

    Case 3:
    Following Graph is exactly what it was before, but edge 3-4 is removed.
    Result is that there is no Hamiltonian Cycle anymore.

    (0)---(1)---(2)
     |   /   \\   |
     |  /     \\  |
     | /       \\ |
     |/         \\|
    (3)         (4)
    >>> graph = [[0, 1, 0, 1, 0],
    ...          [1, 0, 1, 1, 1],
    ...          [0, 1, 0, 0, 1],
    ...          [1, 1, 0, 0, 0],
    ...          [0, 1, 1, 0, 0]]
    >>> hamilton_cycle(graph,4)
    []
    """
    path = [-1] * (len(graph) + 1)
    path[0] = path[-1] = start_index
    return path if util_hamilton_cycle(graph, path, 1) else []
'\n    Wrapper function to call subroutine called util_hamilton_cycle,\n    which will either return array of vertices indicating hamiltonian cycle\n    or an empty list indicating that hamiltonian cycle was not found.\n    Case 1:\n    Following graph consists of 5 edges.\n    If we look closely, we can see that there are multiple Hamiltonian cycles.\n    For example one result is when we iterate like:\n    (0)->(1)->(2)->(4)->(3)->(0)\n\n    (0)---(1)---(2)\n     |   /   \\   |\n     |  /     \\  |\n     | /       \\ |\n     |/         \\|\n    (3)---------(4)\n    >>> graph = [[0, 1, 0, 1, 0],\n    ...          [1, 0, 1, 1, 1],\n    ...          [0, 1, 0, 0, 1],\n    ...          [1, 1, 0, 0, 1],\n    ...          [0, 1, 1, 1, 0]]\n    >>> hamilton_cycle(graph)\n    [0, 1, 2, 4, 3, 0]\n\n    Case 2:\n    Same Graph as it was in Case 1, changed starting index from default to 3\n\n    (0)---(1)---(2)\n     |   /   \\   |\n     |  /     \\  |\n     | /       \\ |\n     |/         \\|\n    (3)---------(4)\n    >>> graph = [[0, 1, 0, 1, 0],\n    ...          [1, 0, 1, 1, 1],\n    ...          [0, 1, 0, 0, 1],\n    ...          [1, 1, 0, 0, 1],\n    ...          [0, 1, 1, 1, 0]]\n    >>> hamilton_cycle(graph, 3)\n    [3, 0, 1, 2, 4, 3]\n\n    Case 3:\n    Following Graph is exactly what it was before, but edge 3-4 is removed.\n    Result is that there is no Hamiltonian Cycle anymore.\n\n    (0)---(1)---(2)\n     |   /   \\   |\n     |  /     \\  |\n     | /       \\ |\n     |/         \\|\n    (3)         (4)\n    >>> graph = [[0, 1, 0, 1, 0],\n    ...          [1, 0, 1, 1, 1],\n    ...          [0, 1, 0, 0, 1],\n    ...          [1, 1, 0, 0, 0],\n    ...          [0, 1, 1, 0, 0]]\n    >>> hamilton_cycle(graph,4)\n    []\n    '
path = [-1] * (len(graph) + 1)
path[0] = path[-1] = start_index
return path if util_hamilton_cycle(graph, path, 1) else []