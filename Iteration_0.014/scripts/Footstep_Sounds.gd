extends Node2D

@onready var footsteps_grass = $footsteps_grass
@onready var footsteps_wood = $footsteps_wood

var current_surface = null
var is_playing_footstep = false

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
	if is_playing_footstep:
		if current_surface == "grass" and footsteps_grass.is_playing():
			footsteps_grass.stop()
		elif current_surface == "wood" and footsteps_wood.is_playing():
			footsteps_wood.stop()
		is_playing_footstep = false

func set_current_surface(surface):
	if current_surface != surface:
		stop_footstep()
		current_surface = surface
