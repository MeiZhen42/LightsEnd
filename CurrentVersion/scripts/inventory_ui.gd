class_name inventory_ui extends Control

@onready var grid_container = $GridContainer
@onready var merge_panel = $merge_panel

func _ready():
	Global.inventory_updated.connect(_on_inventory_updated) # _ indicates connector signal
	_on_inventory_updated()

# Update inventory U
func _on_inventory_updated():  
	clear_grid_container()
	for item in Global.inventory:
		var slot = Global.inventory_slot_scene.instantiate()
		grid_container.add_child(slot)
		if item != null:
			slot.set_item(item)
		else:
			slot.set_empty() 

# Clear inventory UI grid
func clear_grid_container():
	while grid_container.get_child_count() > 0:
		var child = grid_container.get_child(0)
		grid_container.remove_child(child)
		child.queue_free()


func _on_cancel_merging_pressed():
	Global.merge_from = null
	$merge_panel.hide()
