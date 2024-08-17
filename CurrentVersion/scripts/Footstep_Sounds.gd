extends Node2D

@onready var footsteps_grass = $footsteps_grass
@onready var footsteps_wood = $footsteps_wood

var current_surface = null
var is_playing_footstep = false
var tile_map = null 

func _ready():
	# No need to initialize current_scene or connect to scene_changed signal
	pass

func footstep(): 
	if not is_playing_footstep:
		if current_surface == "grass":
			if not footsteps_grass.is_playing():
				footsteps_grass.play()
				is_playing_footstep = true
		elif current_surface == "wood":
			if not footsteps_wood.is_playing():
				footsteps_wood.play()
				is_playing_footstep = true

func stop_footstep():
	print("stop_footstep called")
	if is_playing_footstep:
		if current_surface == "grass":
			footsteps_grass.stop()
		elif current_surface == "wood":
			footsteps_wood.stop()
		is_playing_footstep = false

func set_current_surface(surface):
	current_surface = surface

# Existing functions (you can keep them for now or refactor later if desired)
func footstep_grass():
	if not footsteps_grass.is_playing():
		footsteps_grass.play()

func footstep_wood():
	if not footsteps_wood.is_playing():
		footsteps_wood.play()

func stop_footstep_grass():
	if footsteps_grass.is_playing():
		footsteps_grass.stop()
