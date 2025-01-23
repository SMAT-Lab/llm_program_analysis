package bindings.clang.common
from clang import libclang.*
from cbindings import bindings.common.CTranslationContext
public func getName(cdecl: CXCursor): String {
    let spelling = getCursorSpelling(cdecl)
    match (cdecl.kind) {
        case CXCursor_StructDecl | CXCursor_UnionDecl | CXCursor_EnumDecl =>
            let name = if (spelling.isEmpty()) { getTypeSpelling(getCursorType(cdecl)) } else { spelling }
            getParentPrefix(cdecl) + name
        case _ => spelling
    }
}
func getParentName(cursor: CXCursor, ctx!: ?CTranslationContext = None): ?String {
    let parent = getCursorLexicalParent(cursor)
    match (parent.kind) {
        case CXCursor_TranslationUnit => None
        case _ => match(ctx) {
            case Some(ctx) => getUniqueName(parent, ctx: ctx)
            case None => getName(parent)
        }
    }
}
func getParentPrefix(cursor: CXCursor, ctx!: ?CTranslationContext = None): String {
    match (getParentName(cursor, ctx: ctx)) {
        case Some(parentName) => "${parentName}_"
        case None => ""
    }
}
public func getUniqueName(cdecl: CXCursor, ctx!: CTranslationContext) {
    let parentPrefix = getParentPrefix(cdecl, ctx: ctx)
    match (isAnonymousRecordDecl(cdecl) || isAnonymous(cdecl)) {
        case true =>
            let kindSpecifier = match (cdecl.kind) {
                case CXCursor_StructDecl => "Struct"
                case CXCursor_UnionDecl => "Union"
                case CXCursor_EnumDecl => "Enum"
                case _ => ""
            }
            "${parentPrefix}${kindSpecifier}_Anon${ctx.getUniquieDeclId(cdecl)}"
        case false =>
            let cursorSpelling = getCursorSpelling(cdecl)
            let name = if (cursorSpelling.isEmpty()) { getTypeSpelling(getCursorType(cdecl)) } else { cursorSpelling }
            parentPrefix + name
    }
}
extend CTranslationContext {
    func getUniquieDeclId(cdecl: CXCursor) {
        getUniquieId(hashCursor(cdecl))
    }
}