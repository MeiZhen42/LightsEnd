extends CanvasLayer


@onready var label = get_node("fixedText")
#@onready var inventory_ui = $inventoryUI


func type(text):
	label.visible_ratio = 0
	label.text = text
	var tween = create_tween()
	# speed of text showing on scene
	tween.tween_property(label, "visible_ratio", 1, 1)
	#if "item?" in text:
		#tween.tween_callback(show_options)


#func show_options():
	#get_node("options").show()


#func _on_yes_pressed():
	#type("[open inventory to give potion]")
	#get_node("options").hide()
	#inventory_ui.visible = true
	#inventory_ui.visible = !inventory_ui.visible
	


#func _on_no_pressed():
	#type("I'll be here.")
	#get_node("options").hide()
	#inventory_ui.visible = false
	
