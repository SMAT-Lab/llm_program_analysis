from std import collection.*
class Box {
	var v: Int64
	init(v: Int64) { this.v = v }
}
func sumArray(a: ArrayList<Box>): Int64 {
	var s = 0
	for (i in 0..a.size) {
		s += a[i].v
	}
	return s
}
var inputArray: ?ArrayList<Box> = { =>
	let size = 10_000
	var a = ArrayList<Box>()
	a.reserve(size)
	for (i in 0..size) {
		a.append(Box(i))
	}
	return a
}()
public func run_ClassArrayGetter(reps: Int64) {
	let a: ArrayList<Box> = inputArray.getOrThrow()
	for (_ in 0..reps) {
		let _ = sumArray(a)
	}
}
main() {
	let reps = 100
	blackHole(inputArray)
	benchmark("ClassArrayGetter2", run_ClassArrayGetter, reps)
}