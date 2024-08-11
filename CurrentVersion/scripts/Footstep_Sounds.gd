extends Node2D

@onready var footsteps_grass = $footsteps_grass
@onready var footsteps_wood = $footsteps_wood

var current_scene = null 

var is_playing_footstep = false 

func _ready():
	current_scene = get_tree().current_scene.name  # Get the initial scene name

func _on_scene_changed(new_scene_name):
	current_scene = new_scene_name

func footstep(): 
	if not is_playing_footstep:
		if current_scene == "outside":
			if not footsteps_grass.is_playing():
				footsteps_grass.play()
				is_playing_footstep = true
		elif current_scene == "empty_inside":
			if not footsteps_wood.is_playing():
				footsteps_wood.play()
				is_playing_footstep = true

func stop_footstep():
	if is_playing_footstep:
		if current_scene == "outside":
			footsteps_grass.stop()
		elif current_scene == "empty_inside":
			footsteps_wood.stop()
		is_playing_footstep = false

