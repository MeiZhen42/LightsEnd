extends Popup


func show_save_confirmation():
	# Assuming you have a Label node named SaveConfirmationLabel
	if has_node("SaveConfirmationLabel"):
		$SaveConfirmationLabel.text = "Game Saved!"
		$SaveConfirmationLabel.visible = true
		# Hide the label after a short delay
		await get_tree().create_timer(2.0).timeout
		$SaveConfirmationLabel.visible = false
