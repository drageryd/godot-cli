# Available commands to call from the command line

var _commands = {
	"test1": funcref(self, "_test1"),
	"test2": funcref(self, "_test2"),
}

func call_command(args):
	if args[0] in _commands:
		print("CALLING")
		_commands[args[0]].call_func(args)

func _test1(args):
	print("Called test1", args)

func _test2(args):
	print("Called test2", args)
