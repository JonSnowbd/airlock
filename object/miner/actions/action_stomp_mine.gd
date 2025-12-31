extends MinerBaseAction


var detail: DungeonRoom.OreDetail
var jumps_left = 4
var target_y = 0.0

var item_to_create: ItemDef

func action_get_prio() -> float:
	for h: Dictionary in miner.search_array:
		var col = h["collider"]
		var n = h["normal"]
		var pos = h["position"]
		if col is TileMapLayer:
			var parent = col.get_parent()
			if parent is DungeonRoom:
				var dat = parent.get_ore_data(pos, n)
				if dat == null: continue
				detail = dat
				return 25.0
			else:
				continue
	return -100000.0
func action_start() -> void:
	item_to_create = null
	jumps_left = 4
	miner.navigating = true
	var local_ore_pos = detail.room.ore_layer.map_to_local(detail.tile_index)
	var ore_pos = detail.room.ore_layer.to_global(local_ore_pos)
	
	var cell_data = detail.room.ore_layer.get_cell_tile_data(detail.tile_index)
	if cell_data.has_custom_data("properties"):
		var item = cell_data.get_custom_data("properties")
		if item is ItemDef:
			item_to_create = item as ItemDef
	miner.target_x = ore_pos.x
	target_y = ore_pos.y-(detail.room.tile_set.tile_size.y*0.5)
func action_end():
	miner.navigating = false
	detail = null
func action_work(_delta: float) -> Response:
	if !detail.room.does_tile_exist(detail.tile_index):
		return Response.CantContinue
	if !miner.navigating and miner.is_on_floor():
		if abs(miner.global_position.y-target_y) > 4.0:
			return Response.CantContinue
		miner.velocity.y = -40.0
		jumps_left -= 1
		if jumps_left <= 0:
			var pos = detail.room.ore_layer.to_global(detail.room.ore_layer.map_to_local(detail.tile_index))
			detail.room.destroy_tile_at(detail.tile_index)
			var new_drop = ItemDrop.create_drop(item_to_create)
			miner.get_parent().add_child(new_drop)
			new_drop.global_position = pos
			new_drop.reset_physics_interpolation()
			miner.cooldown = 2.0
			return Response.Done
		
	return Response.Working
