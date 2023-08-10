extends Node





func rl_step(trial: Array, is_terminal: bool) -> void:
	# Will only run is update if the episode has ended
	if is_terminal:
		# Prediction

# Graph, current state
func select_action(g: Dictionary, s: Vector2i) -> Vector2i:
	return Vector2i(0, 0)
