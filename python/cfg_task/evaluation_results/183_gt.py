class Item(object):

    def __init__(self, key, value):
        self.key = key
        self.value = value
def __init__(self, key, value):
    self.key = key
    self.value = value
self.key = key
self.value = value
class HashTable(object):

    def __init__(self, size):
        self.size = size
        self.table = [[] for _ in range(self.size)]

    def _hash_function(self, key):
        return key % self.size

    def set(self, key, value):
        hash_index = self._hash_function(key)
        for item in self.table[hash_index]:
            if item.key == key:
                item.value = value
                return
        self.table[hash_index].append(Item(key, value))

    def get(self, key):
        hash_index = self._hash_function(key)
        for item in self.table[hash_index]:
            if item.key == key:
                return item.value
        raise KeyError('Key not found')

    def remove(self, key):
        hash_index = self._hash_function(key)
        for (index, item) in enumerate(self.table[hash_index]):
            if item.key == key:
                del self.table[hash_index][index]
                return
        raise KeyError('Key not found')
def __init__(self, size):
    self.size = size
    self.table = [[] for _ in range(self.size)]
self.size = size
self.table = [[] for _ in range(self.size)]
def _hash_function(self, key):
    return key % self.size
return key % self.size
def set(self, key, value):
    hash_index = self._hash_function(key)
    for item in self.table[hash_index]:
        if item.key == key:
            item.value = value
            return
    self.table[hash_index].append(Item(key, value))
hash_index = self._hash_function(key)
item
self.table[hash_index]
item.key Eq key
self.table[hash_index].append(Item(key, value))
def get(self, key):
    hash_index = self._hash_function(key)
    for item in self.table[hash_index]:
        if item.key == key:
            return item.value
    raise KeyError('Key not found')
hash_index = self._hash_function(key)
item.value = value
return
item
self.table[hash_index]
item.key Eq key
raise KeyError('Key not found')
def remove(self, key):
    hash_index = self._hash_function(key)
    for (index, item) in enumerate(self.table[hash_index]):
        if item.key == key:
            del self.table[hash_index][index]
            return
    raise KeyError('Key not found')
hash_index = self._hash_function(key)
return item.value
(index, item)
enumerate(self.table[hash_index])
item.key Eq key
raise KeyError('Key not found')
del self.table[hash_index][index]
return