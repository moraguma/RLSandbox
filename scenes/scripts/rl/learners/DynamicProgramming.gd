extends Learner

# q[s][a]
var q = {}
var gamma = 0.9
var episodes_to_zero = 50
var episodes = 0

# trial is a list of [s, a, r]
func rl_step(trial: Array, is_terminal: bool, env: RLEnvironment) -> void:
	if is_terminal:
		episodes += 1
		
		# Update state-action value function
		var g = env.graph # g is {s: {a: [[s', chance]}}
		
		var nq = q.duplicate(true)
		for s in g:
			for a in g[s]:
				init_state_action(q, s, a)
				init_state_action(nq, s, a)
				
				nq[s][a] = 0
				for result in g[s][a]:
					var ns = result[0]
					var p = result[1]
					var r = env.rewarder.get_reward(env, ns)
					nq[s][a] += p * (r + gamma * get_state_value(q, ns))
		q = nq
		
		# Updates value function visualization -----------------------------------------------------
		for s in q:
			update_view_qs(q, s, env)

# Graph, current state
func select_action(s: Vector2i, ax: Array[Vector2i], env: RLEnvironment) -> Vector2i:
	var r = randf()
	
	var max_value = -INF
	var best_action
	for a in ax:
		init_state_action(q, s, a)
		
		if q[s][a] > max_value:
			max_value = q[s][a]
			best_action = a
	
	return best_action


func init_state_action(d: Dictionary, s: Vector2i, a: Vector2i):
	if not s in d:
		d[s] = {}
	if not a in d[s]:
		d[s][a] = 0

func get_state_value(d: Dictionary, s: Vector2i):
	if not s in d:
		return 0
	if len(d[s]) == 0:
		return 0
	
	var max_value = -INF
	for a in d[s]:
		if not d[s][a] > -INF:
			pass
		if d[s][a] > max_value:
			max_value = d[s][a]
	
	return max_value
