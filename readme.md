# panic

Rust's `panic`, `todo`, `unimplemented`, and `unreachable` macro method implementation for Haxe.

> [!IMPORTANT]
> On `sys` targets, `-D panic.throw`, throws instead of panicking.

## usage

```haxe
function main() {
	panic("hi!"); /* hi! */ panic(); /* explicit panic */
	todo("todo!"); /* not yet implemented: todo! */ todo(); /* not yet implemented */
	unimplemented("sure"); /* not implemented: sure */ unimplemented(); /* not implemented */
	unreachable("okay"); /* internal error: entered unreachable code: okay */ unreachable(); /* internal error: entered unreachable code */
}
```

## meta
| meta            | desc                                                                                                |
| --------------- | --------------------------------------------------------------------------------------------------- |
| `:panic.skip`   | Skips `Fixer` macro processing for this `class`/`abstract`                                          |
| `:panic.bypass` | Forces the `Fixer` macro to rewrite to `panic.Funcs`, ignoring any local methods with the same name |