extends Control

# Declare the labels
@onready var level_label = $VBoxContainer/Level  # Adjust the path as necessary
@onready var hp_label = $VBoxContainer/HP  # Assuming Label2 is for HP
@onready var crit_chance_label = $VBoxContainer/Crit  # Assuming Label3 is for Crit Chance
@onready var damage_label = $VBoxContainer/Damage  # Assuming Label4 is for Damage

# This function will be called to update the stats displayed in the UI
func update_stats(level, health, max_health, crit_chance, attack_damage):
	level_label.text = "Level: " + str(level)
	hp_label.text = "HP: " + str(health) + "/" + str(max_health)
	crit_chance_label.text = "Crit Chance: " + str(int(crit_chance * 100)) + "%"  # Convert to percentage and round
	damage_label.text = "Damage: " + str(attack_damage)
