class_name Learner

# Math -------------------------------------------------------------------------
const e = 2.71828

func rl_step(trial: Array, is_terminal: bool) -> void:
	pass

# Graph, current state
func select_action(s: Vector2i, ax: Array[Vector2i]) -> Vector2i:
	return Vector2i(0, 0)

# --------------------------------------------------------------------------------------------------
# UTIL
# --------------------------------------------------------------------------------------------------

func dot(a, b):
	if len(a) != len(b):
		push_error("Dot product between vectors of different sizes!")
	
	var r = 0
	for i in range(len(a)):
		r += a[i] * b[i]
	
	return r

# Start, iterations to zero, iterations
func linear_decrease(s: float, r: float, i: int) -> float:
	return max(0, s - s * i/r)
