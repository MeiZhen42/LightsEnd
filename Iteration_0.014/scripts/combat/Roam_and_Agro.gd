extends CharacterBody2D

const ROAM_SPEED = 20.0
const AGRO_SPEED = 40.0
const TARGET_REACH_THRESHOLD = 1800.0
const TARGET_CHANGE_INTERVAL = 4.0  # Time in seconds to wait before changing the target
const MAX_HEALTH = 100.0

var roam_area_shape : RectangleShape2D = null
var roam_area : Area2D = null
var target_position : Vector2 = Vector2.ZERO
var time_since_last_target_change : float = 0.0
var is_agro : bool = false
var agro_target : Node2D = null
var start_position : Vector2 = Vector2.ZERO
var health : float = MAX_HEALTH

@onready var health_bar := $HealthBar  # Adjust path to your ProgressBar node
@onready var sprite := $Sprite2D  # Reference to the Sprite node

func _ready():
	roam_area = $RoamAreaPlaceholder.get_node("RoamArea")
	if roam_area:
		var collision_shape = roam_area.get_node("CollisionShape2D")
		if collision_shape and collision_shape.shape:
			roam_area_shape = collision_shape.shape
		else:
			print("Error: CollisionShape2D with shape not found")
	else:
		print("Error: RoamArea node not found")

	if health_bar:
		health_bar.min_value = 0
		health_bar.max_value = MAX_HEALTH
		health_bar.value = health  # Set the initial value to current health
	else:
		print("Error: HealthBar node not found or incorrect path.")

func _flip_sprite():
	if sprite:
		# Flip the sprite based on movement direction
		if velocity.x > 0:
			sprite.flip_h = true  # Facing right
		elif velocity.x < 0:
			sprite.flip_h = false  # Facing left

func _process(_delta):
	# Update health bar color based on health value
	if health_bar:
		var shade: float = (health_bar.value / health_bar.max_value)
		health_bar.get_theme_stylebox("fill").bg_color = Color((69 - 63 * shade)/255, (3 + 155 * shade)/255, (3 + 89 * shade)/255)
		
		if health_bar.value < health_bar.max_value:
			health_bar.show()
		else:
			health_bar.hide()

func _physics_process(_delta):
	if roam_area_shape:
		time_since_last_target_change += _delta
		
		# Check if the NPC is outside the roam area
		if !_is_within_roam_area(global_position):
			print("Outside roam area, returning to start position.")
			target_position = start_position
			is_agro = false  # Stop agro if returning to start position

		if is_agro and agro_target:
			target_position = agro_target.global_position
			_move_towards_target(_delta, AGRO_SPEED)
		else:
			_roam_area(_delta)
		
		# Check if we have reached the target position
		if global_position.distance_to(target_position) < TARGET_REACH_THRESHOLD:
			if time_since_last_target_change >= TARGET_CHANGE_INTERVAL:
				_set_random_target_position()
				time_since_last_target_change = 0.0

		# Call _flip_sprite to update sprite direction based on movement
		_flip_sprite()

func _move_towards_target(_delta, speed: float):
	if target_position:
		var direction = (target_position - global_position).normalized()
		velocity = direction * speed
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

func _roam_area(_delta):
	# This function handles roaming if not in agro mode
	if not is_agro:
		_move_towards_target(_delta, ROAM_SPEED)

func _is_within_roam_area(position: Vector2) -> bool:
	if roam_area_shape:
		var area_bounds = roam_area_shape.extents
		var left_bound = global_position.x - area_bounds.x
		var right_bound = global_position.x + area_bounds.x
		var top_bound = global_position.y - area_bounds.y
		var bottom_bound = global_position.y + area_bounds.y
		return position.x >= left_bound and position.x <= right_bound and position.y >= top_bound and position.y <= bottom_bound
	return false

func _on_agro_area_entered(body):
	print("Entered agro area")
	if body.is_in_group("player"):
		print("Player detected!")
		is_agro = true
		agro_target = body
		target_position = body.global_position

func _on_agro_area_exited(body):
	print("Exited agro area")
	if body.is_in_group("player"):
		print("Player lost!")
		is_agro = false
		target_position = Vector2.ZERO  # Clear target_position when player exits

func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy took", amount, "damage, remaining health:", health)

	if health_bar:
		health_bar.value = health
	else:
		print("Error: HealthBar node not found or incorrect path.")

	if health <= 0:
		die()

func die():
	print("NPC died")
	queue_free()  # Removes the NPC from the scene
