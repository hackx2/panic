package panic;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Expr.ExprOf;
import haxe.macro.PositionTools;

@:panic.skip // just in case ^^
final class Funcs {
	#if macro
	static function panic_(txt:String, message:ExprOf<String>, ?panic:Bool) {
		final msg = switch message.expr {
			case EConst(CString(s, _)): s;
			case _: null;
		}
		
		final pos = Context.currentPos();
		final loc = PositionTools.toLocation(pos);
		
		final arr:Array<Dynamic> = [loc.file,loc.range.start.line, loc.range.start.character];
		final where = 'panicked at ' + arr.join(':');

		final out = new StringBuf();
		out.add(where); out.add(':\n');
		if(panic) {
			out.add(msg != null ? msg : txt);
		} else {
			out.add(txt + (msg != null ? ': $msg' : ''));
		}
		
		return if (Context.defined('sys') && !Context.defined('panic.throw')) macro {
			Sys.stderr().writeString($v{out.toString()});
			Sys.exit(101); // same status rust exits with
			throw $v{txt}; // stops the compiler from complaining about requiring a return type
		} else {
			macro throw $v{txt};
		}
	}
	#end

	/**
	 * Panics the current process
	 */
	public static macro function panic(?message:ExprOf<String>) {
		return panic_('explicit panic', message, true);
	}

	/**
	 * Indicates unreachable code.
	 */
	public static macro function unreachable(?message:ExprOf<String>) {
		return panic_('internal error: entered unreachable code', message);
	}

	/**
	 * Indicates unimplemented code by panicking with a message of "not implemented".  
	 * 
	 * Allows your code to pass the type-check.
	 */
	public static macro function unimplemented(?message:ExprOf<String>) {
		return panic_('not implemented', message);
	}

	/**
	 * Indicates unfinished code.
	 * 
	 * This may be useful if you're prototyping something, or you just want a placeholder.
	 */
	public static macro function todo(?message:ExprOf<String>) {
		return panic_('not yet implemented', message);
	}
}