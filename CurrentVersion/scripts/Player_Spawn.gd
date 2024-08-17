extends Node2D

var player_scene = preload("res://scenes/player.tscn")
var player = null

func _ready():
	# Delay player instantiation using await
	await get_tree().create_timer(0.1).timeout  # Adjust the delay as needed

	if player == null:
		var new_obj = player_scene.instantiate()
		new_obj.position = position
		get_parent().add_child(new_obj)
		player = new_obj

		# Manually emit the scene_changed signal after instantiating the player
		FootstepSounds.emit_signal("scene_changed", get_tree().current_scene.name)
		print("Emitted scene_changed signal from respawn scene")

		# Manually emit the scene_changed signal after instantiating the player
	#FootstepSounds.custom_signal.connect(Callable(_method_to_call))

	# Manually emit the scene_changed signal after instantiating the player
		#FootstepSounds.emit_signal("scene_changed", get_tree().current_scene.name)
		#print("Emitted scene_changed signal from respawn scene") 
