extends MinerBaseAction

var target: ItemDef
var victim: Miner

var done: bool = false

func action_get_prio() -> float:
	for c in miner.crew:
		if c.coordinating: continue
		for item in c.items:
			if miner.can_carry(item):
				target = item
				victim = c
				return 8.0
	return -1000.0

func action_start() -> void:
	done = false
	miner.navigating = true
	
func action_end() -> void:
	miner.ungrab()
	miner.unlock()
	victim.unlock()
	victim.cooldown = 1.0
	miner.cooldown = 1.0

func action_work(_delta: float) -> Response:
	miner.target_x = victim.global_position.x
	var dist = abs(miner.global_position.x - victim.global_position.x)
	miner.navigating = dist > 3.0
	if done: 
		victim.items.erase(target)
		miner.items.append(target)
		return Response.Done
	if !victim.items.has(target) or miner.cant_navigate():
		return Response.CantContinue
	if dist<3.5 and miner.is_on_floor() and victim.is_on_floor():
		begin_jacking()
		var t = create_tween()
		t.tween_interval(1.7)
		t.tween_callback(end_jacking)
	return Response.Working

func begin_jacking():
	miner.lock()
	victim.lock()
	victim.coordinating = true
	miner.animator.call_deferred("play", "jack")
	miner.call_deferred("grab", victim)
func end_jacking():
	victim.coordinating = false
	done = true
