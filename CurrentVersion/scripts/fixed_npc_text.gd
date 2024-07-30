extends Node2D

var area_active = false
var outside = "res://scenes/outside.tscn"
var inside_without_patrons = "res://scenes/empty_inside.tscn"
var inside_with_patrons = "res://scenes/inside.tscn"
var player_in_range = false


func _ready():
	Global.set_barkeep_reference(self)

func _physics_process(_delta):
	#npc_movement(_delta)
	if Input.is_action_pressed("ui_accept") and area_active == true: 
		if get_tree().current_scene.name == "outside":
			$fixedNpcText.type("Hello, welcome to my tavern.
				Mind helping me out and 
				gathering ingredients?
				It will help stave off
				the darkness")
		if get_tree().current_scene.name == "empty_inside":
			$fixedNpcText.type("Are you ready to start?")
		if get_tree().current_scene.name == "inside":
			$fixedNpcText.type("Have you finished for the day?")

#func npc_movement(_delta):
	#npc_animation(_delta)
	#velocity.x = 0
	#velocity.y = 0
#
#func npc_animation(_delta):
	#var animation = $npcCollision
	#animation.play("front_idle")
	#move_and_slide()




func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		area_active = true
		player_in_range = true
		Global.npc_in_range = true
		$fixedNpcText.type(" ")
		$fixedNpcText.visible = true


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		area_active = false
		player_in_range = false
		Global.npc_in_range = true
		$fixedNpcText.visible = false
		$fixedNpcText.type(" ")
		$fixedNpcText/options.visible = false
