class_name Player extends CharacterBody2D

const SPEED = 100.0
var current_direction = "none"

@onready var interact_ui = $'interactUI'
@onready var inventory_ui = $'inventoryUI'
@onready var footstep_player := $AudioStreamPlayer2D

func _ready():
	Global.set_player_reference(self)
	
	# Debug: Check if footstep_player is correctly initialized
	if footstep_player:
		print("Footstep player initialized successfully")
	else:
		print("Footstep player is null")

func _physics_process(_delta):
	player_movement(_delta)
	
func player_movement(_delta):
	velocity = Vector2.ZERO
	
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

#func apply_item_effect(item):
#    match item["effect"]:
#        "Cure":
#            print("Negative effect")
#        "Sad":
#            print("Negative effect")
#        _:
#            print("Nothing happened")
