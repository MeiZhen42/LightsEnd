class_name in_tavern extends Area2D


var entered = false

func _on_body_entered(_body: PhysicsBody2D):
	entered = true


func _on_body_exited(_body: PhysicsBody2D):
	entered = false
	

func _process(_delta):
	if entered == true:
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().change_scene_to_file("res://scenes/outside.tscn")
	# entered == false
	
