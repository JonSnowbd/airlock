extends CharacterBody2D
class_name Miner

@export_group("Design")
@export var miner_unit_name: String
@export var miner_skin_colors: Array[Color] = []
@export var miner_hair_colors: Array[Color] = []
@export var possible_first_names: Array[String] = []
@export var possible_last_names: Array[String] = []

@export_group("Stats", "stat_")
## How much it notices things and makes the right choice
@export var stat_cognizance: int = 3
## How strong it is in combat
@export var stat_perspicacity: int = 3
## How fast it is
@export var stat_rapidity: int = 3
## An arbitrary scalar for many things including luck.
@export var stat_je_ne_sais_quoi: int = 3
## How much it can carry
@export var stat_oxenship: int = 10
@export var default_tags: Array[Script] = []

@export_group("References")
@export var hand_transform: RemoteTransform2D
@export var body_root: Node2D
@export var search: RayCast2D
@export var foot_cast: RayCast2D
@export var animator: AnimationPlayer
@export var default_actions: Array[Script]
@export var action_threshold: float = 5.0
@export var head_sprite: Sprite2D
@export var skin_colored_sprites: Array[Node2D]
@export var grave_fall: RayCast2D

var human_name: String

var navigating: bool = false
## If true, wont think for itself regarding actions.
var coordinating: bool = false
var target_x: float = 0.0

var current_action: MinerBaseAction
var action_list: Array[MinerBaseAction]
var crew: Array[Miner]
var cooldown: float = 0.0

var search_array: Array[Dictionary]
var action_attempts: int = 0

var locked: bool = false
var items: Array[ItemDef] = []

var stagnant_jumps: Array[float] = []

var max_health: float = 0.0
var current_health: float = 0.0

var push_animation: String = "" :
	set(val):
		push_animation = val
		if !val.is_empty():
			animator.play(val)
var base_animation: String

func animation_finished(anim: String):
	if push_animation == anim:
		animator.play(base_animation)
		push_animation = ""

func _ready() -> void:
	for act in default_actions:
		var inst = Node.new()
		inst.set_script(act)
		if inst is MinerBaseAction:
			add_child(inst)
			inst.miner = self
			action_list.append(inst)
	animator.animation_finished.connect(animation_finished)
	var skin_color = miner_skin_colors.pick_random()
	var vec3_skin = Vector3(skin_color.r, skin_color.g, skin_color.b)
	var hair_color = miner_hair_colors.pick_random()
	var vec3_hair = Vector3(hair_color.r, hair_color.g, hair_color.b)
	for node in skin_colored_sprites:
		node.set_instance_shader_parameter("skin_color", vec3_skin)
		node.set_instance_shader_parameter("hair_color", vec3_hair)
	human_name = "%s %s" % [possible_first_names.pick_random(), possible_last_names.pick_random()]
	max_health = lerp(30.0, 150.0, float(stat_perspicacity)/10.0)
	current_health = max_health

func cant_navigate() -> bool:
	return !grave_fall.is_colliding() or len(stagnant_jumps) > 10

func populate_search():
	search_array.clear()
	var eye_checks = clamp(lerp(3.0, 24.0, float(stat_cognizance)/10.0), 4.0, 24.0)
	for x in range(floor(eye_checks)):
		search.target_position = Vector2.RIGHT.rotated(randf_range(-PI,PI)) * 70.0
		search.force_raycast_update()
		if search.is_colliding():
			search_array.append({
				"collider" = search.get_collider(),
				"position" = search.get_collision_point(),
				"normal" = search.get_collision_normal(),
			})

func _physics_process(delta: float) -> void:
	var new_base = "idle"
	if is_on_floor() and abs(velocity.x) > 1.0:
		new_base = "walk"
	if !is_on_floor():
		new_base = "falling"
	if is_on_floor() or is_on_ceiling() and velocity.y > 0.0:
		velocity.y = 0.0
	velocity += Vector2(0.0, 9.81)
	if !locked and navigating:
		var x_diff = target_x - global_position.x
		var movespeed = lerp(15.0, 75.0, float(stat_rapidity)/10.0)
		if abs(x_diff) > 2.0:
			velocity.x = movespeed * sign(x_diff)
		else:
			velocity.x = 0.0
			navigating = false
		if abs(velocity.x) > 1.0:
			var foot_cast_dist = lerp(7.5, 15.0, float(stat_rapidity)/7.0)
			foot_cast.target_position.x = foot_cast_dist if velocity.x > 1.0 else -foot_cast_dist
			body_root.scale.x = 1.0 if velocity.x > 1.0 else -1.0
			grave_fall.position.x = 8.0 if velocity.x > 1.0 else -8.0
		
		var mouse_pos = get_local_mouse_position()
		var is_mouse_boosting = abs(mouse_pos.x) < 6.0 and abs(mouse_pos.y) < 4.0 and velocity.y > 0.0
		foot_cast.force_raycast_update()
		if abs(velocity.x) > 1.0 and (is_on_floor() or is_mouse_boosting) and foot_cast.is_colliding():
			stagnant_jumps.append(floor(global_position.x))
			velocity.y = -145.0
			var base_jump = stagnant_jumps[0]
			for s in stagnant_jumps:
				if abs(base_jump - s) > 1.0:
					stagnant_jumps.clear()
					break
	
	for a in action_list:
		if a.action_butt():
			if current_action != null:
				current_action.action_end()
				current_action = null
	if current_action == null:
		if cooldown > 0.0:
			cooldown -= delta
		if cooldown <= 0.0:
			populate_search()
			var best_action: MinerBaseAction = null
			var best_action_prio = 0.0
			for i in action_list:
				var prio = i.action_get_prio()
				if prio > best_action_prio:
					best_action_prio = prio
					best_action = i
			if best_action_prio > action_threshold - (action_attempts * 3.0):
				current_action = best_action
				current_action.action_start()
				action_attempts = 0
			else:
				action_attempts += 1
	else:
		var resp = current_action.action_work(delta)
		if resp == MinerBaseAction.Response.Done:
			current_action.action_end()
			current_action = null
			cooldown = max(randf_range(0.25, 0.5), cooldown)
		if resp == MinerBaseAction.Response.CantContinue:
			current_action.action_end()
			current_action = null
			cooldown = max(0.75, cooldown)
	
	if !locked and (new_base != base_animation):
		animator.play(new_base)
		base_animation = new_base
	
	move_and_slide()

func get_inventory_weight() -> float:
	var sum = 0.0
	for i in items:
		sum += i.weight
	return sum
func can_carry(new_item: ItemDef) -> bool:
	var current_weight = get_inventory_weight()
	return new_item.weight + current_weight <= stat_oxenship

func lock():
	locked = true
	velocity.x = 0.0
	animator.current_animation = &"RESET"
	animator.seek(0.0, true, true)
	animator.stop()
func unlock():
	locked = false
	animator.call_deferred("play", base_animation)
	rotation = 0.0

func grab(object: Node2D):
	hand_transform.remote_path = hand_transform.get_path_to(object)
func ungrab():
	hand_transform.remote_path = NodePath("")
