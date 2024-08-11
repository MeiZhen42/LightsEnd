extends Node2D

@onready var footsteps_grass = $footsteps_grass
@onready var footsteps_wood = $footsteps_wood

func footstep_grass():
	if not footsteps_grass.is_playing():
		footsteps_grass.play()

func footstep_wood():
	if not footsteps_wood.is_playing():
		footsteps_wood.play()

func stop_footstep_grass():
	if footsteps_grass.is_playing():
		footsteps_grass.stop()
