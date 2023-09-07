extends Rewarder

var base_reward = -0.2
var win_reward = 1.0
var lose_reward = -1.0

func get_reward(e: RLEnvironment, s: Vector2i) -> float:
	var object = e.get_cell_atlas_coords(e.OBJECT_LAYER, s)
	if object == e.WIN_TILE:
		return win_reward
	if object == e.LOSE_TILE:
		return lose_reward
	return base_reward
