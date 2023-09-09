class_name Learner

# Math -------------------------------------------------------------------------
const e = 2.71828

func rl_step(trial: Array, is_terminal: bool, env: RLEnvironment) -> void:
	pass

# Graph, current state
func select_action(s: Vector2i, ax: Array[Vector2i], env: RLEnvironment) -> Vector2i:
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


func update_view_qs(q, s, env: RLEnvironment):
	var v = -INF
	var min_v = INF
	var total_q = 0.0
	
	for pa in q[s]:
		total_q += abs(q[s][pa])
		
		if q[s][pa] < min_v:
			min_v = q[s][pa]
		if q[s][pa] > v:
			v = q[s][pa]
	
	env.update_value_view(s, v)
	
	for pa in q[s]:
		env.update_policy_view(s, pa, (q[s][pa] - min_v) / (total_q - min_v))
