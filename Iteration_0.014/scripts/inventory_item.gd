@tool
class_name inventoryitem extends Node2D


@export var item_type = ""
@export var item_name = ""
@export var item_texture: Texture
@export var item_effect = ""
var scene_path: String = "res://scenes/inventory_item.tscn"


@onready var icon_sprite = $Sprite2D


var player_in_range = false

func _ready():
	if not Engine.is_editor_hint():
		icon_sprite.texture = item_texture

func _process(_delta):
	if Engine.is_editor_hint():
		icon_sprite.texture = item_texture
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		pickup_item()


func pickup_item():
	var item = {
		"quantity": 1,
		"type": item_type,
		"name": item_name,
		"effect": item_effect,
		"texture": item_texture,
		"scene_path": scene_path
	}
	if Global.player_node:
		Global.add_item(item)
		self.queue_free() #removes item from scene after picking up


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		#Global.npc_in_range = false
		#body.interact_ui.visible = true
		

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		#Global.npc_in_range = false
		#body.interact_ui.visible = false


func set_item_data(data):
	item_type = data["type"]
	item_name = data["name"]
	item_effect = data["effect"]
	item_texture = data["texture"]
