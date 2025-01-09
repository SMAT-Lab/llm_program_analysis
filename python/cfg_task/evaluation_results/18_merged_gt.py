'\nGraph Coloring also called "m coloring problem"\nconsists of coloring a given graph with at most m colors\nsuch that no adjacent vertices are assigned the same color\n\nWikipedia: https://en.wikipedia.org/wiki/Graph_coloring\n'
def valid_coloring(neighbours: list[int], colored_vertices: list[int], color: int) -> bool:
    """
    For each neighbour check if the coloring constraint is satisfied
    If any of the neighbours fail the constraint return False
    If all neighbours validate the constraint return True

    >>> neighbours = [0,1,0,1,0]
    >>> colored_vertices = [0, 2, 1, 2, 0]

    >>> color = 1
    >>> valid_coloring(neighbours, colored_vertices, color)
    True

    >>> color = 2
    >>> valid_coloring(neighbours, colored_vertices, color)
    False
    """
    return not any((neighbour == 1 and colored_vertices[i] == color for (i, neighbour) in enumerate(neighbours)))
'\n    For each neighbour check if the coloring constraint is satisfied\n    If any of the neighbours fail the constraint return False\n    If all neighbours validate the constraint return True\n\n    >>> neighbours = [0,1,0,1,0]\n    >>> colored_vertices = [0, 2, 1, 2, 0]\n\n    >>> color = 1\n    >>> valid_coloring(neighbours, colored_vertices, color)\n    True\n\n    >>> color = 2\n    >>> valid_coloring(neighbours, colored_vertices, color)\n    False\n    '
return not any((neighbour == 1 and colored_vertices[i] == color for (i, neighbour) in enumerate(neighbours)))
def util_color(graph: list[list[int]], max_colors: int, colored_vertices: list[int], index: int) -> bool:
    """
    Pseudo-Code

    Base Case:
    1. Check if coloring is complete
        1.1 If complete return True (meaning that we successfully colored the graph)

    Recursive Step:
    2. Iterates over each color:
        Check if the current coloring is valid:
            2.1. Color given vertex
            2.2. Do recursive call, check if this coloring leads to a solution
            2.4. if current coloring leads to a solution return
            2.5. Uncolor given vertex

    >>> graph = [[0, 1, 0, 0, 0],
    ...          [1, 0, 1, 0, 1],
    ...          [0, 1, 0, 1, 0],
    ...          [0, 1, 1, 0, 0],
    ...          [0, 1, 0, 0, 0]]
    >>> max_colors = 3
    >>> colored_vertices = [0, 1, 0, 0, 0]
    >>> index = 3

    >>> util_color(graph, max_colors, colored_vertices, index)
    True

    >>> max_colors = 2
    >>> util_color(graph, max_colors, colored_vertices, index)
    False
    """
    if index == len(graph):
        return True
    for i in range(max_colors):
        if valid_coloring(graph[index], colored_vertices, i):
            colored_vertices[index] = i
            if util_color(graph, max_colors, colored_vertices, index + 1):
                return True
            colored_vertices[index] = -1
    return False
'\n    Pseudo-Code\n\n    Base Case:\n    1. Check if coloring is complete\n        1.1 If complete return True (meaning that we successfully colored the graph)\n\n    Recursive Step:\n    2. Iterates over each color:\n        Check if the current coloring is valid:\n            2.1. Color given vertex\n            2.2. Do recursive call, check if this coloring leads to a solution\n            2.4. if current coloring leads to a solution return\n            2.5. Uncolor given vertex\n\n    >>> graph = [[0, 1, 0, 0, 0],\n    ...          [1, 0, 1, 0, 1],\n    ...          [0, 1, 0, 1, 0],\n    ...          [0, 1, 1, 0, 0],\n    ...          [0, 1, 0, 0, 0]]\n    >>> max_colors = 3\n    >>> colored_vertices = [0, 1, 0, 0, 0]\n    >>> index = 3\n\n    >>> util_color(graph, max_colors, colored_vertices, index)\n    True\n\n    >>> max_colors = 2\n    >>> util_color(graph, max_colors, colored_vertices, index)\n    False\n    '
index Eq len(graph)
return True
i
range(max_colors)
valid_coloring(graph[index], colored_vertices, i)
return False
colored_vertices[index] = i
util_color(graph, max_colors, colored_vertices, index Add 1)
return True
def color(graph: list[list[int]], max_colors: int) -> list[int]:
    """
    Wrapper function to call subroutine called util_color
    which will either return True or False.
    If True is returned colored_vertices list is filled with correct colorings

    >>> graph = [[0, 1, 0, 0, 0],
    ...          [1, 0, 1, 0, 1],
    ...          [0, 1, 0, 1, 0],
    ...          [0, 1, 1, 0, 0],
    ...          [0, 1, 0, 0, 0]]

    >>> max_colors = 3
    >>> color(graph, max_colors)
    [0, 1, 0, 2, 0]

    >>> max_colors = 2
    >>> color(graph, max_colors)
    []
    """
    colored_vertices = [-1] * len(graph)
    if util_color(graph, max_colors, colored_vertices, 0):
        return colored_vertices
    return []
'\n    Wrapper function to call subroutine called util_color\n    which will either return True or False.\n    If True is returned colored_vertices list is filled with correct colorings\n\n    >>> graph = [[0, 1, 0, 0, 0],\n    ...          [1, 0, 1, 0, 1],\n    ...          [0, 1, 0, 1, 0],\n    ...          [0, 1, 1, 0, 0],\n    ...          [0, 1, 0, 0, 0]]\n\n    >>> max_colors = 3\n    >>> color(graph, max_colors)\n    [0, 1, 0, 2, 0]\n\n    >>> max_colors = 2\n    >>> color(graph, max_colors)\n    []\n    '
colored_vertices = [-1] * len(graph)
util_color(graph, max_colors, colored_vertices, 0)
return colored_vertices