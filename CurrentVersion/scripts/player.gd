extends CharacterBody2D

var SPEED = 100.0
var ATTACK_RADIUS = 1.0
var ATTACK_DAMAGE = 9

var CRIT_CHANCE = 0.1  # 10% chance for a critical hit
var CRIT_MULTIPLIER = 2.0  # Critical hits deal 2x damage
var health = 100  # Initialize health
var max_health = 100  # Maximum health
var current_direction = "none"
var safe: bool = true
var is_attacking: bool = false  # Track whether the player is currently attacking
var starting_position: Vector2  # Store the player's starting position
var x_offset: float = 125.0  # X offset for respawn
var y_offset: float = 180.0  # Y offset for respawn
var experience = 0
var level = 1
var experience_needed = 100

const LEVEL_UP_TEXT_SCENE_PATH = "res://scenes/LevelUpText.tscn"
const DAMAGE_TEXT_SCENE_PATH = "res://scenes/DamageText.tscn"  # Path to the DamageText scene
const sword_offsets = {
	"right": Vector2(20, 0),
	"left": Vector2(-20, 0),
	"down": Vector2(0, 20),
	"up": Vector2(0, -20)
}

@onready var interact_ui = $'interactUI'
@onready var inventory_ui = $'inventoryUI'
@onready var footstep_player := $AudioStreamPlayer2D
@onready var sanity_bar = $SanityBar
@onready var attack_area = $AttackArea  # Reference to AttackArea node
@onready var attack_collision_shape = $AttackArea/CollisionShape2D  # Reference to the CollisionShape2D
@onready var health_bar = $HealthBar  # Reference to HealthBar node
@onready var sword_swing_effect := $SwordSwing  # Adjust path to your sword swing effect node
@onready var level_up_text = $LevelUpText/LevelUpLabel  # Reference to the LevelUpLabel
@onready var level_up_animation_player = $LevelUpText/LevelUpAnimation  # Reference to the LevelUpAnimation
@onready var level_label = $PlayerStatsUI/VBoxContainer/Level  # Adjust the path as necessary
@onready var hp_label = $PlayerStatsUI/VBoxContainer/HP  # Assuming Label2 is for HP
@onready var crit_chance_label = $PlayerStatsUI/VBoxContainer/Crit  # Assuming Label3 is for Crit Chance
@onready var damage_label = $PlayerStatsUI/VBoxContainer/Damage  # Assuming Label4 is for Damage
@onready var player_stats_ui = $PlayerStatsUI # Adjust path if needed$PlayerStatsUI/VBoxContainer





const sanity_decline: float = 1.5
const sanity_regain: float = 1

func _ready():
	Global.set_player_reference(self)
	sanity_bar.min_value = 0
	sanity_bar.max_value = 100
	sanity_bar.value = sanity_bar.max_value
	
	if health_bar:
		health_bar.min_value = 0
		health_bar.max_value = max_health
		health_bar.value = health  # Set initial health value
	else:
		print("Error: HealthBar node not found or incorrect path.")
	
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
	
	if sword_swing_effect:
		sword_swing_effect.visible = false  # Ensure the effect is hidden initially

		update_ui()
		

func update_ui():
	# Check each label to ensure it's not null before setting text
	if level_label:
		level_label.text = "Level: " + str(level)
	else:
		print("Error: level_label is null")

	if hp_label:
		hp_label.text = "HP: " + str(health) + "/" + str(max_health)
	else:
		print("Error: hp_label is null")

	if crit_chance_label:
		crit_chance_label.text = "Crit Chance: %.2f%%" % (CRIT_CHANCE * 100)  # Format with two decimal places
	else:
		print("Error: crit_chance_label is null")

	if damage_label:
		damage_label.text = "Damage: " + str(ATTACK_DAMAGE)
	else:
		print("Error: damage_label is null")

func toggle_stats_ui():
	# Toggle the visibility of the player stats UI
	if player_stats_ui:
		player_stats_ui.visible = not player_stats_ui.visible

func _physics_process(_delta):
	player_movement(_delta)
	
	if attack_area:
		# Set the attack area position relative to the player
		attack_area.position = Vector2(0, -ATTACK_RADIUS)
		
		# Update attack_area rotation based on player direction
		match current_direction:
			"down":
				attack_area.rotation = 0 #-PI / 2  # right
			"up":
				attack_area.rotation = PI #PI / 2  # left
			"right":
				attack_area.rotation = -PI / 2 #0 # down
			"left":
				attack_area.rotation = PI / 2  # up
		
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

# Check for "ui_toggle_stats" action to toggle stats UI
	if event.is_action_pressed("ui_toggle_stats"):
		toggle_stats_ui()
		
func attack():
	if attack_area:
		print("Attack initiated")
		is_attacking = true  # Set the attacking flag to true
		attack_area.scale = Vector2(ATTACK_RADIUS, ATTACK_RADIUS)
		attack_collision_shape.disabled = false  # Enable the attack area collision
		attack_area.show()

		# Update sword swing effect rotation and position
		if sword_swing_effect:
			sword_swing_effect.visible = true
			sword_swing_effect.rotation = get_sword_rotation()

			# Check if current_direction is a valid key in sword_offsets
			if sword_offsets.has(current_direction):
				sword_swing_effect.position = sword_offsets[current_direction]
			else:
				print("Error: current_direction is not a valid key in sword_offsets. Current direction:", current_direction)
			
			# Uncomment if you use an AnimationPlayer for the sword swing effect
			# sword_swing_effect.play("swing")
		
		# Hide the attack area and sword swing effect after a longer delay
		await get_tree().create_timer(0.5).timeout  # Increase this value as needed
		attack_area.hide()
		attack_collision_shape.disabled = true  # Disable the attack area collision
		
		if sword_swing_effect:
			sword_swing_effect.visible = false  # Hide the sword swing effect
		is_attacking = false  # Reset the attacking flag
		print("Attack area hidden")

		# Critical hit logic
		if randf() < CRIT_CHANCE:  # Random float between 0 and 1
			print("Critical hit!")
			deal_damage(ATTACK_DAMAGE * CRIT_MULTIPLIER)
		else:
			deal_damage(ATTACK_DAMAGE)
	else:
		print("Error: AttackArea node is not initialized")
		
func deal_damage(damage_amount: int):
	# Optionally, you can add visual or sound effects for damage here
	print("Dealing", damage_amount, "damage")
	# Logic to deal damage to enemies
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("enemies"):
			print("Enemy detected in attack area, applying damage")
			if body.has_method("take_damage"):
				body.take_damage(damage_amount)
				display_damage_text(body.global_position, damage_amount)
				gain_experience(10)  # Example XP gain
			else:
				print("Error: Enemy does not have take_damage method!")

func gain_experience(amount: int):
	experience += amount
	print("Gained ", amount, " experience. Total: ", experience)
	while experience >= experience_needed:
		level_up()

func level_up():
	level += 1
	experience -= experience_needed  # Subtract the required exp for current level
	experience_needed = int(experience_needed * 1.1)  # Increase exp needed for next level by 10%
	max_health += 20  # Increase max health
	health = max_health  # Restore health to new max health
	CRIT_CHANCE += 0.01  # Increase critical chance by 1%
	CRIT_MULTIPLIER += 0.1  # Increase critical multiplier by 0.1
	ATTACK_DAMAGE += 1  # Increase attack damage by 1
	show_level_up_text()
	update_ui()
	print("Leveled up! Level ", level, ", Health ", health, ", Next Level XP Needed: ", experience_needed, ", Crit Chance: ", CRIT_CHANCE, ", Crit Multiplier: ", CRIT_MULTIPLIER, ", Attack Damage: ", ATTACK_DAMAGE)

func show_level_up_text():
	level_up_text.visible = true
	level_up_animation_player.play("Show_Level_Up")

func _on_LevelUpAnimation_animation_finished(anim_name):
	if anim_name == "Show_Level_Up":
		level_up_text.visible = false  # Hide the level-up text after animation

func get_sword_rotation() -> float:
	match current_direction:
		"right":
			return PI  #-PI / 2  # 90 degrees DOWN
		"left":
			return 0 #PI / 2  # -90 degrees UP
		"down":
			return -PI / 2  # 0 degrees LEFT
		"up":
			return PI / 2  # 180 degrees RIGHT
	return 0

func _on_attack_area_body_entered(body):
	if is_attacking:  # Only apply damage if the player is attacking
		if body.is_in_group("enemies"):
			print("Enemy detected in attack area, applying damage")
			if body.has_method("take_damage"):
				print("Enemy has take_damage method, applying", ATTACK_DAMAGE, "damage")
				body.take_damage(ATTACK_DAMAGE)
				display_damage_text(body.global_position, ATTACK_DAMAGE)
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

	# Update health bar value (if it exists)
	if health_bar:
		health_bar.value = health

	# Optional: Visual feedback on taking damage
	# (Replace with your desired effect)
	# self.modulate = Color.RED  # Change color for a brief moment
	# play_sound("damage.wav")  # Play a sound effect

func die():
	# Handle death (e.g., animation, game over, respawn)
	print("Player died!")
	position = starting_position + Vector2(x_offset, y_offset)  # Respawn at the adjusted starting position
	health = max_health  # Reset health
	if health_bar:
		health_bar.value = health  # Reset health bar value
	# Optionally, you could also reset other player state here, if needed

func display_damage_text(position: Vector2, damage_amount: int):
	# Load the DamageText scene
	var damage_text_scene = load(DAMAGE_TEXT_SCENE_PATH)
	if damage_text_scene:
		var damage_text_instance = damage_text_scene.instantiate()
		if damage_text_instance:
			var label = damage_text_instance.get_node("Label")  # Ensure your Label is named "Label"
			if label:
				label.text = str(damage_amount)
				damage_text_instance.position = position
				damage_text_instance.z_index = 1  # Ensure the damage text is rendered above other elements
				get_tree().current_scene.add_child(damage_text_instance)
				
				# Access AnimationPlayer node
				var anim_player = damage_text_instance.get_node("AnimationPlayer")
				if anim_player:
					anim_player.play("damage_text_animation")  # Play the animation
					
					# Optionally, remove the damage text after animation
					await anim_player.animation_finished  # Wait until animation is finished
					damage_text_instance.queue_free()  # Remove the text after animation
				else:
					print("Error: AnimationPlayer node not found in DamageText scene")
			else:
				print("Error: Label node not found in DamageText scene")
		else:
			print("Error: Could not instantiate DamageText scene")
	else:
		print("Error: DamageText scene not found at", DAMAGE_TEXT_SCENE_PATH)

