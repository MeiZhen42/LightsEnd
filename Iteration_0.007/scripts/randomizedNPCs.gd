class_name randomized_npc extends Sprite2D

# number of frames-- get_width corresponds to the x in the Region -> w = number in Inspector
@onready var frames = texture.get_width() / region_rect.size.x
# which sprite it is within range e.g. 1st sprite in roder
@onready var rand = randi_range(0, frames - 1)

@onready var tag = $Area2D/Label

#var sprite = 

func _ready():
	Global.set_npc_reference(self)
	region_rect.position.x = rand * region_rect.size.x
	if rand > 0:
		self.visible = true
	else:
		self.visible = false
		

# if sprite region_rect.position.x <= 16:
	# specific item will cure
# if sprite region_rect.position.x > 16 and sprite region_rect.position.x <= 32
	# specific item will cure
# etc.
# else	
	# print("Item has no effect")


func apply_item_effect(item):
	match item["effect"]:
		"Cure1":
			if rand == 1:
				print("Positive effect for rock 1")
			else:
				print("Wrong potion")
		"Cure2":
			if rand == 2:
				print("Positive effect for rock 2")
			else:
				print("Wrong potion")
		"Cursed":
			print("Negative effect")
		_:
			print("Nothing happened")
	
	if item["effect"] == "Cure1" and rand == 1:
		$Area2D/Label.visible = true
	elif item["effect"] == "Cure2" and rand == 2:
		$Area2D/Label.visible = true
	else:
		print("Not the right match")

#func item_viability():
	#if region_rect.position.x < 16:
		#Global.npc_node.apply_item_effect()


#func _on_item_rect_changed():
	#if region_rect.position.x < 16:
		#Global.npc_node.apply_item_effect()
