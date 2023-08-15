extends ActionResults

@export_range(0.0, 0.5) var chance = 0.1

func get_result(e: RLEnvironment, s: Vector2i, a:Vector2i) -> Array:
	return [[counter_clockwise_shift(a), chance], [clockwise_shift(a), chance], [a, 1 - 2 * chance]]


# Matrix rotation by theta = 270º
func clockwise_shift(a: Vector2i) -> Vector2i:
	return Vector2i(a[1], -a[0])


# Matrix rotation by theta = 90º
func counter_clockwise_shift(a: Vector2i) -> Vector2i:
	return Vector2i(-a[1], a[0])
