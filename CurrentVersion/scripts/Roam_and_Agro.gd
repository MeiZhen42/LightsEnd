extends CharacterBody2D

const ROAM_SPEED = 30.0
const AGRO_SPEED = 95.0
const TARGET_REACH_THRESHOLD = 1800.0
const TARGET_CHANGE_INTERVAL = 4.0  # Time in seconds to wait before changing the target
const MAX_HEALTH = 150.0
const RESPAWN_DELAY = 5.0  # Time in seconds before respawning
const RESPAWN_RADIUS = 600
const MAX_RESPAWN_ATTEMPTS = 10  # Maximum attempts to find a valid spawn point

var roam_area_shape: RectangleShape2D = null
var roam_area: Area2D = null
var target_position: Vector2 = Vector2.ZERO
var time_since_last_target_change: float = 0.0
var is_agro: bool = false
var agro_target: Node2D = null
var start_position: Vector2 = Vector2.ZERO
var health: float = MAX_HEALTH
var enemy_damage_amount = 10
var respawn_timer: float = 0.0  # Timer for respawn delay

@onready var health_bar := $HealthBar  # Adjust path to your ProgressBar node
@onready var sprite := $Sprite2D  # Reference to the Sprite node
@onready var attack_box := $AttackBox
@onready var collision_shape := $Body  # Reference to the CollisionShape2D
@onready var Attack_Box := $AttackBox/CollisionShape2D  # Reference to the CollisionShape2D

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

func _on_AttackBox_enemy_collided(other_body):
	if other_body.is_in_group("player"):
		print("Player detected in attack box")
		other_body.take_damage(enemy_damage_amount)

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

	# Only show the health bar if the enemy is alive (health > 0) and the sprite is visible
	health_bar.visible = health > 0 and (sprite and sprite.visible)

func _physics_process(_delta):
	if roam_area_shape:
		time_since_last_target_change += _delta
		
		# Check if the NPC is outside the roam area
		if !_is_within_roam_area():
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

func _is_within_roam_area():
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

	# Disable collisions and hide the sprite
	disable_collisions()
	hide_sprite()

	# Wait for respawn delay
	await get_tree().create_timer(RESPAWN_DELAY).timeout

	# Find a valid spawn position
	var new_position = get_valid_spawn_position(start_position, RESPAWN_RADIUS)

	# Set new position and reset enemy state
	global_position = new_position
	enable_collisions()
	show_sprite()
	health = MAX_HEALTH
	health_bar.value = health

# Function to find a valid spawn position within the specified radius
func find_valid_spawn_position() -> Vector2:
	var attempt = 0
	while attempt < MAX_RESPAWN_ATTEMPTS:
		var potential_position = get_random_position_in_radius(start_position, RESPAWN_RADIUS)
		if is_position_valid(potential_position):
			return potential_position
		attempt += 1
	return start_position  # Fallback to start position if no valid position is found

func is_position_valid(position: Vector2) -> bool:
	# Create a small circle shape for collision checking
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 10  # Adjust the radius as needed

	# Set up the parameters for the shape query
	var shape_params = PhysicsShapeQueryParameters2D.new()
	shape_params.shape = circle_shape
	shape_params.transform.origin = position
	shape_params.exclude = [self]  # Exclude self from collision check
	shape_params.collision_mask = 0xFFFFFFFF  # Check against all layers

	# Get the direct space state for collision detection
	var space_state = get_world_2d().direct_space_state

	# Use intersect_shape to check for collisions
	var result = space_state.intersect_shape(shape_params)

	# Return true if no collisions are detected
	return result.size() == 0

func get_valid_spawn_position(center: Vector2, radius: float) -> Vector2:
	for attempt in range(10):  # Try up to 10 times
		var new_position = get_random_position_in_radius(center, radius)
		if is_position_valid(new_position):
			return new_position
	
	# If no valid position found, return the start position as a fallback
	print("Could not find valid position after 10 attempts. Using start position.")
	return center

# Function to get a random position within a specified radius
func get_random_position_in_radius(center: Vector2, radius: float) -> Vector2:
	var random_angle = randf_range(0, PI * 2)
	var random_distance = randf_range(0, radius)
	var offset = Vector2(cos(random_angle), sin(random_angle)) * random_distance
	return center + offset

func disable_collisions():
	# Disable the collision shapes
	if attack_box:
		attack_box.collision_layer = 0
		attack_box.collision_mask = 0
		attack_box.visible = false
	
	if collision_shape:
		$Body.set_deferred("disabled", true)

func enable_collisions():
	# Restore the collision shapes
	if attack_box:
		attack_box.collision_layer = 10  # Set this to the appropriate layer
		attack_box.collision_mask = 1 | 2   # Set this to the appropriate mask
		attack_box.visible = true

	if collision_shape:
		$Body.set_deferred("disabled", false)

func hide_sprite():
	if sprite:
		sprite.visible = false
		
func show_sprite():
	if sprite:
		sprite.visible = true


