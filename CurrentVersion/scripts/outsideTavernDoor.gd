class_name outsidetavern extends Area2D


var entered = false

func _on_body_entered(_body: PhysicsBody2D):
	entered = true


func _on_body_exited(_body: PhysicsBody2D):
	entered = false
	

func _process(_delta):
	if entered == true:
		if Input.is_action_just_pressed("ui_accept"):
			if get_tree().current_scene.name == "outside":
				get_tree().change_scene_to_file("res://scenes/empty_inside.tscn")
			#if get_tree().current_scene.name == "inside":
				#get_tree().change_scene_to_file("res://scenes/outside.tscn")
