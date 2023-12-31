extends Learner

const THETA = 0.01
const MAX_POLICY_EVAL_ITERATIONS = 50

# m[s][a] contains {"results": {s: {reward: 0, frequency: 0}, ...}, "total": total_frequency}
var m = {}
# q[s][a]
var q = {}
var gamma = 0.9
var starting_epsilon = 0.9
var episodes_to_zero = 50
var episodes = 0

# trial is a list of [s, a, r]
func rl_step(trial: Array, is_terminal: bool, env: RLEnvironment) -> void:
	if is_terminal:
		episodes += 1
	if len(trial) > 1:
		# Update model
		add_frequency(m, trial[-2][0], trial[-2][1], trial[-1][0], trial[-1][2])
		
		# Update state-action value function
		var iterations = 0
		var delta = THETA
		while delta >= THETA and iterations < MAX_POLICY_EVAL_ITERATIONS:
			iterations += 1
			delta = 0
			
			var nq = q.duplicate(true)
			for s in m:
				for a in m[s]:
					init_state_action(q, s, a)
					init_state_action(nq, s, a)
					
					nq[s][a] = 0
					for result in m[s][a]["results"]:
						var ns = result
						var r = m[s][a]["results"][result]["reward"] / m[s][a]["results"][result]["frequency"]
						var p = m[s][a]["results"][result]["frequency"] / m[s][a]["total"]
						nq[s][a] += p * (r + gamma * get_state_value(q, ns))
					delta = max(delta, abs(nq[s][a] - q[s][a]))
			q = nq
		
		# Updates value function visualization -----------------------------------------------------
		for s in q:
			update_view_qs(q, s, env)

# Graph, current state
func select_action(s: Vector2i, ax: Array[Vector2i], env: RLEnvironment) -> Vector2i:
	var r = randf()
	if r <= linear_decrease(starting_epsilon, episodes_to_zero, episodes):
		return ax[randi() % len(ax)]
	
	var max_value = -INF
	var best_action
	for a in ax:
		init_state_action(q, s, a)
		
		if q[s][a] > max_value:
			max_value = q[s][a]
			best_action = a
	
	return best_action


func add_frequency(d: Dictionary, s: Vector2i, a: Vector2i, ns: Vector2i, r: float):
	init_model(d, s, a)
	
	if not ns in d[s][a]["results"]:
		d[s][a]["results"][ns] = {"reward": 0.0, "frequency": 0.0}
	d[s][a]["results"][ns]["reward"] += r
	d[s][a]["results"][ns]["frequency"] += 1.0
	d[s][a]["total"] += 1.0


func init_model(d: Dictionary, s: Vector2i, a: Vector2i):
	if not s in d:
		d[s] = {}
	if not a in d[s]:
		d[s][a] = {"results": {}, "total": 0}

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
