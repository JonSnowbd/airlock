extends MinerBaseAction

func action_get_prio() -> float:
	return 1.0
func action_start() -> void:
	miner.navigating = true
	var cam_pos = get_viewport().get_camera_2d().global_position
	miner.target_x = cam_pos.x+randf_range(-250.0, 250.0)

func action_work(_delta: float) -> Response:
	if !miner.navigating:
		return Response.Done
	if miner.cant_navigate():
		return Response.CantContinue
	return Response.Working
