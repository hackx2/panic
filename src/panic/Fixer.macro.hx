package panic;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.ExprTools;

@:no_panic
final class Fixer {
	static final no_meta:String = ':no_panic';
	static final functions = ['panic', 'unreachable', 'unimplemented', 'todo']; // panic methods ^^

	public static function build() {
		final t = Context.getLocalType();
		if (t == null) return null;

		// skips anything that isn't a class or an abstract
		switch t {
			case TInst(c, _): // classes
				final ct = c.get();
				if (ct.isExtern || ct.meta.has(no_meta)) return null;
			case TAbstract(a, _):
				final at = a.get();
				if (at.meta.has(no_meta)) return null;
			case _: return null;
		}

		final fields = Context.getBuildFields();

		// get's all the current class/abstract field names
		final field_names = [for (f in fields) f.name];

		for (f in fields) switch f.kind {
			case FFun(fun): if(fun.expr != null) fun.expr = rewrite_expr(fun.expr, field_names);
			case FProp(get, set, ct, expr): if(expr != null) f.kind = FProp(get, set, ct, rewrite_expr(expr, field_names));
			case FVar(ct, expr): if(expr != null) f.kind = FVar(ct, rewrite_expr(expr, field_names));
		}
		
		return fields;
	}

	// converts `todo("hi")` to `panic.Funcs.todo("hi")`
	static function rewrite_expr(e:Expr, field_names:Array<String>):Expr switch e.expr {
		case EMeta({name: ":bypass"}, inner_expr): return rewrite_expr(inner_expr, []);
		case ECall({expr: EConst(CIdent(name))}, args) if(functions.contains(name) && !field_names.contains(name)):
			final callee = macro panic.Funcs.$name;
			return {
				expr: ECall(callee, [for (a in args) rewrite_expr(a, field_names)]),
				pos: e.pos
			}
		case _: return ExprTools.map(e, v -> rewrite_expr(v, field_names));
	}
}
