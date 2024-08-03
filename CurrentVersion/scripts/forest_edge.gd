extends Node2D

const density = 1.5
const center = Vector2(112, 224) #Vector2(120,250) #
const radius = 700

# Called when the node enters the scene tree for the first time.
func _ready():
	var dtScene = preload("res://scenes/dark_tree.tscn")
	var child: Node2D
	for deg in range(0, 360, density):
		child = dtScene.instantiate()
		child.y_sort_enabled = true
		var loc = Vector2(cos(deg) * radius + center.x, sin(deg) * radius + center.y)
		child.position = loc # Vector2(cos(deg) * radius + center.x, sin(deg) * radius + center.y)
		add_child(child)
		pass
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta):

	pass
