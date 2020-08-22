extends Control

onready var output_text = $ScrollContainer/VBoxContainer/History
onready var command_text = $ScrollContainer/VBoxContainer/CurrentCommand

var command_thread = load("command_thread.gd").new()
var command_history = load("command_history.gd").new()

var tab_count = 0

# Clear commands at start
func _ready():
	# Clear console
	output_text.clear()
	command_text.clear()

# Input handler
func _input(event):
	# Toggle the command line with the key "under ESC"
	if event.is_action_pressed("toggle_console"):
		toggle_console()
	# Else treat input as keyboard input for the command line
	elif event is InputEventKey and event.pressed:
		# Printable characters
		var character = get_printable(event.unicode)
		# Add character to command if printable ascii
		if character != "":
			# Add character to current command
			command_history.add_characters(character)
		# Navigation and special keys
		# Run command
		elif event.scancode == KEY_ENTER:
			run_command()
		# Delete previous character
		elif event.scancode == KEY_BACKSPACE:
			command_history.backspace()
		# Delete character at marker
		elif event.scancode == KEY_DELETE:
			command_history.delete()
		# Go back in history
		elif event.scancode == KEY_UP:
			command_history.previous_command()
		# Go forward in history
		elif event.scancode == KEY_DOWN:
			command_history.next_command()
		# Move marker to the right
		elif event.scancode == KEY_RIGHT:
			command_history.marker_right()
		# Move marker to the left
		elif event.scancode == KEY_LEFT:
			command_history.marker_left()
		# Unknown command
		else:
			print("Got unicode %d" % event.unicode)
		# Autocomplete command or file
		if event.scancode == KEY_TAB:
			autocomplete()
		else:
			tab_count = 0

func _process(delta):
	update_console()

# Hide or show the console
func toggle_console():
	print("Toggle console")
	if visible:
		hide()
	else:
		show()

# Get printable characters (only allow ascii)
func get_printable(unicode):
	# Printable ascii are within [32,126] + 10 (LF)
	if (32 <= unicode and unicode <= 126) or unicode == 10:
		# print("Printable character %s" % char(unicode))
		return char(unicode)
	else:
		return ""

# Update console
# Currently only updates the current command to be run
# TODO: Print output as process runs
func update_console():
	if command_thread.is_busy():
		command_text.text = ""
		for i in range(command_thread.stdout.length()):
			var val = command_thread.stdout.read()
			if val == -1:
				output_text.text += "\n"
			else:
				output_text.text += get_printable(val)
	else:
		# Update command text
		command_text.text = command_history.get_command(true, true)

# Run command
func run_command():
	var command = command_history.get_command(false, false)
	print("Run command: %s" % command)
	# Add indicator and command to console history
	output_text.text += command_history.get_command(true, false) + "\n"
	# Add command to command history
	if command != "":
		command_history.add_history(command)
	# Run command
	command_thread.run(command)

# Autocomplete commands and files
func autocomplete():
	tab_count += 1
	# Get current command
	var command = command_history.get_command(false, false)
	# Truncate at marker position
	command = command.substr(0, command_history.marker_position())
	# Match in current command if piped
	command = command.split("|")[-1].lstrip(" ")
	# Match command if first word, else match file
	command = command.split(" ")
	# Check if command or file
	var is_command = command.size() == 1
	command = command[-1]
	# Split completed paths
	var path = ""
	if "/" in command:
		var last_slash = command.find_last("/")
		path += command.substr(0, last_slash)
		command = command.substr(last_slash + 1)

	# Only the first word matches commands, else it is files
	var matches = []
	if is_command:
		matches = command_thread.match_commands(command)
	else:
		matches = command_thread.match_files(path, command)

	# If no match only reset tab_count
	if matches.empty():
		tab_count = 0
	# If unique match, append command
	elif matches.size() == 1:
		var completion = matches[0].substr(command.length())
		if completion == "":
			completion = " "
		command_history.add_characters(completion)
		tab_count = 0
	# Else more than one match, if first time extract common start
	elif tab_count <= 1:
		# Get first element to compare with
		var common = matches.pop_front()
		# Assume all characters match
		var common_length = common.length()
		# Check with all other matches and update length every loop
		for other in matches:
			for i in range(common_length):
				# If they dont match, update length
				if common[i] != other[i]:
					common_length = i
					break
		# Final common is the truncated string
		common = common.substr(0, common_length)
		var completion = common.substr(command.length())
		command_history.add_characters(completion)
	# If no match for more than one try list options
	else:
		# Add indicator and command to console history
		output_text.text += command_history.get_command(true, false) + "\n"
		# Add options to console history
		for i in range(matches.size()):
			if i != 0:
				output_text.text += "\t"
			output_text.text += matches[i]
		output_text.text += "\n"
