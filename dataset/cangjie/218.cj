main(args: Array<String>) {
	let reps = Int64.tryParse(args[1]) ?? 100
	benchmark("StringEdits", run_StringEdits, reps)
}
let editWords = [
	"woodshed",
	"lakism",
	"gastroperiodynia"
]
let alphabet = "abcdefghijklmnopqrstuvwxyz"
func edits(word: String): HashSet<String> {
	let splits = (0..word.size)
	|> map { idx: Int64 => (word[..idx], word[idx..]) }
	|> collectArray
	var result = ArrayList<String>()
	for ((left, right) in splits) {
		// drop one character.
		result.append(left + right.dropFirst())
		// transpose two characters.
		match (right.first) {
			case Some(fst) =>
				let drop1 = right.dropFirst()
				match (drop1.first) {
					case Some(snd) =>
						result.append(left + snd + fst + drop1.dropFirst())
					case _ => continue
				}
			case _ => continue
		}
		// replace each character with another.
		for (letter in alphabet) {
			result.append(left + letter + right.dropFirst())
		}
		// insert rogue characters
		for (letter in alphabet) {
			result.append(left + letter + right)
		}
	}
	return HashSet<String>(result)
}
public func run_StringEdits(n: Int64) {
	for (_ in 1..=n) {
		for (word in editWords) {
			let _ = edits(word)
		}
	}
}