function todo(e):Void {
	trace(e);
}

function main() {
	todo("testing 123");
	@:bypass todo("testing 123");
	//panic.Funcs.todo("2");
}