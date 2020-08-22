
# Command indicator
const indicator = "> "
# Scrollback history
var history = []
# Current command and history items that have been modified 
# (cleared every execution)
var commands = [""]
var command_index = 0

const marker_symbol = "█"
var marker_index = 0

func get_command(with_indicator, with_marker):
	var c = commands[command_index]
	if with_marker:
		c = c.left(marker_index) + marker_symbol + c.right(marker_index + 1)
	if with_indicator:
		c = indicator + c
	return c

func add_history(command):
	history.insert(0, command)
	commands = [""]
	marker_index = 0
	command_index = 0

func add_characters(characters):
	# Add character to current command
	commands[command_index] = \
		commands[command_index].insert(marker_index, characters)
	# Move command marker
	marker_index += characters.length()

func backspace():
	# Remove one character behind the marker
	if marker_index > 0:
		commands[command_index] = \
			commands[command_index].left(marker_index - 1) + \
			commands[command_index].right(marker_index)
		marker_index -= 1

func delete():
	if marker_index < commands[command_index].length():
		commands[command_index] = \
			commands[command_index].left(marker_index) + \
			commands[command_index].right(marker_index + 1)
	
func previous_command():
	command_index = min(
		command_index + 1, 
		history.size())
	# Import the history item to commands
	if command_index == commands.size():
		commands.append(history[command_index - 1])
	marker_index = commands[command_index].length()

func next_command():
	command_index = max(
		command_index - 1, 
		0)
	marker_index = commands[command_index].length()

func marker_right():
	# Move marker if not at the end of string
	marker_index = min(
		marker_index + 1, 
		commands[command_index].length())

func marker_left():
	# Move marker if not at the start of string
	marker_index = max(
		marker_index - 1, 
		0)

func marker_position():
	return marker_index

