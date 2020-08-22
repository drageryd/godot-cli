var _thread = Thread.new()
var _thread_busy = false
var _commands = load("commands.gd").new()

const Stream = preload("stream.gd")
const FileStream = preload("file_stream.gd")
var stdin = Stream.new()
var stdout = Stream.new()
var stderr = Stream.new()

# Run is called from the command line and holds the command to execute
func run(command):
	# Can the thread be joined
	if _thread_busy:
		print("Thread is already running")
	else:
		# Reserve the thread before starting it
		_thread_busy = true
		_thread.wait_to_finish()
		_thread.start(self, "_thread_main", command)

func is_busy():
	return _thread_busy

# Thread main runs the command string
func _thread_main(command):
	print("Thread running ", command, " ", OS.get_ticks_msec())

	# Create new streams
	stdin = Stream.new()
	stdout = Stream.new()
	stderr = Stream.new()
	var stdpipe = Stream.new()

	# Split at every pipe
	var command_list = command.split("|")
	for i in range(len(command_list)):
		# Every loop except the first reads from the previous stream
		if i != 0:
			stdin = stdpipe
		# Every loop except the last writes to a new pipe stream
		if i < command_list.size() - 1:
			stdpipe = Stream.new()
		else:
			# Use a reference to stdout
			stdpipe = stdout

		# Split command into an argument list
		var args : Array = command_list[i].split(" ", false)
		print(args)

		# Search for redirection in
		var stream_in = stdin
		var index = args.find("<")
		if index != -1:
			print("Found < at ", index)
			# Remove > element
			args.remove(index)
			# Set file stream to next argument
			stream_in = FileStream.new(args[index], "r")
			# Remove file element
			args.remove(index)

		# Search for redirection out
		var stream_out = stdpipe
		index = args.find(">")
		if index != -1:
			print("Found > at ", index)
			# Remove > element
			args.remove(index)
			# Set file stream to next argument
			stream_out = FileStream.new(args[index], "w")
			# Remove file element
			args.remove(index)

		print(args)
		#print(stdin._stream, stdpipe._stream, stdout._stream)
		# Call command
		_commands.call_command(args, stream_in, stream_out, stderr)
		#print(stdin._stream, stdpipe._stream, stdout._stream)
		OS.delay_msec(1000)
	# Mark as ready when done
	_thread_busy = false
	print("Done ", OS.get_ticks_msec())

func _exit_tree():
	_thread.wait_to_finish()
