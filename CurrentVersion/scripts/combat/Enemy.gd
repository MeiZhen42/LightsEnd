extends CharacterBody2D

const SPEED = 20.0
const TARGET_REACH_THRESHOLD = 1800.0
const TARGET_CHANGE_INTERVAL = 4.0  # Time in seconds to wait before changing the target

var target_position : Vector2 = Vector2.ZERO
var roam_area_shape : RectangleShape2D = null
var time_since_last_target_change : float = 0.0

func _ready():
	# Set the roam_area_shape to the CollisionShape2D's shape
	var collision_shape = $CollisionShape2D
	if collision_shape and collision_shape.shape and collision_shape.shape is RectangleShape2D:
		roam_area_shape = collision_shape.shape
	else:
		print("Error: CollisionShape2D with RectangleShape2D not found")

	if roam_area_shape:
		_set_random_target_position()

func _physics_process(_delta):
	if roam_area_shape:
		time_since_last_target_change += _delta
		_move_towards_target(_delta)

		# Check if we have reached the target position
		if global_position.distance_to(target_position) < TARGET_REACH_THRESHOLD:
			if time_since_last_target_change >= TARGET_CHANGE_INTERVAL:
				_set_random_target_position()
				time_since_last_target_change = 0.0

func _move_towards_target(_delta):
	if target_position:
		var direction = (target_position - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()

func _set_random_target_position():
	if roam_area_shape:
		var area_bounds = roam_area_shape.extents
		target_position = global_position + Vector2(
			randf_range(-area_bounds.x, area_bounds.x),
			randf_range(-area_bounds.y, area_bounds.y)
		)
		# Ensure the target position is within the roam area
		target_position = _clamp_position_to_area(target_position)

func _clamp_position_to_area(position: Vector2) -> Vector2:
	if roam_area_shape:
		var area_bounds = roam_area_shape.extents
		var clamped_x = clamp(position.x, global_position.x - area_bounds.x, global_position.x + area_bounds.x)
		var clamped_y = clamp(position.y, global_position.y - area_bounds.y, global_position.y + area_bounds.y)
		return Vector2(clamped_x, clamped_y)
	return position
