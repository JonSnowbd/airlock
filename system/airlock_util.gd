extends Node
class_name AirlockUtil

static func set_window(cam: Camera2D, x_pos: float = 0.0, room: DungeonRoom = null, zoom: float = 2.0, at_top: bool = false, windows: Array[GameWindow] = []):
	var safe = DisplayServer.screen_get_usable_rect()
	var window = cam.get_window()
	if room == null:
		window.size.y = (16.0*8.0)*zoom
	else:
		window.size.y = (room.room_bounds.size.y*room.tile_set.tile_size.y)*zoom
	window.size.x = safe.size.x
	window.position.x = safe.position.x
	cam.zoom = Vector2(zoom, zoom)
	if room != null:
		var room_y = room.global_position.y
		room_y += room.room_bounds.size.y * room.tile_set.tile_size.y * 0.5
		cam.global_position.y = room_y
	else:
		cam.global_position.y = 0.0
	cam.global_position.x = x_pos
	
	if at_top:
		window.position.y = safe.position.y
	else:
		window.position.y = safe.size.y-window.size.y
	
	var stamp = 10.0
	for c in windows:
		c.position.x = window.position.x+int(stamp)
		if at_top:
			c.position.y = int(window.position.y-window.size.y+10.0)
		else:
			c.position.y = int(window.position.y-c.size.y-10.0)
		stamp += c.size.x+10.0
