extends HSlider


#func _on_VolumeSlider_value_changed(value):
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func _ready():
	self.value = 0  # Start the slider at 0 dB, representing 100%
	update_volume_label(0)

func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	update_volume_label(value)

func update_volume_label(value):
	# Since VolumePercentageLabel is a direct child of VolumeSlider
	var label = get_node("VolumePercentageLabel")
	var percentage = int((1 + (value / 40)) * 100)
	label.text = str(percentage) + "%"
