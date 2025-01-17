package cjqt.widgets
import cjqt.core.*
foreign func nativeFileDialogGetOpenFileUrl(
    parentPtr: Int64,
    caption: CString,
    dirPtr: Int64,
    filter: CString
): Int64
foreign func nativeFileDialogGetOpenFileName(
    parentPtr: Int64,
    caption: CString,
    dir: CString,
    filter: CString
): CString
foreign func nativeFileDialogGetSaveFileUrl(
    parentPtr: Int64,
    caption: CString,
    dirPtr: Int64,
    filter: CString
): Int64
foreign func nativeFileDialogGetSaveFileName(
    parentPtr: Int64,
    caption: CString,
    dir: CString,
    filter: CString
): CString
public class QFileDialog <: QWidget {
    static public func getOpenFileUrl(parent!: QWidget = QWidget(0), caption!: String = "", dir!: QUrl = QUrl(""),
        filter!: String = ""): QUrl {
        let urlPtr = unsafe {
            nativeFileDialogGetOpenFileUrl(parent.ptr, LibC.mallocCString(caption), dir.ptr, LibC.mallocCString(filter))
        }
        return QUrl(urlPtr)
    }
    static public func getOpenFileName(parent!: QWidget = QWidget(0), caption!: String = "", dir!: String = "",
        filter!: String = ""): String {
        let name = unsafe {
            nativeFileDialogGetOpenFileName(parent.ptr, LibC.mallocCString(caption), LibC.mallocCString(dir), LibC.mallocCString(filter))
        }
        return name.toString()
    }
    static public func getSaveFileUrl(parent!: QWidget = QWidget(0), caption!: String = "", dir!: QUrl = QUrl(""),
        filter!: String = ""): QUrl {
        let urlPtr = unsafe {
            nativeFileDialogGetSaveFileUrl(parent.ptr, LibC.mallocCString(caption), dir.ptr, LibC.mallocCString(filter))
        }
        return QUrl(urlPtr)
    }
    static public func getSaveFileName(parent!: QWidget = QWidget(0), caption!: String = "", dir!: String = "",
        filter!: String = ""): String {
        let name = unsafe {
            nativeFileDialogGetSaveFileName(parent.ptr, LibC.mallocCString(caption), LibC.mallocCString(dir), LibC.mallocCString(filter))
        }
        return name.toString()
    }
}