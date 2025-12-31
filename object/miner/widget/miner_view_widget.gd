extends Control

@export var name_label: Label
@export var avatar_rect: TextureRect
@export var status_rect: TextureRect
@export var health: ProgressBar
@export var storage: ProgressBar

var target: Miner

func start_watching(miner: Miner):
	target = miner
	var avatar = AtlasTexture.new()
	avatar.atlas = target.head_sprite.texture
	avatar.region = target.head_sprite.region_rect
	avatar_rect.texture = avatar
	avatar_rect.set_instance_shader_parameter("hair_color", miner.skin_colored_sprites[0].get_instance_shader_parameter("hair_color"))
	avatar_rect.set_instance_shader_parameter("skin_color", miner.skin_colored_sprites[0].get_instance_shader_parameter("skin_color"))

func _physics_process(delta: float) -> void:
	health.max_value = target.max_health
	health.min_value = 0.0
	health.value = target.current_health
	storage.value = target.get_inventory_weight()
	storage.min_value = 0.0
	storage.max_value = float(target.stat_oxenship)
	
	name_label.text = target.human_name
