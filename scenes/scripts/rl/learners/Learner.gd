class_name Learner

# Math -------------------------------------------------------------------------
const e = 2.71828

# Past state, past action, current state, reward
func rl_step(ps: Vector2i, pa: Vector2i, cs: Vector2i, r: float) -> void:
	pass

# Graph, current state
func select_action(g: Dictionary, s: Vector2i) -> Vector2i:
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
