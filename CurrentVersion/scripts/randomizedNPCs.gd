class_name randomized_npc extends Sprite2D

# number of frames-- get_width corresponds to the x in the Region -> w = number in Inspector
@onready var frames = texture.get_width() / region_rect.size.x
# which sprite it is within range e.g. 1st sprite in roder
@onready var rand_sprite = randi_range(0, frames - 1)
@onready var rand = randf_range(0, 10)
#@onready var unique_id = get_instance_id()
#@onready var tag = $Area2D/Label
@onready var node_path = "res://scenes/randomizedNPCs.tscn"
@onready var test = get_tree().root.find_child("fixedText")

#var sprite = 

func cursed_random():
	if rand > 4:
		$"Slime-icon".visible = true
	else:
		$"Slime-icon".visible = false

func _ready():
	Global.set_npc_reference(self)
	region_rect.position.x = rand_sprite * region_rect.size.x
	if rand_sprite > 0:
		self.visible = true
	else:
		self.visible = false
	cursed_random()
		
		

# if sprite region_rect.position.x <= 16:
	# specific item will cure
# if sprite region_rect.position.x > 16 and sprite region_rect.position.x <= 32
	# specific item will cure
# etc.
# else	
	# print("Item has no effect")


func apply_item_effect(item):
	print("applying item")
	print("effect: " + item["effect"])
	if item["effect"].begins_with("Cure"):
		#print(item["name"])
		#print(rand_sprite)
		var cureArr: Array[String] = ["YT", "YS", "YC", "GT", "GS", "GC", "BT", "BS", "BC"]
		#var effectNum = item["effect"].substr(4,-1).to_int()
		#print(item["name"].trim_suffix(" Potion"))
		#print(InventoryManager.translate_full_string_to_code(item["name"]))
		var effectNum = cureArr.find(InventoryManager.translate_full_string_to_code(item["name"]))
		#print(effectNum)
		var msgToType = ""
		var node = get_node("../cutScene")
			
		if rand_sprite == effectNum and $"Slime-icon".visible == true:
			print(str("Positive effect for rock ", effectNum))
			msgToType = "I feel much better. Thank you"
			$"Slime-icon".hide()
		else:
			print("Wrong potion")
			msgToType = "I don't feel any different"
		
		if(node != null):
			node.type(msgToType)
		else:
			print("Couldn't print message. Could not find cutScene.\nIntended message: " + msgToType)
			print(get_tree_string())
	elif item["effect"].begins_with("Curse"):
		print("Negative effect")
	else:
		print("Nothing happened")
	#print(effectNum)


# hiding wrong sprite--last sprite in node list of inside.tscn
# look at inside.tscn -> get group "npc" -> if find match, then hide interacted node



	#if item["effect"] == "Cure1" and rand == 1:
		#$cutScene.get_node("options").show()
		#$cutScene.type("Much better.")
	#elif item["effect"] == "Cure2" and rand == 2:
		#$cutScene.get_node("options").show()
		#$cutScene.type("I feel much better.")
	#else:
		#print("Not the right match")

#func item_viability():
	#if region_rect.position.x < 16:
		#Global.npc_node.apply_item_effect()


#func _on_item_rect_changed():
	#if region_rect.position.x < 16:
		#Global.npc_node.apply_item_effect()
