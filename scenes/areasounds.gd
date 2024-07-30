extends Area2D

# You don't need to redefine signals here
# signal body_entered(body)
# signal body_exited(body)

func _on_area_entered(area):
	# Emit the built-in body_entered signal
	emit_signal("body_entered", area)

func _on_area_exited(area):
	# Emit the built-in body_exited signal
	emit_signal("body_exited", area)
