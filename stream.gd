# The purpose of the stream class is to pass data via the stdio from scripts
# it will be used both when piping two commands and for stdin/stdout

var _stream
var _mutex

func _init():
	_stream = []
	_mutex = Mutex.new()

func write(val):
	_mutex.lock()
	_stream.append(val)
	_mutex.unlock()

func read():
	_mutex.lock()
	var c = _stream.pop_front()
	_mutex.unlock()
	return c

func length():
	return _stream.size()

func close():
	_mutex.lock()
	_stream.append(-1)
	_mutex.unlock()
