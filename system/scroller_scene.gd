extends Node

@export var cam: Camera2D
@export var initial_room: DungeonRoom
@export var border: ApplicationBorder

var current_rooms: Array[DungeonRoom]
var current_windows: Array[GameWindow] = []
var crew: Array[Miner] = []

var ending: bool = false
var cam_pos = 0.0

func sync_window_settings():
	if ending: return
	var save = note.save as AirlockSave
	if save == null: return
	AirlockUtil.set_window(cam, cam_pos, initial_room, save.zoom, save.top_side, current_windows)

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
		if r.ending_room:
			break

	for miner: MinerSerialization in save.team:
		var spot = initial_room.spawns.pick_random()
		var inst = miner.hydrate()
		initial_room.spawns.erase(spot)
		add_child(inst)
		inst.global_position = spot.global_position
		inst.cooldown = 2.0
		crew.append(inst)
	
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
	if ending: return
	sync_window_settings()
	cam.position.y = 0.0
	cam.position.x += 7.0*delta
	var is_done = len(crew) > 0
	for c in crew:
		if c.extracted: continue
		is_done = false
		if c.global_position.y > 600.0:
			extract_miner(c)
	if is_done:
		ending = true
		finish()
	
func finish():
	await get_tree().create_timer(2.0).timeout
	note.level.change_to("uid://cnb5kyc4eoky2", true)
	note.transition.trigger(0.75)
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

func extract_miner(target: Miner):
	target.extracted = true
	for a in target.action_list:
		a.action_extracted()
