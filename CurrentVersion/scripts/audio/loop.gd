extends AudioStreamPlayer

func _ready():
	if stream:
		stream.loop = false  # Ensure the stream's loop property is off
	play()

func _on_finished():
	# Restart the stream when it finishes
	play()

#func _process(delta):
	# Optionally, debug information to track the time
	print("Playing time: ", get_playback_position())
