extends CanvasLayer
class_name ApplicationBorder

@export var close: Button
@export var flip: Button
@export var mute: Button
@export var units: HBoxContainer


func _ready() -> void:
	close.pressed.connect(func():
		get_tree().quit()
	)
	flip.pressed.connect(func():
		var save = note.save as AirlockSave
		if save != null:
			save.top_side = !save.top_side
	)

func start_watching(miner: Miner):
	const widget = preload("uid://hmoftd3trbm")
	var miner_view_widget = widget.instantiate()
	miner_view_widget.start_watching(miner)
	units.add_child(miner_view_widget)
