# The filestream should have identical class methods
# as the normal stream, but act on files instead

var _file
var _mutex

func _init(path, rw):
	_file = File.new()
	if rw == "w":
		_file.open(path, File.WRITE)
	# Default "r"
	else:
		_file.open(path, File.READ)
	_mutex = Mutex.new()

func write(val):
	_mutex.lock()
	if val == -1:
		_file.close()
	else:
		_file.store_8(val)
	_mutex.unlock()

func read():
	_mutex.lock()
	# Return -1 if passed file length
	if _file.get_position() >= _file.get_len():
		return -1
	var c = _file.get_8()
	_mutex.unlock()
	return c

func length():
	return _file.get_len()

func close():
	_mutex.lock()
	_file.close()
	_mutex.unlock()
