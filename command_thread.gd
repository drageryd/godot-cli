var _thread = Thread.new()
var _thread_lock = Mutex.new()

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
	# Run command
	OS.delay_msec(5000)
	# Unlock the thread when done
	_thread_lock.unlock()
	print("Done ", OS.get_ticks_msec())

func _exit_tree():
	_thread.wait_to_finish()
