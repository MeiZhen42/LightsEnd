extends Node2D

var enemy_scene = preload("res://scenes/Enemy.tscn")
var enemy = null
var is_waiting = false  # Track if the timer is active

func _process(_delta):
	if enemy == null and not is_waiting:
		create_enemy_with_delay(15.0)

func create_enemy_with_delay(wait_time: float) -> void:
	# Set the waiting flag to true to prevent multiple spawns
	is_waiting = true

	# Start the timer coroutine with a delay
	await get_tree().create_timer(wait_time).timeout

	# Only create a new enemy if there is no current enemy
	if enemy == null:
		var new_obj = enemy_scene.instantiate()
		new_obj.position = position
		get_parent().add_child(new_obj)
		enemy = new_obj

	# Reset the waiting flag after the enemy is created
	is_waiting = false
