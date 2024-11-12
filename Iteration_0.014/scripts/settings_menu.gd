# SettingsMenu.gd
extends Control

func _ready():
	load_settings()

func _on_FullscreenCheckBox_toggled(pressed):
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if pressed else DisplayServer.WINDOW_MODE_WINDOWED)
	save_settings()

func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	save_settings()

func save_settings():
	var config = ConfigFile.new()
	config.set_value("Audio", "MasterVolume", $CanvasLayer/VolumeSlider.value)  # Update path if inside CanvasLayer
	config.set_value("Video", "Fullscreen", $CanvasLayer/FullscreenCheckBox.pressed)  # Update path if inside CanvasLayer
	# Save other settings as needed
	var err = config.save("user://settings.cfg")
	if err != OK:
		print("Error saving settings: ", err)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		var volume = config.get_value("Audio", "MasterVolume", -10.0)
		$CanvasLayer/VolumeSlider.value = volume  # Update path if inside CanvasLayer
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)

		var is_fullscreen = config.get_value("Video", "Fullscreen", false)
		$CanvasLayer/FullscreenCheckBox.pressed = is_fullscreen  # Update path if inside CanvasLayer
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		# Load other settings as needed
	else:
		print("No settings file found or error loading settings: ", err)
