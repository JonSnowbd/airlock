extends Node

@export var cam: Camera2D
@export var initial_room: DungeonRoom
@export var border: ApplicationBorder

var current_rooms: Array[DungeonRoom]
var current_windows: Array[GameWindow] = []
var crew: Array[Miner] = []

func sync_window_settings():
	var save = note.save as AirlockSave
	if save == null: return
	var safe = DisplayServer.screen_get_usable_rect()
	var window = get_window()
	window.size.y = (16.0*8.0)*save.zoom
	window.size.x = safe.size.x
	window.position.x = safe.position.x
	cam.zoom = Vector2(save.zoom, save.zoom)
	
	if save.top_side:
		window.position.y = safe.position.y
	else:
		window.position.y = safe.size.y-window.size.y
	
	var stamp = 10.0
	for c in current_windows:
		c.position.x = window.position.x+int(stamp)
		if save.top_side:
			c.position.y = int(window.position.y-window.size.y+10.0)
		else:
			c.position.y = int(window.position.y-c.size.y-10.0)
		stamp += c.size.x+10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var save = note.save as AirlockSave
	if save == null: note.error("No save found.")
	cam.position.x = 0.0
	sync_window_settings()
	
	note.time("World Gen")
	var size = get_window().size / save.zoom
	initial_room.position.x = (initial_room.tile_set.tile_size.x * initial_room.room_bounds.size.x)*-0.5
	initial_room.position.y = (initial_room.tile_set.tile_size.y*initial_room.room_bounds.size.y)*-0.5
	var r = initial_room
	for i in range(12):
		r = r.generate_next_area()

	for miner: MinerSerialization in save.team:
		var inst = miner.hydrate()
		inst.cooldown = 2.0
		var spot = initial_room.spawns.pick_random()
		initial_room.spawns.erase(spot)
		add_child(inst)
		inst.global_position = spot.global_position
		crew.append(inst)
		border.start_watching(inst)
	
	for miner in crew:
		for other in crew:
			if other != miner:
				miner.crew.append(other)
	
	note.time()

func create_new_window(prefab_uid: String) -> GameWindow:
	var win_scene
	if note.loading_screen.is_cached(prefab_uid):
		win_scene = note.loading_screen.fetch(prefab_uid)
	else:
		win_scene = load(prefab_uid)
	
	var new_window = win_scene.instantiate() as GameWindow
	add_child(new_window)
	current_windows.append(new_window)
	return new_window

func _physics_process(delta: float) -> void:
	sync_window_settings()
	cam.position.y = 0.0
	cam.position.x += 7.0*delta

func _unhandled_input(event: InputEvent) -> void:
	var save = note.save as AirlockSave
	if save == null: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			save.zoom = clamp(save.zoom+0.1, 1.5, 5.0)
			get_viewport().set_input_as_handled()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			save.zoom = clamp(save.zoom-0.1, 1.5, 5.0)
			get_viewport().set_input_as_handled()
