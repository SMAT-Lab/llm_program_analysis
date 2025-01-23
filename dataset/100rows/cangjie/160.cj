package libclang
public enum CXChildVisitResult <: Ordinal<CXChildVisitResult> {
    CXChildVisit_Break
    | CXChildVisit_Continue
    | CXChildVisit_Recurse
    override public prop ordinal: UInt {
        get() {
            match (this) {
                case CXChildVisit_Break => 0
                case CXChildVisit_Continue => 1
                case CXChildVisit_Recurse => 2
            }
        }
    }
    static redef public func fromOrdinal(ordinal: UInt): CXChildVisitResult {
        match (ordinal) {
            case 0 => CXChildVisit_Break
            case 1 => CXChildVisit_Continue
            case 2 => CXChildVisit_Recurse
            case invalid => throw IllegalArgumentException("Can't create CXChildVisitResult from ${invalid}")
        }
    }
}