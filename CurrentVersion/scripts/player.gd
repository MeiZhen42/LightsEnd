extends CharacterBody2D

const SPEED = 100.0
const ATTACK_RADIUS = 1.0
const ATTACK_DAMAGE = 10

var health = 100  # Initialize health
var current_direction = "none"
var safe: bool = true
var is_attacking: bool = false  # Track whether the player is currently attacking

@onready var interact_ui = $'interactUI'
@onready var inventory_ui = $'inventoryUI'
@onready var footstep_player := $AudioStreamPlayer2D
@onready var sanity_bar = $SanityBar
@onready var attack_area = $AttackArea  # Reference to AttackArea node
@onready var attack_collision_shape = $AttackArea/CollisionShape2D  # Reference to the CollisionShape2D

const sanity_decline: float = 1.5
const sanity_regain: float = 1

func _ready():
	Global.set_player_reference(self)
	sanity_bar.min_value = 0
	sanity_bar.max_value = 100
	sanity_bar.value = sanity_bar.max_value
	
	print("Enemy initialized:", self.name)
	
	# Debug: Check if footstep_player and attack_area are correctly initialized
	if footstep_player:
		print("Footstep player initialized successfully")
	else:
		print("Footstep player is null")
	
	if attack_area:
		print("Attack area initialized successfully")
		attack_area.hide()  # Hide the attack area initially
		attack_collision_shape.disabled = true  # Disable the attack area collision
	else:
		print("Attack area is null")

func _physics_process(_delta):
	player_movement(_delta)
	
	 # Update attack_area position to follow player
	if attack_area:
		# Set the attack area position relative to the player
		attack_area.position = Vector2(0, -ATTACK_RADIUS)
		attack_area.position.y -= 0  # Adjust this value based on your needs
		
		 # Update attack_area rotation based on player direction
		match current_direction:
			"right":
				attack_area.rotation = -PI / 2  # 90 degrees
				attack_area.position.y -= -10
			"left":
				attack_area.rotation = PI / 2  # -90 degrees
				attack_area.position.y -= -10
			"down":
				attack_area.rotation = 0
			"up":
				attack_area.rotation = PI  # 180 degrees 
		
	# Check for attack input
	if Input.is_action_just_pressed("attack"):
		attack()

func _process(_delta):
	# Adjust sanity
	if safe:
		sanity_bar.value += sanity_regain * _delta
	else:
		sanity_bar.value -= sanity_decline * _delta
		if sanity_bar.value <= sanity_bar.min_value:
			## ToDo: do something when sanity reaches 0
			pass
	
	var shade: float = (sanity_bar.value / sanity_bar.max_value)
	sanity_bar.get_theme_stylebox("fill").bg_color = Color((69 - 63 * shade)/255, (3 + 155 * shade)/255, (3 + 89 * shade)/255)
	
	if sanity_bar.value < sanity_bar.max_value:
		sanity_bar.show()
	else:
		sanity_bar.hide()

func player_movement(_delta):
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		current_direction = "right"
		play_animation(1)
		velocity.x = SPEED
	elif Input.is_action_pressed("ui_left"):
		current_direction = "left"
		play_animation(1)
		velocity.x = -SPEED
	elif Input.is_action_pressed("ui_down"):
		current_direction = "down"
		play_animation(1)
		velocity.y = SPEED
	elif Input.is_action_pressed("ui_up"):
		current_direction = "up"
		play_animation(1)
		velocity.y = -SPEED
	else:
		play_animation(0)
	
	if velocity != Vector2.ZERO:
		if footstep_player and not footstep_player.is_playing():
			footstep_player.play()
	else:
		if footstep_player:
			footstep_player.stop()
	
	self.velocity = velocity
	move_and_slide()

func play_animation(movement):
	var direction = current_direction
	var animation = $AnimatedSprite2D
	
	if direction == "right":
		animation.flip_h = false
		if movement == 1:
			animation.play("side_walk")
		elif movement == 0:
			animation.play("side_idle")
			
	elif direction == "left":
		animation.flip_h = true
		if movement == 1:
			animation.play("side_walk")
		elif movement == 0:
			animation.play("side_idle")    
			
	elif direction == "down":
		animation.flip_h = false
		if movement == 1:
			animation.play("front_walk")
		elif movement == 0:
			animation.play("front_idle")
			
	elif direction == "up":
		animation.flip_h = false
		if movement == 1:
			animation.play("back_walk")
		elif movement == 0:
			animation.play("back_idle")

func _input(event):
	if event.is_action_pressed("q"):
		inventory_ui.visible = !inventory_ui.visible
		get_tree().paused = !get_tree().paused

func attack():
	if attack_area:
		print("Attack initiated")
		is_attacking = true  # Set the attacking flag to true
		#attack_area.position = position + Vector2(-120, -ATTACK_RADIUS)  # Adjust offset if needed
		#attack_area.position.y -= 250  # Adjust this value based on your needs
		attack_area.scale = Vector2(ATTACK_RADIUS, ATTACK_RADIUS)
		attack_collision_shape.disabled = false  # Enable the attack area collision
		attack_area.show()
		print("Attack area shown at position: ", attack_area.position)

		# Hide it after a short delay to simulate the attack duration
		await get_tree().create_timer(0.1).timeout
		attack_area.hide()
		attack_collision_shape.disabled = true  # Disable the attack area collision
		is_attacking = false  # Reset the attacking flag
		print("Attack area hidden")
	else:
		print("Error: AttackArea node is not initialized")

func _on_attack_area_body_entered(body):
	if is_attacking:  # Only apply damage if the player is attacking
		if body.is_in_group("enemies"):
			print("Enemy detected in attack area, applying damage")
			if body.has_method("take_damage"):
				print("Enemy has take_damage method, applying", ATTACK_DAMAGE, "damage")
				body.take_damage(ATTACK_DAMAGE)
			else:
				print("Error: Enemy does not have take_damage method!")
		else:
			print("Non-enemy body entered attack area:", body.name)
	else:
		print("Body entered attack area, but player is not attacking")

func take_damage(amount):
	# Implement health reduction logic
	health -= amount
	if health <= 0:
		die()  # Handle death

# Additional functions
func die():
	queue_free()  # Example: remove the player from the scene
