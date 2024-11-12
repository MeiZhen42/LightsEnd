extends Button

# This function recursively prints the entire scene tree structure.
func print_scene_tree(node, indent=0):
	print("Inspecting node: " + node.name)  # Debug print for each node
	var indent_str = ""
	for i in range(indent):
		indent_str += " "  # Add spaces based on the indent level
	print(indent_str + node.name)  # Print the node name with indentation
	
	# Iterate through children and recursively print them
	var children = node.get_children()
	print("Node: " + node.name + " has " + str(children.size()) + " children")  # Debug number of children
	for child in children:
		print_scene_tree(child, indent + 2)  # Recursively print children with increased indentation

func _init():
	print("INIT function called - Autoload is working")

func _ready():
	print("READY function called")  # This will confirm that _ready() is being executed
	print("Scene tree debug start")
	var root = get_tree().root
	if root != null:
		print("Root node found: " + root.name)  # Debug the root node
		print_scene_tree(root)  # Print the scene tree starting from the root
	else:
		print("Error: No root node found.")
	print("Scene tree debug end")



func save_game():
	var save_data = {}
	
	# Save player data
	var player = get_node_or_null("/root/scenes/player")
	if player == null:
		print("Error: Player node not found")
	else:
		save_data["player"] = {
			"position": player.global_transform.origin,
			"health": player.health,
			"inventory": player.inventory,
		}
	
	# Safely check for current scene and get its filename
	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene is SceneState:  # Use SceneState to check the actual scene
		save_data["game"] = {
			"current_level": current_scene.scene_file_path,  # Use scene_file_path instead of resource_path
		}
	else:
		print("Error: No valid scene loaded or incorrect scene type.")
	
	# Save world state (enemy positions and health)
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var enemy_states = []
	for enemy in enemies:
		if enemy == null:
			print("Error: Enemy node is null")
			continue
	
		enemy_states.append({
			"type": enemy.type,  # Assuming enemies have a 'type' property
			"position": enemy.global_transform.origin,
			"health": enemy.health,
		})
	save_data["world"] = {
		"enemy_states": enemy_states,
	}
	
	# Save to file
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		show_save_confirmation()
	else:
		print("Error: Unable to save the game.")

func show_save_confirmation():
	# Assuming you have a Label node named SaveConfirmationLabel
	if has_node("SaveConfirmationLabel"):
		$SaveConfirmationLabel.text = "Game Saved!"
		$SaveConfirmationLabel.visible = true
		# Hide the label after a short delay
		await get_tree().create_timer(2.0).timeout
		$SaveConfirmationLabel.visible = false
