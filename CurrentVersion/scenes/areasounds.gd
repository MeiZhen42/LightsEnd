extends Area2D


func _on_area_entered(area):
	# Emit the built-in body_entered signal
	emit_signal("body_entered", area)

func _on_area_exited(area):
	# Emit the built-in body_exited signal
	emit_signal("body_exited", area)
