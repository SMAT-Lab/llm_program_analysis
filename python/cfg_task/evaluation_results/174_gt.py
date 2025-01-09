from collections import deque
from enum import Enum
class State(Enum):
    unvisited = 0
    visited = 1
unvisited = 0
visited = 1
class Graph(object):

    def bfs(self, source, dest):
        if source is None:
            return False
        queue = deque()
        queue.append(source)
        source.visit_state = State.visited
        while queue:
            node = queue.popleft()
            print(node)
            if dest is node:
                return True
            for adjacent_node in node.adj_nodes.values():
                if adjacent_node.visit_state == State.unvisited:
                    queue.append(adjacent_node)
                    adjacent_node.visit_state = State.visited
        return False
def bfs(self, source, dest):
    if source is None:
        return False
    queue = deque()
    queue.append(source)
    source.visit_state = State.visited
    while queue:
        node = queue.popleft()
        print(node)
        if dest is node:
            return True
        for adjacent_node in node.adj_nodes.values():
            if adjacent_node.visit_state == State.unvisited:
                queue.append(adjacent_node)
                adjacent_node.visit_state = State.visited
    return False
source Is None
return False
queue
node = queue.popleft()
print(node)
dest Is node
return False
return True
adjacent_node
node.adj_nodes.values()
adjacent_node.visit_state Eq State.unvisited
queue.append(adjacent_node)
adjacent_node.visit_state = State.visited
class Person(object):

    def __init__(self, id, name):
        self.id = id
        self.name = name
        self.friend_ids = []
def __init__(self, id, name):
    self.id = id
    self.name = name
    self.friend_ids = []
self.id = id
self.name = name
self.friend_ids = []
class LookupService(object):

    def __init__(self):
        self.lookup = {}

    def get_person(self, person_id):
        person_server = self.lookup[person_id]
        return person_server.people[person_id]
def __init__(self):
    self.lookup = {}
self.lookup = {}
def get_person(self, person_id):
    person_server = self.lookup[person_id]
    return person_server.people[person_id]
person_server = self.lookup[person_id]
return person_server.people[person_id]
class PersonServer(object):

    def __init__(self):
        self.people = {}

    def get_people(self, ids):
        results = []
        for id in ids:
            if id in self.people:
                results.append(self.people[id])
        return results
def __init__(self):
    self.people = {}
self.people = {}
def get_people(self, ids):
    results = []
    for id in ids:
        if id in self.people:
            results.append(self.people[id])
    return results
results = []
id
ids
id In self.people
return results
results.append(self.people[id])
class UserGraphService(object):

    def __init__(self, person_ids, lookup):
        self.lookup = lookup
        self.person_ids = person_ids
        self.visited_ids = set()

    def bfs(self, source, dest):
        pass
def __init__(self, person_ids, lookup):
    self.lookup = lookup
    self.person_ids = person_ids
    self.visited_ids = set()
self.lookup = lookup
self.person_ids = person_ids
self.visited_ids = set()
def bfs(self, source, dest):
    pass
pass