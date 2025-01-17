package cj2sql.sql.expr
import std.collection.ArrayList
import std.collection.collectString
public class SqlCaseExpr <: SqlExpr {
    private let _paren: Bool
    private let _matchExpr: ?SqlExpr
    private let _whenClauses: ArrayList<SqlWhenClause>
    private let _elseExpr: ?SqlExpr
    public SqlCaseExpr(matchExpr: SqlExpr, whenClauses: Array<SqlWhenClause>, elseExpr: SqlExpr, paren!: Bool = true) {
        this._matchExpr = matchExpr
        this._whenClauses = ArrayList<SqlWhenClause>(whenClauses)
        this._elseExpr = elseExpr
        this._paren = paren
    }
    public init(whenClauses: Array<SqlWhenClause>, matchExpr!: ?SqlExpr = None, elseExpr!: ?SqlExpr = None,
        paren!: Bool = true) {
        this._matchExpr = matchExpr
        this._whenClauses = ArrayList<SqlWhenClause>(whenClauses)
        this._elseExpr = elseExpr
        this._paren = paren
    }
    public prop paren: Bool {
        get() {
            return _paren
        }
    }
    public prop matchExpr: ?SqlExpr {
        get() {
            return _matchExpr
        }
    }
    public prop whenClauses: ArrayList<SqlWhenClause> {
        get() {
            return _whenClauses
        }
    }
    public prop elseExpr: ?SqlExpr {
        get() {
            return _elseExpr
        }
    }
    public func traverse(visitor: SqlVisitor) {
        visitor.resetBreakTraverse()
        visitor.visit(this)
        if (visitor.needBreakTraverse()) {
            return
        }
        if (let Some(expr) <- _matchExpr) {
            expr.traverse(visitor)
        }
        for (expr in _whenClauses) {
            expr.traverse(visitor)
        }
        if (let Some(expr) <- _elseExpr) {
            expr.traverse(visitor)
        }
    }
    public func toString(): String {
        let sql = StringBuilder()
        if (_paren) {
            sql.append("(")
        }
        sql.append("CASE")
        if (let Some(expr) <- _matchExpr) {
            sql.append(" ")
            sql.append(expr.toString())
        }
        sql.append(" ")
        sql.append(_whenClauses |> collectString<SqlWhenClause>(delimiter: " "))
        if (let Some(expr) <- _elseExpr) {
            sql.append(" ELSE ")
            sql.append(expr.toString())
        }
        sql.append(" END")
        if (_paren) {
            sql.append(")")
        }
        return sql.toString()
    }
}
public class SqlWhenClause <: SqlExpr {
    private let _whenExpr: SqlExpr
    private let _thenExpr: SqlExpr
    public SqlWhenClause(whenExpr: SqlExpr, thenExpr: SqlExpr) {
        this._whenExpr = whenExpr
        this._thenExpr = thenExpr
    }
    public prop whenExpr: SqlExpr {
        get() {
            return _whenExpr
        }
    }
    public prop thenExpr: SqlExpr {
        get() {
            return _thenExpr
        }
    }
    public func traverse(visitor: SqlVisitor) {
        visitor.resetBreakTraverse()
        visitor.visit(this)
        if (visitor.needBreakTraverse()) {
            return
        }
        _whenExpr.traverse(visitor)
        _thenExpr.traverse(visitor)
    }
    public func toString(): String {
        return "WHEN " + _whenExpr.toString() + " THEN " + _thenExpr.toString()
    }
}