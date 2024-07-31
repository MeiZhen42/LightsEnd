extends CharacterBody2D

const HEALTH = 50
var health = HEALTH

func _ready():
	# Initialize if needed
	pass

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()  # Remove the enemy from the scene
