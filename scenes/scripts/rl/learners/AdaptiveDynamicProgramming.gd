extends Learner

const THETA = 0.01

# m[s][a] contains {"results": {s: {reward: 0, frequency: 0}, ...}, "total": total_frequency}
var m = {}
# q[s][a]
var q = {}
var gamma = 0.9
var starting_epsilon = 0.9
var episodes_to_zero_epsilon = 1000
var episodes = 0

# trial is a list of [s, a, r]
func rl_step(trial: Array, is_terminal: bool) -> void:
	if is_terminal:
		episodes += 1
	if len(trial) > 1:
		# Update model
		add_frequency(m, trial[-2][0], trial[-2][1], trial[-1][0], trial[-1][2])
		
		# Update state-action value function
		var delta = THETA
		while delta >= THETA:
			delta = 0
			for s in m:
				for a in m[s]:
					init_state_action(q, s, a)
					
					var old_q = q[s][a]
					for result in m[s][a]["results"]:
						var ns = result
						var r = m[s][a]["results"][result]["reward"]
						var p = m[s][a]["results"][result]["frequency"] / m[s][a]["total"]
						q[s][a] += p * (r + gamma * get_state_value(q, ns))

# Graph, current state
func select_action(s: Vector2i, ax: Array[Vector2i]) -> Vector2i:
	var r = randf()
	if r <= linear_decrease(starting_epsilon, episodes_to_zero_epsilon, episodes):
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
		d[s][a]["results"][ns] = {"reward": 0, "frequency": 0}
	d[s][a]["results"][ns]["reward"] += r
	d[s][a]["results"][ns]["frequency"] += 1
	d[s][a]["total"] += 1


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
		if d[s][a] > max_value:
			max_value = d[s][a]
	
	return max_value
