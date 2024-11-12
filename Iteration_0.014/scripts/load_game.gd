extends Button


func load_game():
	var file = FileAccess.open("user://savegame.save", FileAccess.READ)
	if file == null:
		print("Error: No save file found.")
		return
	
	var save_data = file.get_var()  # Load the saved data from the file
	file.close()
	
	# Load player data
	var player = get_node_or_null("/root/World/Player")
	if player != null and "player" in save_data:
		var player_data = save_data["player"]
		player.global_transform.origin = player_data["position"]
		player.health = player_data["health"]
		player.inventory = player_data["inventory"]
	else:
		print("Error: Player node not found or player data missing.")

	# Load game progress (e.g., current level)
	if "game" in save_data:
		var game_data = save_data["game"]
		var current_level = game_data["current_level"]
		print("Loading level: ", current_level)
		# If necessary, you can use this data to change scenes or reload the current level

	# Load world state (enemies)
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
