class Node(object):

    def __init__(self, results):
        self.results = results
        self.next = next
def __init__(self, results):
    self.results = results
    self.next = next
self.results = results
self.next = next
class LinkedList(object):

    def __init__(self):
        self.head = None
        self.tail = None

    def move_to_front(self, node):
        pass

    def append_to_front(self, node):
        pass

    def remove_from_tail(self):
        pass
def __init__(self):
    self.head = None
    self.tail = None
self.head = None
self.tail = None
def move_to_front(self, node):
    pass
pass
def append_to_front(self, node):
    pass
pass
def remove_from_tail(self):
    pass
pass
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
        node = self.lookup.get(query)
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
        node = self.lookup.get(query)
        if node is not None:
            node.results = results
            self.linked_list.move_to_front(node)
        else:
            if self.size == self.MAX_SIZE:
                self.lookup.pop(self.linked_list.tail.query, None)
                self.linked_list.remove_from_tail()
            else:
                self.size += 1
            new_node = Node(results)
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
    node = self.lookup.get(query)
    if node is None:
        return None
    self.linked_list.move_to_front(node)
    return node.results
'Get the stored query result from the cache.\n\n        Accessing a node updates its position to the front of the LRU list.\n        '
node = self.lookup.get(query)
node Is None
def set(self, results, query):
    """Set the result for the given query key in the cache.

        When updating an entry, updates its position to the front of the LRU list.
        If the entry is new and the cache is at capacity, removes the oldest entry
        before the new entry is added.
        """
    node = self.lookup.get(query)
    if node is not None:
        node.results = results
        self.linked_list.move_to_front(node)
    else:
        if self.size == self.MAX_SIZE:
            self.lookup.pop(self.linked_list.tail.query, None)
            self.linked_list.remove_from_tail()
        else:
            self.size += 1
        new_node = Node(results)
        self.linked_list.append_to_front(new_node)
        self.lookup[query] = new_node
'Set the result for the given query key in the cache.\n\n        When updating an entry, updates its position to the front of the LRU list.\n        If the entry is new and the cache is at capacity, removes the oldest entry\n        before the new entry is added.\n        '
node = self.lookup.get(query)
node IsNot None
return None
node.results = results
self.linked_list.move_to_front(node)
self.size Eq self.MAX_SIZE
self.lookup.pop(self.linked_list.tail.query, None)
self.linked_list.remove_from_tail()
self.size += 1
new_node = Node(results)
self.linked_list.append_to_front(new_node)
self.lookup[query] = new_node