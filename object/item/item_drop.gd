extends CharacterBody2D
class_name ItemDrop

static var prefab: PackedScene

static func create_drop(new_item: ItemDef) -> ItemDrop:
	if prefab == null:
		prefab = load("uid://cigx5upcl88dx")
	var inst = prefab.instantiate() as ItemDrop
	inst.set_item(new_item)
	return inst

@export var sprite: Sprite2D

var item: ItemDef

func set_item(new_item: ItemDef):
	item = new_item
	sprite.texture = new_item.item_icon

func eat():
	var t = create_tween()
	t.tween_property(self, "scale", Vector2(0.0001, 0.0001), 0.3)
	t.tween_callback(queue_free)

func _physics_process(delta: float) -> void:
	velocity.y += 9.81
	move_and_slide()
	if is_on_floor():
		velocity.y = 0.0
