extends Node2D

var player_scene = preload("res://scenes/player.tscn")
var player = null

# Called when the node enters the scene tree for the first time.
func _process(_delta):
	if player == null:
		var new_obj = player_scene.instantiate()
		new_obj.position = position
		get_parent().add_child(new_obj)
		player = new_obj


	# Manually emit the scene_changed signal after instantiating the player
		#FootstepSounds.emit_signal("scene_changed", get_tree().current_scene.name)
		#print("Emitted scene_changed signal from respawn scene") 
