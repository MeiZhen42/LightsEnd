extends Area2D

signal entered_roam_area
signal exited_roam_area

# Dictionary to keep track of enemies within the roam area
var enemies_in_area = {}

func _ready():
	# Initialize any needed values or states
	set_roam_area_bounds()

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		enemies_in_area[body] = true
		emit_signal("entered_roam_area", body)
		# Additional logic for when an enemy enters

func _on_body_exited(body):
	if body.is_in_group("enemies"):
		enemies_in_area.erase(body)
		emit_signal("exited_roam_area", body)
		# Additional logic for when an enemy exits

func set_roam_area_bounds():
	# Example function to set the bounds of the roam area
	# Adjust this to your specific needs
	var collision_shape = $CollisionShape2D.shape
	if collision_shape:
		# Do something with the shape
		pass
	else:
		print("CollisionShape2D not found.")
