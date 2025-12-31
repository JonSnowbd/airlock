extends Resource
class_name MinerSerialization

@export_file("*.tscn", "*.scn") var base_prefab: String
@export_file("*.tres", "*.res") var additions: Array[String]

func hydrate() -> Miner:
	if base_prefab.is_empty(): return null
	if note.loading_screen.is_cached(base_prefab):
		var inst = note.loading_screen.fetch(base_prefab).instantiate() as Miner
		if inst != null:
			return inst
	else:
		var inst = note.loading_screen.force_fetch(base_prefab).instantiate() as Miner
		if inst != null:
			return inst
	return null
