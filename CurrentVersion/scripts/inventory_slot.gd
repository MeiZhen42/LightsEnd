class_name inventory_slot extends Control


@onready var icon = $innerBorder/itemIcon
@onready var quantity_label =  $innerBorder/itemQuantity
@onready var details_panel = $details_panel
@onready var item_name = $details_panel/itemName
@onready var item_type = $details_panel/itemType
@onready var item_effect = $details_panel/itemEffect
@onready var usage_panel = $usage_panel
#@onready var text = $text_ui/fixedText

#@onready var node_path = "res://scenes/randomizedNPCs.tscn"


var item = null

#func _physics_process(_delta):
	#text = " "


func _on_drop_button_pressed():
	if item != null:
		var drop_position = Global.player_node.global_position
		var drop_offset = Vector2(25, 0)
		drop_offset = drop_offset.rotated(Global.player_node.rotation)
		Global.drop_item(item, drop_position + drop_offset)
		Global.remove_item(item["type"], item["effect"])
		usage_panel.visible = false


func _on_item_button_mouse_entered():
	if item != null:
		usage_panel.visible = false
		details_panel.visible = true


func _on_item_button_pressed():
	if item != null:
		usage_panel.visible = !usage_panel.visible


func _on_item_button_mouse_exited():
	details_panel.visible = false


func set_empty():
	icon.texture = null  
	quantity_label.text = ""


func set_item(new_item):
	item = new_item
	icon.texture = new_item["texture"] 
	quantity_label.text = str(item["quantity"])
	item_name.text = str(item["name"])
	item_type.text = str(item["type"])
	if item["effect"] != "":
		item_effect.text = str("+ ", item["effect"])
	else: 
		item_effect.text = ""
		

func _on_use_button_pressed():
	usage_panel.visible = false
	if item != null and item["effect"] != "":
		#print("test01")
		# change all lines with Global to pulling from playerNpcRange.gd
		if Global.player_node:
			#print("test02")
			#text = "Thanks"
			if Global.player_in_range == true:
				Global.npc_node.apply_item_effect(item)
				#print("test03")
				Global.remove_item(item["type"], item["effect"])
				print("Consumed potion")
				# close inventory and type message
				#text.visible = true
				
				#text.type("Thank you")s
				#Global.npc_node.npc_status(item)
		else:
			print("npc could not be found")
