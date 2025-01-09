class QueryApi(object):

    def __init__(self, memory_cache, reverse_index_cluster):
        self.memory_cache = memory_cache
        self.reverse_index_cluster = reverse_index_cluster

    def parse_query(self, query):
        """Remove markup, break text into terms, deal with typos,
        normalize capitalization, convert to use boolean operations.
        """
        ...

    def process_query(self, query):
        query = self.parse_query(query)
        results = self.memory_cache.get(query)
        if results is None:
            results = self.reverse_index_cluster.process_search(query)
            self.memory_cache.set(query, results)
        return results
def __init__(self, memory_cache, reverse_index_cluster):
    self.memory_cache = memory_cache
    self.reverse_index_cluster = reverse_index_cluster
self.memory_cache = memory_cache
self.reverse_index_cluster = reverse_index_cluster
def parse_query(self, query):
    """Remove markup, break text into terms, deal with typos,
        normalize capitalization, convert to use boolean operations.
        """
    ...
'Remove markup, break text into terms, deal with typos,\n        normalize capitalization, convert to use boolean operations.\n        '
Ellipsis
def process_query(self, query):
    query = self.parse_query(query)
    results = self.memory_cache.get(query)
    if results is None:
        results = self.reverse_index_cluster.process_search(query)
        self.memory_cache.set(query, results)
    return results
query = self.parse_query(query)
results = self.memory_cache.get(query)
results Is None
class Node(object):

    def __init__(self, query, results):
        self.query = query
        self.results = results
def __init__(self, query, results):
    self.query = query
    self.results = results
self.query = query
self.results = results
class LinkedList(object):

    def __init__(self):
        self.head = None
        self.tail = None

    def move_to_front(self, node):
        ...

    def append_to_front(self, node):
        ...

    def remove_from_tail(self):
        ...
def __init__(self):
    self.head = None
    self.tail = None
self.head = None
self.tail = None
def move_to_front(self, node):
    ...
Ellipsis
def append_to_front(self, node):
    ...
Ellipsis
def remove_from_tail(self):
    ...
Ellipsis
class Cache(object):

    def __init__(self, MAX_SIZE):
        self.MAX_SIZE = MAX_SIZE
        self.size = 0
        self.lookup = {}
        self.linked_list = LinkedList()

    def get(self, query):
        """Get the stored query result from the cache.

        Accessing a node updates its position to the front of the LRU list.
        """
        node = self.lookup[query]
        if node is None:
            return None
        self.linked_list.move_to_front(node)
        return node.results

    def set(self, results, query):
        """Set the result for the given query key in the cache.

        When updating an entry, updates its position to the front of the LRU list.
        If the entry is new and the cache is at capacity, removes the oldest entry
        before the new entry is added.
        """
        node = self.map[query]
        if node is not None:
            node.results = results
            self.linked_list.move_to_front(node)
        else:
            if self.size == self.MAX_SIZE:
                self.lookup.pop(self.linked_list.tail.query, None)
                self.linked_list.remove_from_tail()
            else:
                self.size += 1
            new_node = Node(query, results)
            self.linked_list.append_to_front(new_node)
            self.lookup[query] = new_node
def __init__(self, MAX_SIZE):
    self.MAX_SIZE = MAX_SIZE
    self.size = 0
    self.lookup = {}
    self.linked_list = LinkedList()
self.MAX_SIZE = MAX_SIZE
self.size = 0
self.lookup = {}
self.linked_list = LinkedList()
def get(self, query):
    """Get the stored query result from the cache.

        Accessing a node updates its position to the front of the LRU list.
        """
    node = self.lookup[query]
    if node is None:
        return None
    self.linked_list.move_to_front(node)
    return node.results
'Get the stored query result from the cache.\n\n        Accessing a node updates its position to the front of the LRU list.\n        '
node = self.lookup[query]
node Is None
def set(self, results, query):
    """Set the result for the given query key in the cache.

        When updating an entry, updates its position to the front of the LRU list.
        If the entry is new and the cache is at capacity, removes the oldest entry
        before the new entry is added.
        """
    node = self.map[query]
    if node is not None:
        node.results = results
        self.linked_list.move_to_front(node)
    else:
        if self.size == self.MAX_SIZE:
            self.lookup.pop(self.linked_list.tail.query, None)
            self.linked_list.remove_from_tail()
        else:
            self.size += 1
        new_node = Node(query, results)
        self.linked_list.append_to_front(new_node)
        self.lookup[query] = new_node
'Set the result for the given query key in the cache.\n\n        When updating an entry, updates its position to the front of the LRU list.\n        If the entry is new and the cache is at capacity, removes the oldest entry\n        before the new entry is added.\n        '
node = self.map[query]
node IsNot None
results = self.reverse_index_cluster.process_search(query)
self.memory_cache.set(query, results)
return None
node.results = results
self.linked_list.move_to_front(node)
self.size Eq self.MAX_SIZE
return results
self.lookup.pop(self.linked_list.tail.query, None)
self.linked_list.remove_from_tail()
self.size += 1
new_node = Node(query, results)
self.linked_list.append_to_front(new_node)
self.lookup[query] = new_node