# PauseScreen.gd
extends Control

func _ready():
	# Start hidden
	#visible = false
	#$SettingsMenu.visible = false  # Ensure SettingsMenu is hidden initially
	#process_mode = Node.PROCESS_MODE_WHEN_PAUSED  # Process input when paused
# PauseScreen.gd

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
	$CanvasLayer/Panel.visible = true
	$CanvasLayer/SettingsMenu.visible = false

func hide_settings_menu():
	print("Hiding settings menu")
	$CanvasLayer/Panel.visible = true
	$CanvasLayer/SettingsMenu.visible = false

func _on_Back_pressed():
	hide_settings_menu()
