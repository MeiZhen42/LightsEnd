class_name in_tavern extends Area2D


var entered = false

func _on_body_entered(body: PhysicsBody2D):
	if body.is_in_group("player"):
		entered = true


func _on_body_exited(body: PhysicsBody2D):
	if body.is_in_group("player"):
		entered = false
	

func _process(_delta):
	if entered == true:
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().change_scene_to_file("res://scenes/outside.tscn")
