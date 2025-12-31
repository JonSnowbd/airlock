extends NoteSaveSession
class_name AirlockSave

var team: Array[MinerSerialization] = []
var top_side: bool = false
var monitor: int = -1
var zoom: float = 2.0

func starting():
	monitor = DisplayServer.get_primary_screen()
	if exists("settings"):
		var obj = read_object("settings")
		top_side = obj.get_or_add("top_side", false)
		monitor = obj.get_or_add("monitor", monitor)
		zoom = obj.get_or_add("zoom", zoom)
	
	var pack = MinerSerialization.new()
	pack.base_prefab = "uid://bgmwi7jkh0llu"
	var savage = MinerSerialization.new()
	savage.base_prefab = "uid://0le1twb6dwd6"
	var wizzy = MinerSerialization.new()
	wizzy.base_prefab = "uid://cyq42i4b0pvko"
	
	team.append(pack)
	team.append(wizzy)
	team.append(savage)
	team.append(savage)
	team.append(savage)
func ending():
	write_object("settings", {
		"top_side" = top_side,
		"monitor" = monitor,
		"zoom" = zoom,
	})
