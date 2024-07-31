extends Node2D

@onready var tag = $fixedNPCs/Area2D/Label


var player_in_range = null


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		#apply_item
		Global.player_in_range = true
		#tag.visible = true
		#body.interact_ui.visible = true


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		Global.player_in_range = false
		#tag.visible = false
		#body.interact_ui.visible = false





#func npc_status(item):
	#if item["effect"] == "Cure":
		#tag.visible = false
	#elif item["effect"] != "Cure":
		#tag.visible = true
