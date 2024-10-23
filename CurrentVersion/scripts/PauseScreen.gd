# PauseScreen.gd
extends Control

func _ready():
	print("Ready function called for PauseScreen")
	var root = get_tree().root
	print_scene_tree(root)
	# Start hidden
	visible = false
	$CanvasLayer/SettingsMenu.visible = false  # Ensure SettingsMenu is hidden initially
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED  # Process input when paused
	
	# Ensure Save and Load buttons are connected to the appropriate functions
	#$CanvasLayer/Panel/SaveButton.connect("pressed", self, "_on_SaveButton_pressed")
	#$CanvasLayer/Panel/LoadButton.connect("pressed", self, "_on_LoadButton_pressed")

	var panel = $CanvasLayer/Panel
	var settings_menu = $CanvasLayer/SettingsMenu

	if panel == null:
		print("Error: Panel node is null")
	else:
		panel.visible = true  # Ensure the main panel is visible

	if settings_menu == null:
		print("Error: SettingsMenu node is null")
	else:
		settings_menu.visible = false  # Ensure settings menu is hidden at start

func print_scene_tree(node, indent=0):
	var indent_str = "\t".repeat(indent)  # Using repeat() for tabbed indents
	print(indent_str + node.name)  # Print the node name with indentation
	
	# Recursively print all children
	for child in node.get_children():
		print_scene_tree(child, indent + 1)


func show_pause_screen():
	print("PauseScreen: show_pause_screen() called")
	$CanvasLayer.visible = true  # Ensure CanvasLayer itself is visible
	$CanvasLayer/Panel.visible = true  # Show the main panel
	$CanvasLayer/SettingsMenu.visible = false  # Ensure settings menu is hidden by default
	visible = true  # Show the entire PauseScreen
	get_tree().paused = true

func hide_pause_screen():
	print("PauseScreen: hide_pause_screen() called")
	$CanvasLayer.visible = false  # Hide the entire CanvasLayer and Panel
	visible = false  # Hide the PauseScreen
	get_tree().paused = false  # Unpause the game

func _on_ContinueButton_pressed():
	hide_pause_screen()

func _on_SettingsButton_pressed():
	show_settings_menu()

func show_settings_menu():
	print("Showing settings menu")
	$CanvasLayer/Panel.visible = false
	$CanvasLayer/SettingsMenu.visible = true

func hide_settings_menu():
	print("Hiding settings menu")
	$CanvasLayer/Panel.visible = true
	$CanvasLayer/SettingsMenu.visible = false

func _on_Back_pressed():
	hide_settings_menu()

# Function to handle Save button press
func _on_SaveButton_pressed():
	# Get the PlayerSpawn node (adjust path as necessary)
	var player_spawn = get_node_or_null("/root/outside/PlayerSpawn")
	if player_spawn != null:
		# Check if the player has been instantiated
		var player = player_spawn.player
		if player == null:
			# If player is not found, wait for instantiation
			print("Waiting for player instantiation...")
			while player == null:
				player = player_spawn.player  # Continuously check for the player
				await get_tree().create_timer(0.1).timeout  # Small wait before checking again
			
		# Check if the player is available after the loop
		if player != null:
			# Collect player data
			var player_data = {
				"health": player.health,
				"max_health": player.max_health,
				"level": player.level,
				"experience": player.experience,
				"position": player.global_position,
				# "inventory": player.inventory  # Add inventory if necessary
			}
			
			# Call save_game with the collected player data
			save_game(player_data)
			print("Player data saved via button press.")
		else:
			print("Error: Player node not found, even after waiting.")
	else:
		print("Error: PlayerSpawn node not found.")

func save_game(player_data):
	var save_data = {}

	# Save the passed player data
	save_data["player"] = player_data
	
	# Save game progress (e.g., current scene)
	var current_scene = get_tree().current_scene
	if current_scene != null:
		# Ensure you're accessing the scene's resource_path, not filename on a TileMap
		if current_scene.has_method("get_scene_file_path"):
			save_data["game"] = {
				"current_level": current_scene.get_scene_file_path()  # Correct method for scene path
			}
		else:
			print("Error: Scene does not have a valid path.")
	else:
		print("Error: No valid scene loaded or incorrect scene type.")
	
	# Save world state (e.g., enemy positions and health)
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var enemy_states = []
	for enemy in enemies:
		if enemy == null:
			print("Error: Enemy node is null")
			continue
		
		enemy_states.append({
			"type": enemy.type,
			"position": enemy.global_transform.origin,
			"health": enemy.health
		})
	save_data["world"] = {
		"enemy_states": enemy_states
	}
	
	# Save to file
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		show_save_confirmation()
	else:
		print("Error: Unable to save the game.")
	
func load_game():
	# Open the saved file
	var file = FileAccess.open("user://savegame.save", FileAccess.READ)
	if file == null:
		print("Error: No save file found.")
		return
	
	# Load the saved data
	var save_data = file.get_var()  
	file.close()
	
	# Load player data
	var player_spawn = get_node_or_null("/root/outside/PlayerSpawn")
	if player_spawn != null and "player" in save_data:
		# Wait for the player to be instantiated if necessary
		while player_spawn.player == null:
			await get_tree().create_timer(0.1).timeout  # Wait briefly until the player is instantiated
		
		var player = player_spawn.player
		if player != null:
			# Make sure the properties are defined in your player script
			var player_data = save_data["player"]
			player.global_position = player_data["position"]
			player.health = player_data["health"]
			player.max_health = player_data["max_health"]
			player.level = player_data["level"]
			player.experience = player_data["experience"]
			
			# Update the UI to reflect the loaded data
			player.update_ui()  # Call the function to update UI
			print("Player data loaded successfully.")
		else:
			print("Error: Player node not found after instantiation.")
	else:
		print("Error: PlayerSpawn node not found or player data missing.")

	# Load game progress (e.g., current level)
	# (Continue with the rest of your load logic)


	# Load world state (e.g., enemy positions and health)
	if "world" in save_data and "enemy_states" in save_data["world"]:
		var enemy_states = save_data["world"]["enemy_states"]
		var enemies = get_tree().get_nodes_in_group("Enemies")
		for i in range(len(enemy_states)):
			if i < len(enemies):  # Ensure we don't go out of bounds
				var enemy = enemies[i]
				var enemy_data = enemy_states[i]
				enemy.global_transform.origin = enemy_data["position"]
				enemy.health = enemy_data["health"]
				print("Restored enemy: ", enemy_data["type"], " at ", enemy_data["position"])
	else:
		print("No enemy states found in save data.")


# Show a save confirmation message
func show_save_confirmation():
	if has_node("SaveConfirmationLabel"):
		$SaveConfirmationLabel.text = "Game Saved!"
		$SaveConfirmationLabel.visible = true
		await get_tree().create_timer(2.0).timeout  # Wait for 2 seconds
		$SaveConfirmationLabel.visible = false

# Handle Load button press
func _on_LoadButton_pressed():
	load_game()
