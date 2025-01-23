from std import collection.*
extend Range<T> {
    public func toArrayList(): ArrayList<T> {
        let new = ArrayList<T>()
        for (item in this) {
            new.append(item)
        }
        return new
    }
}
extend ArrayList<T> {
    public operator func +(rht: ArrayList<T>): ArrayList<T> {
        this.appendAll(rht)
        return this
    }
}
let pH = 5000
let pyramidTemplate: ArrayList<Int64> =
    (1..=pH).toArrayList()
  + (pH..=1:-1).toArrayList()
public func run_SortIntPyramid(num: Int64) {
    for (_ in 0..(5*num)) {
        var pyramid = pyramidTemplate.clone()
        pyramid.sort()
        check(pyramid[0] <= pyramid[pyramid.size / 2])
    }
}
main(args: Array<String>) {
	let reps = Int64.tryParse(args[1]) ?? 100
    benchmark("SortIntPyramid", run_SortIntPyramid, reps)
}