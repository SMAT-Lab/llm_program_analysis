package cjqt.widgets
import cjqt.gui.*
import cjqt.core.*
foreign func nativeSplitterHandleCreate(orientation:Int32, parentPtr: Int64): Int64
foreign func nativeSplitterHandleDelete(ptr: Int64): Unit
foreign func nativeSplitterHandleSetOrientation(ptr: Int64, orientation: Int32): Unit
foreign func nativeSplitterHandleOrientation(ptr: Int64): Int32
foreign func nativeSplitterHandleOpaqueResize(ptr: Int64): Bool
foreign func nativeSplitterHandleSplitter(ptr: Int64): Int64
foreign func nativeSplitterHandleSizeHint(ptr: Int64): Int64
public class QSplitterHandle <: QWidget {
    public init(orientation!:Int64 = 1, parent!: QSplitter = QSplitter()) {
        super(unsafe {
            nativeSplitterHandleCreate(Int32(orientation), parent.ptr)
        })
    }
    public init(ptr: Int64) {
        super(ptr)
    }
    public override func delete() {
        unsafe {
            nativeSplitterHandleDelete(ptr)
        }
    }
    public func setOrientation(orientation:Int64) {
        unsafe {
            nativeSplitterHandleSetOrientation(ptr, Int32(orientation))
        }
    }
    public func orientation(): Int64 {
        let result = unsafe {
            nativeSplitterHandleOrientation(ptr)
        }
        return Int64(result)
    }
    public func opaqueResize(): Bool {
        let result = unsafe {
            nativeSplitterHandleOpaqueResize(ptr)
        }
        return result
    }
    public func splitter(): QSplitter {
        let result = unsafe {
            nativeSplitterHandleSplitter(ptr)
        }
        return QSplitter()
    }
    public func sizeHint(): QSize {
        let result = unsafe {
            nativeSplitterHandleSizeHint(ptr)
        }
        return QSize(result)
    }
}