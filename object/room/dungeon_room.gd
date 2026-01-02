extends TileMapLayer
class_name DungeonRoom

class OreDetail:
	var local_position: Vector2
	var tile_index: Vector2i
	var ore_index: Vector2i
	var room: DungeonRoom

@export var starting_room: bool = false
@export var ending_room: bool = false
@export var room_bounds: Rect2i
@export var spawns: Array[Marker2D]
@export_file("*.tscn", "*.scn") var next_rooms: Array[String]

@export var background_layer: TileMapLayer
@export var ore_layer: TileMapLayer

var next_area: DungeonRoom

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for scn in next_rooms:
		if !note.loading_screen.is_cached(scn):
			note.loading_screen.shadow_load(scn)

func generate_next_area() -> DungeonRoom:
	var scn = next_rooms.pick_random()
	var pack = note.loading_screen.force_fetch(scn)
	var inst: DungeonRoom = pack.instantiate()
	get_parent().add_child(inst)
	inst.global_position.y = global_position.y
	inst.global_position.x = global_position.x + (inst.tile_set.tile_size.x*room_bounds.size.x)
	next_area = inst
	return inst

func get_ore_data(world_position: Vector2, collision_normal: Vector2) -> OreDetail:
	var pos = ore_layer.to_local(world_position) + (collision_normal*-4.0)
	var ind = ore_layer.local_to_map(pos)
	var data = ore_layer.get_cell_tile_data(ind)
	if data == null: return null
	var ore_details = OreDetail.new()
	ore_details.room = self
	ore_details.local_position = pos
	ore_details.tile_index = ind
	return ore_details

func does_tile_exist(ind: Vector2i) -> bool:
	if ore_layer != null:
		return get_cell_tile_data(ind) != null or ore_layer.get_cell_tile_data(ind) != null
	else:
		return get_cell_tile_data(ind) != null

func destroy_tile_at(ind: Vector2i):
	set_cell(ind)
	if ore_layer != null:
		ore_layer.set_cell(ind)
