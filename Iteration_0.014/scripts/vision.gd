extends Node2D

var is_agro : bool = false
var target_position : Vector2 = Vector2.ZERO
var agro_target: Node2D

@onready var enemy = get_parent()  # This assumes the AgroBehavior is a child of the enemy node

func _ready():
	pass

func _physics_process(_delta):
	if is_agro and agro_target:
		target_position = agro_target.global_position
		_move_towards_target(_delta)

func _move_towards_target(_delta):
	if target_position and enemy:
		var direction = (target_position - enemy.global_position).normalized()
		enemy.velocity = direction * enemy.SPEED
		enemy.move_and_slide()
		print("Chasing player: ", target_position)

func _on_agro_area_entered(body):
	print("Agro area entered")
	if body.is_in_group("player"):
		print("Player detected!")
		is_agro = true
		target_position = body.global_position
		agro_target = body

func _on_agro_area_exited(body):
	print("Agro area exited")
	if body.is_in_group("player"):
		print("Player lost!")
		is_agro = false
		target_position = Vector2.ZERO
