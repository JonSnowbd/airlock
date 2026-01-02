extends Node


@export var cam: Camera2D
@export var room: DungeonRoom
var cam_pos: float = 0.0

func _ready() -> void:
	var save = note.save as AirlockSave
	if save != null:
		save.zoom = 2.0

func _physics_process(delta: float) -> void:
	AirlockUtil.set_window(cam, cam_pos, room, 2.0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("drag"):
			cam_pos -= event.relative.x / cam.zoom.x
