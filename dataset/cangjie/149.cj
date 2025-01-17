package datamatrix.encoder
public enum SymbolShapeHint <: Equatable<SymbolShapeHint> & ToString {
    | FORCE_NONE
    | FORCE_SQUARE
    | FORCE_RECTANGLE
    public func GetSymbolShapeHintNum(result: SymbolShapeHint): Int64 {
        match (result) {
            case FORCE_NONE => return 0;
            case FORCE_SQUARE => return 1;
            case FORCE_RECTANGLE => return 2;
        }
    }
    public operator func ==(right: SymbolShapeHint): Bool {
        if (GetSymbolShapeHintNum(right) == GetSymbolShapeHintNum(this)) {
            true;
        } else {
            false;
        }
    }
    public operator func !=(right: SymbolShapeHint): Bool {
        if (GetSymbolShapeHintNum(right) != GetSymbolShapeHintNum(this)) {
            true;
        } else {
            false;
        }
    }
    public func toString() {
        match (this) {
            case FORCE_NONE => "FORCE_NONE"
            case FORCE_SQUARE => "FORCE_SQUARE"
            case FORCE_RECTANGLE => "FORCE_RECTANGLE"
        }
    }
}