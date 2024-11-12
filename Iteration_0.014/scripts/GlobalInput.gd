# GlobalInput.gd
extends Node

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # Process in all states
	set_process_input(true)  # Enable input processing
	print("GlobalInput.gd is ready")
	
func _input(event):
	if event.is_action_pressed("pause_game"):
		print("Pause key pressed")
		if not get_tree().paused:
			print("Showing pause screen")
			PauseScreen.show_pause_screen()
		else:
			print("Hiding pause screen")
			PauseScreen.hide_pause_screen()
