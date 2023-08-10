extends Resetter

func get_initial_tile(g: Dictionary) -> Vector2i:
	return g.keys()[randi() % len(g)]
