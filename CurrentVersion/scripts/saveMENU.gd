extends Button


func save_game():
	var save_data = {}
	
	# Save player data
	var player = get_node("/root/World/Player")
	save_data["player"] = {
		"position": player.global_transform.origin,
		"health": player.health,
		"inventory": player.inventory,
	}
	
	# Save game progress
	save_data["game"] = {
		"current_level": get_tree().current_scene.filename,
		# Add other game progress data as needed
	}
	
	# Save world state
	# Example: enemy positions and health
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var enemy_states = []
	for enemy in enemies:
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
