extends Rewarder

const BASE_REWARD = -0.2
const WIN_REWARD = 1.0
const LOSE_REWARD = -1.0

func get_reward(e: RLEnvironment, s: Vector2i) -> float:
	var object = e.get_cell_atlas_coords(e.OBJECT_LAYER, s)
	if object == e.WIN_TILE:
		return WIN_REWARD
	if object == e.LOSE_TILE:
		return LOSE_REWARD
	return BASE_REWARD
