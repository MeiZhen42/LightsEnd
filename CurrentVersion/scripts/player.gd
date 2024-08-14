extends CharacterBody2D

var SPEED = 800.0
var ATTACK_RADIUS = 1.0
var ATTACK_DAMAGE = 9

var CRIT_CHANCE = 0.1  # 10% chance for a critical hit
var CRIT_MULTIPLIER = 2.0  # Critical hits deal 2x damage
var health = 100  # Initialize health
var max_health = 100  # Maximum health
var current_direction = "none"
var safe: bool = true
var is_attacking: bool = false  # Track whether the player is currently attacking
var experience = 0
var level = 1
var experience_needed = 100
var is_playing_footstep = false
var should_play_footstep = false

const LEVEL_UP_TEXT_SCENE_PATH = "res://scenes/LevelUpText.tscn"
const DAMAGE_TEXT_SCENE_PATH = "res://scenes/DamageText.tscn"  # Path to the DamageText scene

# Offsets for the sword relative to the player
const sword_offsets = {
	"right": Vector2(0, 0),
	"left": Vector2(0, 0),
	"down": Vector2(0, 0),
	"up": Vector2(0, 0)
}

# Rotations for the sword relative to the player direction
const sword_rotations = {
	"right": -PI / 2, #0, #down
	"left": PI / 2, #0, #PI, #up
	"down": 0, # PI / 2, #left
	"up": PI, #-PI / 2 #right
}

@onready var interact_ui = $'interactUI'
@onready var inventory_ui = $'inventoryUI'
@onready var sanity_bar = $SanityBar
@onready var attack_area = $AttackArea  # Reference to AttackArea node
@onready var attack_collision_shape = $AttackArea/CollisionShape2D  # Reference to the CollisionShape2D
@onready var health_bar = $HealthBar  # Reference to HealthBar node
@onready var sword_swing2 = $SwordSwing2  # Reference to the SwordSwing2 node
@onready var sword_swing_sprite := $SwordSwing2/Sprite2D  # Reference to the Sprite2D in SwordSwing2
@onready var sword_animation_player := $SwordSwing2/SwordAnimation  # Reference to the AnimationPlayer in SwordSwing2
@onready var level_up_text = $LevelUpText/LevelUpLabel  # Reference to the LevelUpLabel
@onready var level_up_animation_player = $LevelUpText/LevelUpAnimation  # Reference to the LevelUpAnimation
@onready var level_label = $PlayerStatsUI/VBoxContainer/Level  # Adjust the path as necessary
@onready var hp_label = $PlayerStatsUI/VBoxContainer/HP  # Assuming Label2 is for HP
@onready var crit_chance_label = $PlayerStatsUI/VBoxContainer/Crit  # Assuming Label3 is for Crit Chance
@onready var crit_dmg_label = $PlayerStatsUI/VBoxContainer/Crit_dmg  # Assuming Label3 is for Crit Chance
@onready var damage_label = $PlayerStatsUI/VBoxContainer/Damage  # Assuming Label4 is for Damage
@onready var player_stats_ui = $PlayerStatsUI  # Adjust path if needed


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
	
	
	if attack_area:
		print("Attack area initialized successfully")
		attack_area.hide()  # Hide the attack area initially
		attack_collision_shape.disabled = true  # Disable the attack area collision
	else:
		print("Attack area is null")
	
	if sword_swing2:
		sword_swing2.visible = false  # Ensure the sword swing is hidden initially
		if sword_animation_player:
			sword_animation_player.stop()  # Ensure the animation is stopped initially

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

	if crit_dmg_label:
		crit_dmg_label.text = "Crit-Multi: " + str(CRIT_MULTIPLIER) + "X"

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
	detect_surface()
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

	
func detect_surface():
	var tile_maps = get_tree().get_nodes_in_group("tilemap")
	print("Number of TileMaps found:", tile_maps.size()) 

	if tile_maps.size() > 0:
		var tile_map = tile_maps[0] 
		var player_cell_pos = tile_map.to_local(global_position).floor()
		print("Player Cell Position:", player_cell_pos) 

		var cell = tile_map.get_cell_source_id(0, player_cell_pos) 
		print("Cell ID:", cell) 

		if cell != -1: 
			var atlas_coords = tile_map.get_cell_atlas_coords(0, player_cell_pos)
			print("Current Tile Atlas Coords:", atlas_coords) 
			if atlas_coords == Vector2i(0, 0):
				print("Walking on Grass")
				FootstepSounds.set_current_surface("grass")
			elif atlas_coords == Vector2i(50, 0):
				print("Walking on Wood")
				FootstepSounds.set_current_surface("wood")
		else:
			print("Player is on an empty cell") 

 

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
	
	should_play_footstep = velocity != Vector2.ZERO
	
	if should_play_footstep and not is_playing_footstep:
		FootstepSounds.footstep()
		is_playing_footstep = true
	elif not should_play_footstep and is_playing_footstep:
		FootstepSounds.stop_footstep()
		is_playing_footstep = false
	
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
		if sword_swing2:
			sword_swing2.visible = true
			sword_swing2.rotation = get_sword_rotation()

			# Check if current_direction is a valid key in sword_offsets
			if sword_offsets.has(current_direction):
				sword_swing2.position = sword_offsets[current_direction]
			else:
				print("Error: current_direction is not a valid key in sword_offsets. Current direction:", current_direction)
			
			# Play sword swing animation
			if sword_animation_player:
				sword_animation_player.play("sword_swing")
		
		# Hide the attack area after a delay
		await get_tree().create_timer(0.5).timeout  # Adjust this value as needed
		attack_area.hide()
		attack_collision_shape.disabled = true  # Disable the attack area collision
		
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

func _on_sword_swing_animation_finished(anim_name):
	if anim_name == "sword_swing":
		if sword_swing2:
			sword_swing2.visible = false  # Hide the sword swing after animation

func deal_damage(damage_amount: int):
	# Optionally, you can add visual or sound effects for damage here
	print("Dealing", damage_amount, "damage")
	# Logic to deal damage to enemies
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("enemies"):
			print("Enemy detected in attack area, applying damage")
			if body.has_method("take_damage"):
				body.take_damage(damage_amount)
				display_damage_text(body.global_position, damage_amount)  # Enemy damage text
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
	CRIT_CHANCE += 0.001  # Increase critical chance by 1%
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
	# Use predefined sword_rotations to get rotation based on direction
	if sword_rotations.has(current_direction):
		return sword_rotations[current_direction]
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
	
	# Display damage text above the player with player-specific positioning
	display_damage_text(global_position, amount, true)  # Pass true for the player
	
	if health <= 0:
		die()  # Handle death

	# Update health bar value (if it exists)
	if health_bar:
		health_bar.value = health

	# Optional: Visual feedback on taking damage
	# self.modulate = Color.RED  # Change color for a brief moment
	# play_sound("damage.wav")  # Play a sound effect

func die():
	# Handle death (e.g., animation, game over, respawn)
	print("Player died!")
	queue_free()

func display_damage_text(position: Vector2, damage_amount: int, is_player: bool = false):
	# Load the DamageText scene
	var damage_text_scene = load(DAMAGE_TEXT_SCENE_PATH)
	if damage_text_scene:
		var damage_text_instance = damage_text_scene.instantiate()
		if damage_text_instance:
			var label = damage_text_instance.get_node("Label")  # Ensure your Label is named "Label"
			if label:
				label.text = str(damage_amount)
				
				# Adjust the Y position offset based on whether it's the player or an enemy
				var player_offset = 60  # Adjust this value for the player
				var enemy_offset = 50   # Adjust this value for the enemy
				
				var position_offset = Vector2(0, enemy_offset)  # Default for enemy
				if is_player:
					position_offset = Vector2(0, player_offset)  # Offset for player
				
				damage_text_instance.position = position + position_offset
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




