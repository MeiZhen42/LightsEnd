extends Area2D

#signal enemy_collided(other_body)

var damage_timer: float = 0.0
const DAMAGE_INTERVAL: float = 1.0  # Time between damage applications
var overlapping_bodies: Dictionary = {}

func _ready():
	# Initialize signal connections manually in the editor
	pass

func _process(_delta):
	damage_timer += _delta
	if damage_timer >= DAMAGE_INTERVAL:
		# Apply damage to all overlapping bodies that are in the player group
		for body in overlapping_bodies.keys():
			if body.is_in_group("player"):
				if body.has_method("take_damage"):
					body.take_damage(10)  # Adjust damage amount as needed
				else:
					print("Error: Player does not have take_damage method!")
		damage_timer = 0.0  # Reset damage timer

func _on_body_entered(body):
	# Add body to the list of overlapping bodies
	overlapping_bodies[body] = true

func _on_body_exited(body):
	# Remove body from the list of overlapping bodies
	overlapping_bodies.erase(body)
