from mrjob.job import MRJob
class RemoveDuplicateUrls(MRJob):

    def mapper(self, _, line):
        yield (line, 1)

    def reducer(self, key, values):
        total = sum(values)
        if total == 1:
            yield (key, total)

    def steps(self):
        """Run the map and reduce steps."""
        return [self.mr(mapper=self.mapper, reducer=self.reducer)]
def mapper(self, _, line):
    yield (line, 1)
(yield (line, 1))
def reducer(self, key, values):
    total = sum(values)
    if total == 1:
        yield (key, total)
total = sum(values)
total Eq 1
__name__ Eq '__main__'
(yield (key, total))
RemoveDuplicateUrls.run()
def steps(self):
    """Run the map and reduce steps."""
    return [self.mr(mapper=self.mapper, reducer=self.reducer)]
'Run the map and reduce steps.'
return [self.mr(mapper=self.mapper, reducer=self.reducer)]