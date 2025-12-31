extends Node
class_name MinerBaseAction

enum Response {
	Working,
	CantContinue,
	Done
}

var animation: String = ""
var miner: Miner

func action_get_prio() -> float:
	return 0.0
func action_butt() -> bool:
	return false
func action_start() -> void:
	pass
func action_end() -> void:
	pass
func action_work(_delta: float) -> Response:
	return Response.Done
func action_extracted():
	pass
