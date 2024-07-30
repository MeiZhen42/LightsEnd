class_name Player extends CharacterBody2D

const SPEED = 100.0
var current_direction = "none"

@onready var interact_ui = $'interactUI'
@onready var inventory_ui = $'inventoryUI'
# @onready var inventory_manager = InventoryManager.new()

@onready var sanity_bar = $SanityBar
var safe: bool = true
const sanity_decline: float = 1.5
const sanity_regain: float = 1

func _ready():
	Global.set_player_reference(self)
	sanity_bar.min_value = 0
	sanity_bar.max_value = 100
	sanity_bar.value = sanity_bar.max_value

func _physics_process(_delta):
	player_movement(_delta)

func _process(_delta):
	#Adjust sanity
	if(safe):
		sanity_bar.value += sanity_regain * _delta
	else:
		sanity_bar.value -= sanity_decline * _delta * 5
		if(sanity_bar.value <= sanity_bar.min_value):
			## ToDo: do something when sanity reaches 0
			pass
	#var shade: float = (sanity_bar.value / sanity_bar.max_value) * (0.8-0.2) + 0.2
	#6, 158, 92 -> 69, 3, 3
	var shade: float = (sanity_bar.value / sanity_bar.max_value)
	sanity_bar.get_theme_stylebox("fill").bg_color = Color((69 - 63 * shade)/255, (3 + 155 * shade)/255, (3 + 89 * shade)/255)
	if(sanity_bar.value < sanity_bar.max_value):
		sanity_bar.show()
	else:
		sanity_bar.hide()
	pass
	
func player_movement(_delta):
	if Input.is_action_pressed("ui_right"):
		current_direction = "right"
		play_animation(1)
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_direction = "left"
		play_animation(1)
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_direction = "down"
		play_animation(1)
		velocity.x = 0
		velocity.y = SPEED
	elif Input.is_action_pressed("ui_up"):
		current_direction = "up"
		play_animation(1)
		velocity.x = 0
		velocity.y = -SPEED
	else:
		play_animation(0)
		velocity.x = 0
		velocity.y = 0
		
func play_animation(movement):
	var direction = current_direction
	var animation = $AnimatedSprite2D
	
	if direction == "right":
		animation.flip_h = false
		if movement == 1:
			animation.play("side_walk")
		elif movement == 0:
			animation.play("side_idle")
			
	if direction == "left":
		animation.flip_h = true
		if movement == 1:
			animation.play("side_walk")
		elif movement == 0:
			animation.play("side_idle")	
			
	if direction == "down":
		animation.flip_h = false
		if movement == 1:
			animation.play("front_walk")
		elif movement == 0:
			animation.play("front_idle")
			
	if direction == "up":
		animation.flip_h = false
		if movement == 1:
			animation.play("back_walk")
		elif movement == 0:
			animation.play("back_idle")	
	
	move_and_slide()

func _input(event):
	if event.is_action_pressed("q"):
		inventory_ui.visible = !inventory_ui.visible
		get_tree().paused = !get_tree().paused

#func apply_item_effect(item):
	#match item["effect"]:
		#"Cure":
			#print("Negative effect")
		#"Sad":
			#print("Negative effect")
		#_:
			#print("Nothing happened")
