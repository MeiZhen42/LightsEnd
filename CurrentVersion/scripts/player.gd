extends CharacterBody2D

const SPEED = 100.0
const ATTACK_RADIUS = 30.0
const ATTACK_DAMAGE = 10

var health = 100  # Initialize health
var current_direction = "none"
var safe: bool = true

@onready var interact_ui = $'interactUI'
@onready var inventory_ui = $'inventoryUI'
@onready var footstep_player := $AudioStreamPlayer2D
@onready var sanity_bar = $SanityBar
@onready var attack_area = $AttackArea  # Reference to AttackArea node

const sanity_decline: float = 1.5
const sanity_regain: float = 1

func _ready():
	Global.set_player_reference(self)
	sanity_bar.min_value = 0
	sanity_bar.max_value = 100
	sanity_bar.value = sanity_bar.max_value
	
	# Debug: Check if footstep_player and attack_area are correctly initialized
	if footstep_player:
		print("Footstep player initialized successfully")
	else:
		print("Footstep player is null")
	
	if attack_area:
		print("Attack area initialized successfully")
		attack_area.hide()  # Hide the attack area initially
	else:
		print("Attack area is null")
	

func _physics_process(_delta):
	player_movement(_delta)

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
	attack_area.position = position
	attack_area.scale = Vector2(ATTACK_RADIUS, ATTACK_RADIUS)
	attack_area.show()
	
	# Hide it after a short delay to simulate the attack duration
	await get_tree().create_timer(0.1).timeout
	attack_area.hide()

func _on_attack_area_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(ATTACK_DAMAGE)

func take_damage(amount):
	# Implement health reduction logic
	health -= amount
	if health <= 0:
		die()  # Handle death

# Additional functions
func die():
	queue_free()  # Example: remove the player from the scene
