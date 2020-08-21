var _thread = Thread.new()
var _thread_lock = Mutex.new()
var _commands = load("commands.gd").new()

# Run is called from the command line and holds the command to execute
func run(command):
	# Can the thread be joined
	if _thread_lock.try_lock() == OK:
		_thread.wait_to_finish()
		_thread.start(self, "_thread_main", command)
		_thread_lock.unlock()
	else:
		print("Thread is already running")

# Thread main runs the command string
func _thread_main(command):
	print("Thread running ", command, " ", OS.get_ticks_msec())
	# Lock thread
	_thread_lock.lock()
	# Split at every pipe
	for c in command.split("|"):
		var args = c.split(" ", false)
		_commands.call_command(args)
	# Unlock the thread when done
	_thread_lock.unlock()
	print("Done ", OS.get_ticks_msec())

func _exit_tree():
	_thread.wait_to_finish()
