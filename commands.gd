# Available commands to call from the command line

var _commands = {
	"test1": funcref(self, "_test1"),
	"test2": funcref(self, "_test2"),
	"echo_args": funcref(self, "_echo_args"),
	"forward_stdin": funcref(self, "_forward_stdin"),
}

func call_command(args, stdin, stdout, stderr):
	if len(args) == 0:
		return
	if args[0] in _commands:
		print("CALLING")
		_commands[args[0]].call_func(args, stdin, stdout, stderr)

func _test1(args, stdin, stdout, stderr):
	print("Called test1", args)

func _test2(args, stdin, stdout, stderr):
	print("Called test2", args)

func _echo_args(args, stdin, stdout, stderr):
	var bytes = str(args).to_ascii()
	for b in bytes:
		stdout.write(b)
		OS.delay_msec(1000)
	stdout.close()

func _forward_stdin(args, stdin, stdout, stderr):
	while true:
		var val = stdin.read()
		stdout.write(val)
		if val == -1:
			break
