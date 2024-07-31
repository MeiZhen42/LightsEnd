extends CanvasLayer


@onready var label = get_node("fixedText")
#@onready var inventory_ui = $inventoryUI


func type(text):
	if $options.visible == false:
		label.visible_ratio = 0
		label.text = text
		var tween = create_tween()
		# speed of text showing on scene
		tween.tween_property(label, "visible_ratio", 1, 1)
		if "you" in text:
			tween.tween_callback(show_options)


func show_options():
	get_node("options").show()


func _on_yes_pressed():
	type("")
	#get_node("options").hide()
	if get_tree().current_scene.name == "empty_inside":
		get_tree().change_scene_to_file("res://scenes/inside.tscn")
	elif get_tree().current_scene.name == "inside":
		get_tree().change_scene_to_file("res://scenes/outside.tscn")
	
	


func _on_no_pressed():
	type("Alright then.")
	get_node("options").hide()
	self.visible = false
	
	
