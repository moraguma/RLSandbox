extends Rewarder

const BASE_REWARD = -0.2
const WIN_REWARD = 1.0
const LOSE_REWARD = -1.0

func get_reward(t: TileMap, s: Vector2i) -> float:
	var object = t.get_cell_atlas_coords(t.OBJECT_LAYER, s)
	if object == t.WIN_TILE:
		return WIN_REWARD
	if object == t.LOSE_TILE:
		return LOSE_REWARD
	return BASE_REWARD
