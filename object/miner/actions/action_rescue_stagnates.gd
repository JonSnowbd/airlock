extends MinerBaseAction

var target: ItemDrop

func action_get_prio() -> float:
	for c in miner.crew:
		if len(c.stagnant_jumps) > 4:
			return 15.0
	return -1000.0

func action_butt() -> bool:
	for c in miner.crew:
		if len(c.stagnant_jumps) > 4:
			return true
	return false

func action_start() -> void:
	miner.navigating = true
func action_end() -> void:
	miner.navigating = false

func action_work(_delta: float) -> Response:
	if target == null or !is_instance_valid(target):
		return Response.CantContinue
	var dist = abs(target.global_position.x - miner.global_position.x)
	miner.target_x = target.global_position.x
	miner.navigating = dist > 3.0
	if dist < 3.0 and miner.is_on_floor():
		target.eat()
		miner.items.append(target.item)
		miner.cooldown = 2.0
		miner.velocity.y = -40.0
		return Response.Done
	if miner.cant_navigate():
		return Response.CantContinue
	return Response.Working
