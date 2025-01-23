main(args: Array<String>) {
	let reps = Int64.tryParse(args[1]) ?? 100
	benchmark("NibbleSort", run_NibbleSort, reps)
}
func run_NibbleSort(reps: Int64) {
	let vRef: UInt64 = 0xfeedbba000000000
	let v: UInt64 = 0xbadbeef
	var c = NibbleCollection(v)
	for (_ in 0..1_000*reps) {
		c.val = v
		c.quicksort()
		if (c.val != vRef) {
			break
		}
	}
	check(c.val == vRef)
}
class NibbleCollection {
	var val: UInt64
	public prop let size: Int64 {
		get() { return 16 }
	}
	init(val: UInt64) { this.val = val }
	public operator func [](index: Int64): UInt64 {
		return (val >> (index * 4)) & 0xf
	}
	public operator func [](index: Int64, value!: UInt64) {
		let mask = UInt64(0xf) << (index * 4)
		// 清空nibble
		val &= !mask
		// 写入nibble
		val |= value << (index * 4)
	}
	private func swap_(i: Int64, j: Int64) {
		let t = this[i]
		this[i] = this[j]
		this[j] = t
	}
	private func quicksort_(lft: Int64, rht: Int64): Unit {
		if (lft < rht) {
			let pivot = this[lft + ((rht - lft) / 2)]
			var lft_new = lft
			var rht_new = rht
			quicksort_(lft, rht_new)
			quicksort_(lft_new, rht)
		}
	}
	func quicksort() {
		quicksort_(0, this.size - 1)
	}
}