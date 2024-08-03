extends Area2D

signal player_entered
signal player_exited

func _ready():
	# Connect signals manually if needed, but typically you do it in the editor.
	pass

#func _on_body_entered(body):
	#print("hi")
	#if body.is_in_group("player"):
		#emit_signal("player_entered", body)
#
#func _on_body_exited(body):
	#if body.is_in_group("player"):
		#emit_signal("player_exited", body)


func _on_body_entered(body):
	print("Entered agro area")
	if body.is_in_group("player"):
		print("was player")
		emit_signal("player_entered", body)
	pass # Replace with function body.


func _on_body_exited(body):
	print("Exited agro area")
	
	if body.is_in_group("player"):
		print("was player")
		emit_signal("player_exited", body)
	pass # Replace with function body.
