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
			$fixedNpcText.type(GlobalStrings.dialogue.npc.bar_owner.welcome) #
		if get_tree().current_scene.name == "empty_inside":
			$fixedNpcText.type(GlobalStrings.dialogue.npc.bar_owner.start_serving_question)
		if get_tree().current_scene.name == "inside":
			$fixedNpcText.type(GlobalStrings.dialogue.npc.bar_owner.finish_serving_question)

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
		$fixedNpcText.type(GlobalStrings.dialogue.empty)
		$fixedNpcText.visible = true


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		area_active = false
		player_in_range = false
		Global.npc_in_range = true
		$fixedNpcText.visible = false
		$fixedNpcText.type(GlobalStrings.dialogue.empty)
		$fixedNpcText/options.visible = false
