class_name safezone extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(body: PhysicsBody2D):
	if(body.is_in_group("player")):
		print("you entered the safe zone")
		body.safe = true
	pass # Replace with function body.


func _on_body_exited(body: Node2D): #PhysicsBody2D
	if(body.is_in_group("player")):
		print("you left the safe zone")
		body.safe = false
	# print(str("boop", body.name))
	pass # Replace with function body.


func _on_attack_area_entered(_area):
	pass # Replace with function body.


func _on_entered_roam_area():
	pass # Replace with function body.


func _on_exited_roam_area():
	pass # Replace with function body.
