extends Control

onready var output_text = $ScrollContainer/VBoxContainer/History
onready var command_text = $ScrollContainer/VBoxContainer/CurrentCommand

var command_thread
var command_history

# Clear commands at start
func _ready():
	# Load the command classes
	command_thread = load("command_thread.gd").new()
	command_history = load("command_history.gd").new()
	
	# Clear console
	output_text.clear()
	command_text.clear()
	update_console()

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
			command_history.add_character(character)
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
		# Autocomplete command or file
		elif event.scancode == KEY_TAB:
			print("KEY_TAB")
			# TODO: Tab complete commands and files
		# Unknown command
		else:
			print("Got unicode %d" % event.unicode)
		# Always update console
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
	# Printable ascii are within [32,126]
	if 32 <= unicode and unicode <= 126:
		print("Printable character %s" % char(unicode))
		return char(unicode)
	else:
		return ""

# Update console
# Currently only updates the current command to be run
# TODO: Print output as process runs
func update_console():
	# Update command text
	command_text.text = command_history.get_command(true, true)

# Run command
func run_command():
	print("Run command: %s" % command_history.get_command(false, false))
	# Run command here
	if output_text.text.length() > 0:
		output_text.text += "\n"
	output_text.text += command_history.get_command(true, false)
	command_thread.run(command_history.get_command(false, false))
	# When done
	if command_history.get_command(false, false) != "":
		command_history.add_history(command_history.get_command(false, false))
