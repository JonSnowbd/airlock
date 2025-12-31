extends Window
class_name GameWindow

@export var root: FoldableContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root.resized.connect(recalculate_window)
	recalculate_window()


func recalculate_window():
	if root.folded:
		size.x = 200
	else:
		size.x = 400
	size.y = int(root.size.y)

func window_focus(_data):
	pass
