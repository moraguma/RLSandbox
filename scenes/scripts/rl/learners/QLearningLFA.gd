extends Learner

const FEATURE_VECTOR_SIZE = 624

var gamma = 0.9
var starting_epsilon = 0.9
var episodes_to_zero = 200
var starting_alpha = 0.1
var w
var episodes = 0

var past_ax


func _init():
	# Initialize w
	w = []
	for i in range(FEATURE_VECTOR_SIZE):
		w.append(randf())


# trial is a list of [s, a, r]
func rl_step(trial: Array, is_terminal: bool, env: RLEnvironment) -> void:
	if is_terminal:
		episodes += 1
	
	# Will only update after an action has been taken
	if len(trial) >= 2:
		var s = trial[-2][0]
		var ns = trial[-1][0]
		var a = trial[-2][1]
		var r =  trial[-1][2]
		var na = get_best_action(ns, past_ax, env)
		
		var f = get_features(env, s, a)
		var nf = get_features(env, ns, na)
		
		var v = dot(f, w)
		var nv = dot(nf, w)
		
		var alpha_td_error = linear_decrease(starting_alpha, episodes_to_zero, episodes) * (r + gamma * nv - v)
		
		for i in range(len(w)):
			w[i] += alpha_td_error * f[i]

		
		# Updates value function visualization ---------------------------------------------------------
		update_view(s, env)


func get_features(env: RLEnvironment, s: Vector2i, a: Vector2i) -> Array[float]:
	var binarized_state = []
	for h in range(1, env.MAX_H):
		for v in range(1, env.MAX_V):
			binarized_state.append(1 if h == s[0] and v == s[1] else 0)
	
	var binarized_actions = []
	for action in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]:
		binarized_actions.append(1 if a == action else 0)
	
	var f: Array[float] = []
	
	for i in range(len(binarized_actions)):
		for j in range(len(binarized_state)):
			f.append(float(binarized_actions[i] * binarized_state[j]))
	
	return f


# q[s][a] is the q value of s, a
func select_action(s: Vector2i, ax: Array[Vector2i], env: RLEnvironment) -> Vector2i:
	past_ax = ax
	
	var r = randf()
	if r <= linear_decrease(starting_epsilon, episodes_to_zero, episodes):
		return ax[randi() % len(ax)]
	
	return get_best_action(s, ax, env)


func get_best_action(s: Vector2i, ax: Array[Vector2i], env: RLEnvironment) -> Vector2i:
	var max_v = -INF
	var best_a: Vector2i
	
	for a in ax:
		var v = dot(get_features(env, s, a), w)
		if v > max_v:
			max_v = v
			best_a = a
	
	return best_a


func update_view(s: Vector2i, env: RLEnvironment):
	var g = env.graph # Graph is {s: {a: [s', p]}}
	var table = {}
	
	var v = -INF
	var min_v = INF
	var total_q = 0.0
	
	table[s] = {}
	for pa in g[s]:
		table[s][pa] = dot(get_features(env, s, pa), w)
		total_q += abs(table[s][pa])
		
		if table[s][pa] < min_v:
			min_v = table[s][pa]
		if table[s][pa] > v:
			v = table[s][pa]
	
	env.update_value_view(s, v)
	
	for pa in g[s]:
		env.update_policy_view(s, pa, (table[s][pa] - min_v) / (total_q - min_v))
