extends MinerBaseAction


func action_get_prio() -> float:
	var screen_pos = miner.global_position.x - get_viewport().get_camera_2d().global_position.x
	if abs(screen_pos) > 650.0:
		return 1000.0 # RUN RUN RUN RUN RUN
	return 0.0
func action_start() -> void:
	miner.navigating = true
	var cam_pos = get_viewport().get_camera_2d().global_position
	miner.target_x = cam_pos.x+randf_range(-80.0, 80.0)

func action_work(_delta: float) -> Response:
	if !miner.navigating:
		return Response.Done
	return Response.Working
