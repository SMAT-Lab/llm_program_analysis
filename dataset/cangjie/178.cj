package compress4cj.archivers.rar.unpack
import std.log.*
import std.io.*
import std.fs.*
import std.collection.*
import compress4cj.archivers.rar.unpack.decode.Compress
import compress4cj.utils.internals.URS
import compress4cj.archivers.rar.unpack.vm.VMPreparedProgram
public class UnpackFilter {
    private var BlockStart: Int32 = 0
    private var BlockLength: Int32 = 0
    private var ExecCount: Int32 = 0
    private var NextWindow: Bool = false
    // position of parent filter in Filters array used as prototype for filter
    // in PrgStack array. Not defined for filters in Filters array.
    private var ParentFilter: Int32 = 0
    private var Prg :VMPreparedProgram = VMPreparedProgram()
    public func getBlockLength(): Int32 {
        return BlockLength
    }
    public func setBlockLength(blockLength: Int32) {
        BlockLength = blockLength
    }
    public func getBlockStart(): Int32 {
        return BlockStart
    }
    public func setBlockStart(blockStart: Int32) {
        BlockStart = blockStart
    }
    public func getExecCount(): Int32 {
        return ExecCount
    }
    public func setExecCount(execCount: Int32) {
        ExecCount = execCount
    }
    public func isNextWindow(): Bool {
        return NextWindow
    }
    public func setNextWindow( nextWindow: Bool) {
        NextWindow = nextWindow
    }
    public func getParentFilter() : Int32{
        return ParentFilter
    }
    public func setParentFilter(parentFilter: Int32) {
        ParentFilter = parentFilter
    }
    public func getPrg(): VMPreparedProgram {
        return Prg
    }
    public func setPrg(prg: VMPreparedProgram) {
        Prg = prg
    }
}