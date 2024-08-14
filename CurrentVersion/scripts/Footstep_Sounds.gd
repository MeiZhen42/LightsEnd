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
	if is_playing_footstep:
		if current_surface == "grass":
			footsteps_grass.stop()
		elif current_surface == "wood":
			footsteps_wood.stop()
		is_playing_footstep = false

func set_current_surface(surface):
	current_surface = surface

# You'll likely remove this function or adapt it based on how you get the 'tile_map' reference
func detect_surface():
	if tile_map: 
		var player_cell_pos = tile_map.to_local(global_position).floor()
		print("Player Cell Position:", player_cell_pos) 

		var cell = tile_map.get_cell_source_id(0, player_cell_pos) 
		print("Cell ID:", cell) 

		if cell != -1: 
			var atlas_coords = tile_map.get_cell_atlas_coords(0, player_cell_pos)
			print("Current Tile Atlas Coords:", atlas_coords) 
			if atlas_coords == Vector2i(0, 0):
				print("Walking on Grass")
				set_current_surface("grass")
			elif atlas_coords == Vector2i(50, 0):
				print("Walking on Wood")
				set_current_surface("wood")
		else:
			print("Player is on an empty cell") 

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
