package flexsearch
import std.collection.*
public class SearchOptions <: IndexSearchOptions {
    // A method used to extract a specific field from a query result. The output result may contain multiple fields, any one or more of which can be extracted. The default value is None
    var _pluck: ?ArrayList<String> = None
    public mut prop pluck: ?ArrayList<String> {
        get() {
            _pluck
        }
        set(v) {
            this._pluck = v
        }
    }
    // Stores the key value of the index object, which is an array collection of identifiers. The default value is None
    var _index: ?ArrayList<String> = None
    public mut prop index: ?ArrayList<String> {
        get() {
            _index
        }
        set(v) {
            this._index = v
        }
    }
    // One or more specific fields or fields are stored, and the default value is None
    var _field: ?ArrayList<String> = None
    public mut prop field: ?ArrayList<String> {
        get() {
            _field
        }
        set(v) {
            this._field = v
        }
    }
    // One or more label fields are stored, and the default value is None
    var _tag: ?Array<String> = None
    public mut prop tag: ?Array<String> {
        get() {
            _tag
        }
        set(v) {
            this._tag = v
        }
    }
    // Indicates whether the detailed result is required in the output. The default value is false
    var _enrich: Bool = false
    public mut prop enrich: Bool {
        get() {
            _enrich
        }
        set(v) {
            this._enrich = v
        }
    }
    // A method for combining multiple query conditions, allowing the creation of a complex query with multiple sub-queries, with a default value of "or"
    var _bool: String = "or"
    public mut prop bool: String {
        get() {
            _bool
        }
        set(v) {
            this._bool = v
        }
    }
}