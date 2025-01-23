package treesitter
public class Languages {
    public static func C(): CPointer<Unit> {
        unsafe { tree_sitter_c() }
    }
    public static func Cangjie(): CPointer<Unit> {
        unsafe { tree_sitter_char() }
    }
    public static func Kotlin(): CPointer<Unit> {
        unsafe { tree_sitter_kotlin() }
    }
    public static func Java(): CPointer<Unit> {
        unsafe { tree_sitter_java() }
    }
    public static func Go(): CPointer<Unit> {
        unsafe { tree_sitter_go() }
    }
    public static func Swift(): CPointer<Unit> {
        unsafe { tree_sitter_swift() }
    }
    public static func Cpp(): CPointer<Unit> {
        unsafe { tree_sitter_cpp() }
    }
    public static func CSharp(): CPointer<Unit> {
        unsafe { tree_sitter_c_sharp() }
    }
    public static func Javascript(): CPointer<Unit> {
        unsafe { tree_sitter_javascript() }
    }
    public static func Typescript(): CPointer<Unit> {
        unsafe { tree_sitter_tsx() }
    }
    public static func Rust(): CPointer<Unit> {
        unsafe { tree_sitter_rust() }
    }
    public static func Python(): CPointer<Unit> {
        unsafe { tree_sitter_python() }
    }
}