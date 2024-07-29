extends Node2D

#@onready var tag = $fixedNPCs/Area2D/Label
@onready var text_npc = "res://scenes/random_npc_text.tscn"
@onready var inventory_ui = "res://scenes/inventory_ui.tscn"

var area_active = false


func _physics_process(_delta):
	if Input.is_action_pressed("ui_accept") and area_active == true:
		#if _on_area_2d_body_entered(_delta):
			$cutScene.get_node("fixedText")
			$cutScene.type("Need something strong")
			#queue_free()
		#text_npc.visible = true
		#inventory_ui.visible = true

func _on_area_2d_body_entered(body): #CharacterBody2D
	if body.is_in_group("player"):
		area_active = true
		Global.player_in_range = true
		#tag.visible = true
		#body.interact_ui.visible = true
		$cutScene.visible = true
		# Global.npc_node = body
		print("body entered. self, body:")
		print(self.name)
		#print($fixedNPCs.name)
		#print()
		#print(get_tree_string_pretty())
		print(body.name)
		Global.npc_node = $fixedNPCs


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		Global.player_in_range = false
		area_active = false
		#tag.visible = false
		body.interact_ui.visible = false
		$cutScene.visible = false
		$cutScene.type(" ")



#func _on_text_collision_body_entered(body):
	#if body.is_in_group("player"):
		#Global.player_in_range = true
		


#func _on_text_collision_body_exited(body):
	#if body.is_in_group("player"):
		#Global.player_in_range = false

#func npc_status(item):
	#if item["effect"] == "Cure":
		#tag.visible = false
	#elif item["effect"] != "Cure":
		#tag.visible = true








