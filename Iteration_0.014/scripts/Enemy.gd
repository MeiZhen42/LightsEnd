extends CharacterBody2D

const SPEED = 20.0
const TARGET_REACH_THRESHOLD = 20.0  # Reduced threshold for better target detection
const TARGET_CHANGE_INTERVAL = 4.0  # Time in seconds to wait before changing the target

var target_position : Vector2 = Vector2.ZERO
var roam_area_shape : RectangleShape2D = null
var time_since_last_target_change : float = 0.0
var is_agro : bool = false

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
		
		if is_agro:
			_move_towards_target(_delta)
		else:
			_roam_area(_delta)

		# Check if we have reached the target position
		if global_position.distance_to(target_position) < TARGET_REACH_THRESHOLD:
			if time_since_last_target_change >= TARGET_CHANGE_INTERVAL and not is_agro:
				_set_random_target_position()
				time_since_last_target_change = 0.0

func _move_towards_target(_delta):
	if target_position:
		var direction = (target_position - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()  # Ensure velocity is passed to move_and_slide
		print("Moving towards target: ", target_position, "Direction: ", direction, "Velocity: ", velocity)
	else:
		print("No target position set for agro.")

func _set_random_target_position():
	if roam_area_shape:
		var area_bounds = roam_area_shape.extents
		target_position = global_position + Vector2(
			randf_range(-area_bounds.x, area_bounds.x),
			randf_range(-area_bounds.y, area_bounds.y)
		)
		# Ensure the target position is within the roam area
		target_position = _clamp_position_to_area(target_position)
		print("New roam target position set: ", target_position)

func _clamp_position_to_area(position: Vector2) -> Vector2:
	if roam_area_shape:
		var area_bounds = roam_area_shape.extents
		var clamped_x = clamp(position.x, global_position.x - area_bounds.x, global_position.x + area_bounds.x)
		var clamped_y = clamp(position.y, global_position.y - area_bounds.y, global_position.y + area_bounds.y)
		return Vector2(clamped_x, clamped_y)
	return position

func _on_agro_area_entered(body):
	print("Entered agro area")
	if body.is_in_group("player"):
		print("Player detected!")
		target_position = body.global_position
		is_agro = true
		# Reset the time since last target change
		time_since_last_target_change = 0.0

func _on_agro_area_exited(body):
	print("Exited agro area")
	if body.is_in_group("player"):
		print("Player lost!")
		is_agro = false
		_set_random_target_position()

func _roam_area(_delta):
	# Handle roaming logic if not in agro mode
	if not is_agro:
		if global_position.distance_to(target_position) < TARGET_REACH_THRESHOLD:
			if time_since_last_target_change >= TARGET_CHANGE_INTERVAL:
				_set_random_target_position()
				time_since_last_target_change = 0.0


func _on_area_2d_body_entered(body):
	pass # Replace with function body.


func _on_area_2d_body_exited(body):
	pass # Replace with function body.
