package elebeta.ds;
import haxe.macro.Expr;

class DHeapMacro
{
    static var id = 0;
    macro public static function createClass(genType:Expr,types:Expr)
    {
        return createClassLoop(genType,types);
    }
#if macro
    private static function createClassLoop(genType:Expr, types:Expr)
    {
        switch [genType.expr, types.expr]
        {
            case [EParenthesis(e), _]:
                return createClassLoop(e,types);
            case [_,EParenthesis(e)]:
                return createClassLoop(genType,e);
            case [ECheckType(_,genType), ECheckType(_, type)]:
                switch (type) {
                    case TAnonymous(fields):
                        var name = "DHeap_" + id++;
                        var cls = macro class QQCLASSE extends elebeta.ds.DHeap<$genType> {
                        };
                        cls.name = name;
                        cls.fields = fields;
                        haxe.macro.Context.defineType(cls);
                        var tpath = { pack:[], name:name };
                        return macro new $tpath();
                    case _:
                        throw new Error('The type must be an anonymous class', types.pos);
                }
            case _:
                throw new Error('Invalid expression. ECheckType expected', types.pos);
        }
    }
#end
}
